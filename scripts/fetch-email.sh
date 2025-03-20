#!/usr/bin/env bash

# Check if gitconfig.user exists and has an email field with content
if [ -f ~/.gitconfig.user ] && grep -E -q "email = .+" ~/.gitconfig.user; then
  # Email already exists, just make sure GitHub credentials are set
  if ! grep -q "credential \"https://github.com\"" ~/.gitconfig.user; then
    # Add GitHub credentials section
    echo "" >> ~/.gitconfig.user
    echo "[credential \"https://github.com\"]" >> ~/.gitconfig.user
    echo "    helper = manager" >> ~/.gitconfig.user
    echo "    username = $GITHUB_USERNAME" >> ~/.gitconfig.user
  fi
else
  # No existing email, fetch from 1Password
  email=$($OP_BIN item get "git-email" --fields email --reveal 2>/dev/null)
  if [ -n "$email" ]; then
    echo "[user]" > ~/.gitconfig.user
    echo "    name = $USER_NAME" >> ~/.gitconfig.user
    echo "    email = $email" >> ~/.gitconfig.user
    echo "    username = $GITHUB_USERNAME" >> ~/.gitconfig.user
    
    # Configure GitHub authentication
    echo "[credential \"https://github.com\"]" >> ~/.gitconfig.user
    echo "    helper = manager" >> ~/.gitconfig.user
    echo "    username = $GITHUB_USERNAME" >> ~/.gitconfig.user
  fi
fi
