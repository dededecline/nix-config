#!/usr/bin/env bash
set -e

# Mac App Store apps to install and manage
declare -A MAS_APPS=(
  ['Home Assistant']=1099568401
  ['iMovie']=408981434
  ['Okta Verify']=490179405
  ['Parcel']=639968404
  ['Perplexity']=6714467650
  ['Reeder']=1529448980
  ['Tot']=1491071483
)

# Function to get current mas version
get_current_version() {
  local mas_path="/usr/local/bin/mas"
  if ! [ -x "$mas_path" ]; then # Check if the file exists and is executable
    echo "not_installed"
    return
  fi
  "$mas_path" version # Get version using the specific path
}

# Function to get latest version and package URL from GitHub
get_latest_release_info() {
  local release_info
  release_info=$(curl -s https://api.github.com/repos/mas-cli/mas/releases/latest)
  if [ -z "$release_info" ]; then
    echo "Error: Could not fetch release info from GitHub." >&2
    return 1
  fi
  
  local version
  version=$(echo "$release_info" | grep '"tag_name":' | sed -E 's/.*"v([^"]+)".*/\1/')
  if [ -z "$version" ]; then
    echo "Error: Could not parse version from GitHub release info." >&2
    return 1
  fi
  
  # Find the .pkg asset URL directly from the release assets
  local pkg_url
  pkg_url=$(echo "$release_info" | grep -o '"browser_download_url": ".*\.pkg"' | grep -o 'https://.*\.pkg' | head -n 1)
  if [ -z "$pkg_url" ]; then
    echo "Error: Could not parse package URL from GitHub release info." >&2
    return 1
  fi
  
  echo "$version $pkg_url"
}

# Function to compare versions
version_lt() {
  [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$1" ] && [ "$1" != "$2" ]
}

# Function to download and install the latest version
install_latest_version() {
  local pkg_url=$1
  local temp_dir
  temp_dir=$(mktemp -d)
  local pkg_file="${temp_dir}/mas.pkg"
  
  echo "Downloading mas package from ${pkg_url}..."
  if ! curl --fail -L -o "${pkg_file}" "${pkg_url}"; then
    echo "Error: Failed to download package from ${pkg_url}" >&2
    rm -rf "${temp_dir}"
    return 1
  fi
  
  # Verify the download was successful and file exists
  if [ ! -s "${pkg_file}" ]; then # Check if file exists and is not empty
    echo "Error: Downloaded package file is empty or not found at ${pkg_file}" >&2
    rm -rf "${temp_dir}"
    return 1
  fi
  
  echo "Installing mas package..."
  # Capture installer output, print it only on error
  local install_log
  if ! install_log=$(sudo installer -pkg "${pkg_file}" -target / 2>&1); then
    echo "Error: Installation failed." >&2
    echo "Installer log:" >&2
    echo "$install_log" >&2
    rm -rf "${temp_dir}"
    return 1
  else
    echo "Installation successful."
  fi
  
  # Clean up
  rm -rf "${temp_dir}"
  
  # Add /usr/local/bin to PATH if not already there (where mas is likely installed)
  if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
    export PATH="/usr/local/bin:$PATH"
    echo "Temporarily added /usr/local/bin to PATH for this script execution."
  fi
  
  return 0
}

# Function to get installed MAS app IDs
get_installed_mas_apps() {
  local mas_path="$1"
  "$mas_path" list | awk '{print $1}' || true # Return empty if error or no apps
}

# Function to get outdated MAS app IDs
get_outdated_mas_apps() {
  local mas_path="$1"
  "$mas_path" outdated | awk '{print $1}' || true # Return empty if error or no outdated apps
}

# Function to ensure required MAS apps are installed
ensure_mas_apps_installed() {
  local mas_path="$1"
  shift # Remove mas_path from arguments
  local -n apps_to_manage=$1 # Use nameref for associative array
  
  echo "Checking installed MAS applications..."
  local installed_ids
  installed_ids=$(get_installed_mas_apps "$mas_path")
  local installed_ids_set=$(echo "$installed_ids" | tr '
' ' ')
  
  local app_name app_id missing_apps=0
  for app_name in "${!apps_to_manage[@]}"; do
    app_id="${apps_to_manage[$app_name]}"
    if ! echo " $installed_ids_set " | grep -q " $app_id "; then
      echo "App '${app_name}' (ID: ${app_id}) is not installed. Installing..."
      if ! "$mas_path" install "$app_id"; then
          echo "Error: Failed to install '${app_name}' (ID: ${app_id})." >&2
          # Decide if this should be a fatal error or just a warning
      else
          echo "'${app_name}' installed successfully."
      fi
      missing_apps=$((missing_apps + 1))
    else
      echo "App '${app_name}' (ID: ${app_id}) is already installed."
    fi
  done
  
  if [ $missing_apps -eq 0 ]; then
      echo "All required MAS apps are installed."
  fi
}

# Function to update outdated MAS apps if they are in our managed list
update_outdated_mas_apps() {
    local mas_path="$1"
    shift # Remove mas_path from arguments
    local -n apps_to_manage=$1 # Use nameref for associative array

    echo "Checking for outdated MAS applications..."
    local outdated_ids
    outdated_ids=$(get_outdated_mas_apps "$mas_path")
    
    if [ -z "$outdated_ids" ]; then
        echo "No outdated MAS apps found."
        return 0
    fi

    local outdated_ids_set=$(echo "$outdated_ids" | tr '
' ' ')
    local app_name app_id updates_needed=0
    
    echo "Found outdated app IDs: $outdated_ids_set"

    for app_name in "${!apps_to_manage[@]}"; do
        app_id="${apps_to_manage[$app_name]}"
        if echo " $outdated_ids_set " | grep -q " $app_id "; then
            echo "App '${app_name}' (ID: ${app_id}) is outdated. Updating..."
            if ! "$mas_path" upgrade "$app_id"; then
                echo "Error: Failed to update '${app_name}' (ID: ${app_id})." >&2
                # Decide if this should be a fatal error or just a warning
            else
                echo "'${app_name}' updated successfully."
            fi
            updates_needed=$((updates_needed + 1))
        fi
    done
    
    if [ $updates_needed -eq 0 ]; then
        echo "None of the managed MAS apps need an update."
    else
        echo "Finished checking managed MAS app updates."
    fi
}

# Function to uninstall MAS apps not listed in the managed list
uninstall_unmanaged_mas_apps() {
    local mas_path="$1"
    shift
    local -n apps_to_manage=$1

    echo "Checking for unmanaged MAS applications to uninstall..."
    local installed_ids
    installed_ids=$(get_installed_mas_apps "$mas_path")

    if [ -z "$installed_ids" ]; then
        echo "No MAS apps currently installed."
        return 0
    fi

    # Create a set of managed app IDs for efficient lookup
    local managed_ids_set=" "
    local app_id
    for app_id in "${apps_to_manage[@]}"; do
        managed_ids_set+="$app_id "
    done

    local id_to_check uninstalled_count=0
    echo "Currently installed app IDs: $(echo $installed_ids | tr '\n' ' ')"
    echo "Managed app IDs:$(echo $managed_ids_set | sed 's/^ //;s/ $//')"
    
    # Convert installed_ids string (newline separated) to an array
    local -a installed_ids_array
    readarray -t installed_ids_array <<< "$installed_ids"

    for id_to_check in "${installed_ids_array[@]}"; do
        # Skip empty lines that might result from awk/readarray
        if [ -z "$id_to_check" ]; then
            continue
        fi
        
        if ! echo "$managed_ids_set" | grep -q " $id_to_check "; then
            echo "App ID ${id_to_check} is installed but not in the managed list. Uninstalling..."
            # Attempt to find app name using mas list for better logging
            local app_name_info
            app_name_info=$("$mas_path" list | grep "^$id_to_check " || echo "")
            if [ -n "$app_name_info" ]; then
                echo "  (App Info: $app_name_info)"
            fi

            if ! sudo "$mas_path" uninstall "$id_to_check"; then
                echo "Error: Failed to uninstall App ID ${id_to_check}." >&2
                # Decide if this should be a fatal error or just a warning
            else
                echo "App ID ${id_to_check} uninstalled successfully."
                uninstalled_count=$((uninstalled_count + 1))
            fi
        fi
    done

    if [ $uninstalled_count -eq 0 ]; then
        echo "No unmanaged MAS apps found to uninstall."
    else
        echo "Finished uninstalling unmanaged MAS apps."
    fi
}

# --- Main Script ---
echo "Starting mas management script..."

# 1. Check/Install mas CLI
mas_path="/usr/local/bin/mas"
echo "Checking local mas CLI status..."
current_version=$(get_current_version)

if [ "$current_version" == "not_installed" ]; then
  echo "mas CLI not found."
else
  echo "Current mas version: ${current_version}"
fi

# Fetch latest version info
echo "Fetching latest mas CLI release info from GitHub..."
release_info=$(get_latest_release_info)
if [ $? -ne 0 ]; then 
    echo "Error: Cannot proceed without latest release info." >&2
    exit 1
fi
latest_version=$(echo "$release_info" | cut -d' ' -f1)
pkg_url=$(echo "$release_info" | cut -d' ' -f2-)
echo "Latest mas version available: ${latest_version}"

# Decide if update/installation is needed
install_needed=false
if [ "$current_version" == "not_installed" ]; then
    install_needed=true
    echo "Installation required."
elif version_lt "${current_version}" "${latest_version}"; then
    install_needed=true
    echo "Update required from ${current_version} to ${latest_version}."
else
    echo "mas CLI is already up-to-date (${current_version})."
fi

# Perform installation/update if needed
if $install_needed; then
  echo "Starting mas CLI installation/update..."
  if ! install_latest_version "${pkg_url}"; then
    echo "Error: Failed to install/update mas CLI." >&2
    exit 1
  fi
  # Find the binary path *after* successful installation
  if [ -z "$mas_path" ]; then
      echo "Error: Could not find mas binary even after installation attempt." >&2
      echo "Please check installation logs and ensure mas is in your PATH." >&2
      exit 1
  fi
  echo "Found mas binary at: $mas_path"
  # Verify installation using the found binary path
  new_version=$("$mas_path" version 2>/dev/null || echo "unknown")
  echo "Verification: mas is now at version ${new_version}"
  if [ "${new_version}" != "${latest_version}" ]; then
      echo "Warning: Installed version (${new_version}) doesn't match expected latest version (${latest_version})." >&2
  fi
else
    # If already installed and up-to-date, ensure we have the path
    if [ -z "$mas_path" ]; then
        if [ -z "$mas_path" ]; then
            echo "Error: mas is installed but could not find binary path." >&2
            exit 1
        fi
    fi
    echo "Using mas binary at: $mas_path"
fi

# Check if mas binary path is valid
if [ -z "$mas_path" ] || ! [ -x "$mas_path" ]; then
    echo "Error: mas binary path '$mas_path' is not set or not executable." >&2
    exit 1
fi

# 2. Manage MAS Applications based on MAS_APPS list
echo "Managing MAS applications..."

# Ensure all defined apps are installed
ensure_mas_apps_installed "$mas_path" MAS_APPS

# Update any outdated apps from the list
update_outdated_mas_apps "$mas_path" MAS_APPS

# Uninstall unmanaged apps
uninstall_unmanaged_mas_apps "$mas_path" MAS_APPS

echo "MAS application management complete."
