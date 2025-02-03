#!/bin/sh


# =========================
# PAM Security Management Script
# =========================
# This script manages PAM (Pluggable Authentication Modules), backs up configurations,
# reinstalls packages if necessary, and provides security enhancements for multiple Linux distros.

# =========================
# Set Backup Directories
# =========================
if [ -z "$BCK" ]; then
    BCK="/root/.cache"
fi

BACKUPCONFDIR="$BCK/pam.d"
BACKUPBINARYDIR="$BCK/pam_libraries"

# Create backup directories if they do not exist
mkdir -p $BACKUPCONFDIR
mkdir -p $BACKUPBINARYDIR

# =========================
# Firewall Allow/Deny Controls
# =========================

ipt=$(command -v iptables || command -v /sbin/iptables || command -v /usr/sbin/iptables)
IS_BSD=false

if command -v pkg >/dev/null || command -v pkg_info >/dev/null; then
    IS_BSD=true
fi

ALLOW() {
    if [ "$IS_BSD" = true ]; then
        pfctl -d  # Disable firewall on BSD
    else
        $ipt -P OUTPUT ACCEPT  # Allow all outgoing traffic
    fi
}

DENY() {
    if [ "$IS_BSD" = true ]; then
        pfctl -e  # Enable firewall on BSD
    else
        $ipt -P OUTPUT DROP  # Block all outgoing traffic
    fi
}

# =========================
# Handle PAM Configuration Backup & Restore
# =========================
handle_pam() {
    if [ ! -z "$REVERT" ]; then
        echo "[+] Reverting PAM binaries from backup..."
        if [ -d "$BACKUPBINARYDIR" ]; then
            find "$BACKUPBINARYDIR" -type f | while read -r file; do
                ORIGINAL_DIR=$(echo "$file" | sed "s|$BACKUPBINARYDIR||g" | xargs dirname)
                echo "Restoring $file to $ORIGINAL_DIR"
                mkdir -p "$ORIGINAL_DIR"
                cp "$file" "$ORIGINAL_DIR"
            done
        else
            echo "[-] Backup directory $BACKUPBINARYDIR does not exist. Cannot revert."
            exit 1
        fi

        echo "[+] Reverting PAM configuration files..."
        if [ -d "$BACKUPCONFDIR" ]; then
            cp -R "$BACKUPCONFDIR"/* /etc/pam.d/
        else
            echo "[-] Backup directory $BACKUPCONFDIR does not exist. Cannot revert."
            exit 1
        fi

        echo "[+] Reversion complete."
    else
        echo "[+] Backing up PAM configuration files and binaries..."

        # Backup configuration directory
        mkdir -p "$BACKUPCONFDIR"
        cp -R /etc/pam.d/* "$BACKUPCONFDIR/"

        # Backup PAM-related binaries
        mkdir -p "$BACKUPBINARYDIR"
        MOD=$(find /lib/ /lib64/ /usr/lib/ /usr/lib64/ -name "pam_unix.so" 2>/dev/null)

        if [ -z "$MOD" ]; then
            echo "[-] pam_unix.so not found"
        else
            echo "[+] Found the following pam_unix.so files:"
            echo "$MOD"
            for i in $MOD; do
                BINARY_DIR=$(dirname "$i")
                DEST="$BACKUPBINARYDIR$BINARY_DIR"
                echo "Backing up all binaries from $BINARY_DIR to $DEST"
                mkdir -p "$DEST"
                cp "$BINARY_DIR"/pam* "$DEST/"
            done
        fi

        echo "[+] Backup complete."
    fi
}

# =========================
# PAM Reinstallation for Different Distros
# =========================

DEBIAN() {
    if [ ! -z "$REINSTALL" ]; then
        echo "[+] Reinstalling PAM-related packages..."
        DEBIAN_FRONTEND=noninteractive
        pam-auth-update --package --force
        apt-get -y --reinstall install libpam-runtime libpam-modules
        echo "[+] Reinstallation complete."
    fi
    handle_pam
}

RHEL() {
    if [ ! -z "$REINSTALL" ]; then
        echo "[+] Reinstalling PAM-related packages..."
        yum -y reinstall pam
        echo "[+] Reinstallation complete."
		if command -v authconfig >/dev/null; then
			authconfig --updateall
		fi
    fi
    handle_pam
}

SUSE() {
    if [ ! -z "$REINSTALL" ]; then
        echo "[+] Reinstalling PAM-related packages..."
        zypper install -f -y pam
        pam-config --update
        echo "[+] Reinstallation complete."
    fi
    handle_pam
}

UBUNTU(){
  DEBIAN
}

ARCH() {
    if [ ! -z "$REINSTALL" ]; then
        echo "[+] Reinstalling PAM-related packages for Arch..."
        pacman -S --noconfirm pam
        echo "[+] Reinstallation complete."
    fi
    handle_pam
}

BSD() {
    if [ ! -z "$REINSTALL" ]; then
        echo "[+] Reinstalling PAM-related packages for BSD..."
        pkg install -f pam || pkg_add -f pam
        echo "[+] Reinstallation complete."
    fi
    handle_pam
}

# =========================
# OS Detection and Execution
# =========================
ALLOW

if command -v yum >/dev/null ; then
  RHEL
elif command -v zypper >/dev/null ; then
  SUSE
elif command -v apt-get >/dev/null ; then
  if grep -qi Ubuntu /etc/os-release; then
      UBUNTU
  else
      DEBIAN
  fi
elif command -v pacman >/dev/null ; then
  ARCH
elif command -v pkg >/dev/null || command -v pkg_info >/dev/null; then
    BSD
fi

DENY
