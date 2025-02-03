#!/bin/sh

# =========================
# Restricted Bash (rbash) Enforcement Script
# =========================
# This script restricts all users (except root) to using rbash (Restricted Bash).
# It ensures a backup of /etc/passwd is created before making changes.

BCK="/root/.cache"
BACKUP_FILE="$BCK/passwd.bak"

# =========================
# Backup /etc/passwd Before Modifying
# =========================
mkdir -p "$BCK"
cp /etc/passwd "$BACKUP_FILE"
chmod 644 "$BACKUP_FILE"
echo "[+] Backup of /etc/passwd saved to $BACKUP_FILE"

# =========================
# Ensure rbash Exists
# =========================
if ! command -v rbash >/dev/null 2>&1; then
    echo "[-] rbash not found. Creating symlink to /bin/bash."
    ln -sf /bin/bash /bin/rbash
fi

# =========================
# Restrict All Users to rbash
# =========================
if command -v bash >/dev/null 2>&1; then
    echo "[+] Restricting all users to rbash..."
    head -1 /etc/passwd > /etc/pw.tmp
    sed -n '1!p' /etc/passwd | sed 's/\/bin\/.*sh$/\/bin\/rbash/g' >> /etc/pw.tmp
    mv /etc/pw.tmp /etc/passwd
    chmod 644 /etc/passwd
    echo "[+] All users are now restricted to rbash."
fi

# =========================
# How to Restore Original /etc/passwd
# =========================
echo "[INFO] To restore original shell access, run:"
echo "      cp $BACKUP_FILE /etc/passwd"
