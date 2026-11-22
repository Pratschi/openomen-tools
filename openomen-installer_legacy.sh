#!/usr/bin/env bash
set -e

INSTALL_PATH="/usr/local/bin/openomen"
TMP_FILE="/tmp/openomen_new"

echo -e "\nUnofficial Openomen Installer/Updater [LEGACY] - Version 1.0\n"
echo "[INFO] Obtaining latest/current versions..."

# Obtain latest release's JSON
LATEST_JSON=$(curl -s https://api.github.com/repos/openomen/openomen/releases/latest)

# Extract Version from the Latest Release
LATEST_VERSION=$(echo "$LATEST_JSON" | grep '"tag_name"' | cut -d '"' -f4)
LATEST_VERSION_CLEAN=$(echo "$LATEST_VERSION" | sed 's/.*_//')

echo -e "\n[INFO] Latest Version: v$LATEST_VERSION_CLEAN"

# Detect current version
if [ -f "$INSTALL_PATH" ]; then
    CURRENT_VERSION=$("$INSTALL_PATH" 2>/dev/null | grep -oE 'V[0-9]+\.[0-9]+\.[0-9]+')
    CURRENT_VERSION_CLEAN=$(echo "$CURRENT_VERSION" | sed 's/^V//')
    echo "Current Version: v$CURRENT_VERSION_CLEAN"

    if [ -n "$CURRENT_VERSION_CLEAN" ] && [ "$CURRENT_VERSION_CLEAN" = "$LATEST_VERSION_CLEAN" ]; then
        echo -e "\n[INFO] You already have the latest version!"
        exit 0
    fi
else
    echo "[INFO] Current Version: Openomen is not installed."
fi

echo "[INFO] Downloading new version..."

# Get the binary file from the Latest Release
DOWNLOAD_URL="https://github.com/openomen/openomen/releases/download/$LATEST_VERSION/openomen"

if [ -z "$DOWNLOAD_URL" ]; then
    echo "[ERROR] Latest release's binary not found."
    exit 1
fi

# Download file
curl -s -L "$DOWNLOAD_URL" -o "$TMP_FILE"

# Check downloaded file
if [ ! -s "$TMP_FILE" ]; then
    echo "[ERROR] Download failed. Please check your internet connection and try again."
    sudo rm -f "$TMP_FILE"
    exit 1
fi

chmod +x "$TMP_FILE"

echo "[INFO] Verifying binary..."

DOWNLOADED_VERSION=$("$TMP_FILE" 2>/dev/null | grep -oE 'V[0-9]+\.[0-9]+\.[0-9]+')
DOWNLOADED_VERSION_CLEAN=$(echo "$DOWNLOADED_VERSION" | sed 's/^V//')

if [ ! "$DOWNLOADED_VERSION_CLEAN" = "$LATEST_VERSION_CLEAN" ]; then
    echo "[ERROR] The downloaded binary is either invalid or corrupted. Please try again."
    sudo rm -f "$TMP_FILE"
    exit 0
fi

echo "[INFO] Installing to '/usr/local/bin/openomen'..."

# Replace the old binary with the new one
sudo rm -f "$INSTALL_PATH"
sudo mv "$TMP_FILE" "$INSTALL_PATH"

echo -e "\n[INFO] Updated correctly to Version v$LATEST_VERSION_CLEAN"
