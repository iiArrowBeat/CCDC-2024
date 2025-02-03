#!/bin/sh

# =========================
# Corrupted Package Checker & Updater
# =========================
# This script identifies corrupted or missing packages and attempts to reinstall them.

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PM="apt"
elif command -v yum >/dev/null 2>&1; then
    PM="yum"
elif command -v dnf >/dev/null 2>&1; then
    PM="dnf"
elif command -v pacman >/dev/null 2>&1; then
    PM="pacman"
elif command -v zypper >/dev/null 2>&1; then
    PM="zypper"
elif command -v pkg >/dev/null 2>&1; then
    PM="pkg"
else
    echo "[-] No supported package manager found. Exiting."
    exit 1
fi

echo "[+] Detected package manager: $PM"

# Function to check and fix corrupted packages
fix_packages() {
    case $PM in
        apt)
            echo "[+] Checking for broken packages in Debian/Ubuntu..."
            sudo dpkg --configure -a
            sudo apt update
            sudo apt --fix-broken install -y
            sudo apt upgrade -y
            ;;
        yum|dnf)
            echo "[+] Checking for broken packages in RHEL-based systems..."
            sudo $PM check
            sudo $PM clean all
            sudo $PM reinstall -y $(rpm -Va | awk '$1 ~ /..5/ {print $NF}')
            sudo $PM update -y
            ;;
        pacman)
            echo "[+] Checking for broken packages in Arch Linux..."
            sudo pacman -Qk | grep -v "0 missing" | cut -d ' ' -f1 | xargs sudo pacman -S --noconfirm
            sudo pacman -Syu --noconfirm
            ;;
        zypper)
            echo "[+] Checking for broken packages in OpenSUSE..."
            sudo zypper verify
            sudo zypper refresh
            sudo zypper update -y
            ;;
        pkg)
            echo "[+] Checking for broken packages in FreeBSD..."
            sudo pkg check -Ba
            sudo pkg upgrade -y
            ;;
        *)
            echo "[-] Unsupported package manager: $PM"
            exit 1
            ;;
    esac
    echo "[+] Package check and update complete."
}

# Execute the package fix function
fix_packages
