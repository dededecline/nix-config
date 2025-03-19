# From https://github.com/craigfurman/nix-workstations/blob/main/home/apps/make-app-trampolines.sh

fromDir="$HOME/Applications/Nix Apps"
toDir="$HOME/Applications/Nix Trampolines"
mkdir -p "$toDir"

(
  cd "$fromDir"
  for app in *.app; do
    /usr/bin/osacompile -o "$toDir/$app" -e "do shell script \"open '$fromDir/$app'\""

    # Just clobber the applet icon laid down by osacompile rather than do
    # surgery on the plist.
    cp "$fromDir/$app/Contents/Resources"/*.icns "$toDir/$app/Contents/Resources/applet.icns"
  done
)

# cleanup
(
  cd "$toDir"
  for app in *.app; do
    if [ ! -d "$fromDir/$app" ]; then
      rm -rf "$toDir/$app"
    fi
  done
)
