# =========================
# PAM Security Management Commands
# =========================
# These commands manually manage and secure PAM (Pluggable Authentication Modules)
# for various Linux distributions without requiring a separate script.

# =========================
# 1️⃣ Set Backup Directories
# =========================
BCK="/root/.cache"
BACKUPCONFDIR="$BCK/pam.d"
BACKUPBINARYDIR="$BCK/pam_libraries"
mkdir -p "$BACKUPCONFDIR"
mkdir -p "$BACKUPBINARYDIR"

# =========================
# 2️⃣ Backup PAM Configuration Files
# =========================
cp -R /etc/pam.d/* "$BACKUPCONFDIR/"
chmod -R 600 "$BACKUPCONFDIR"

# =========================
# 3️⃣ Backup PAM Binaries
# =========================
find /lib/ /lib64/ /usr/lib/ /usr/lib64/ -name "pam_unix.so" 2>/dev/null | while read -r MOD; do
    BINARY_DIR=$(dirname "$MOD")
    DEST="$BACKUPBINARYDIR$BINARY_DIR"
    mkdir -p "$DEST"
    cp "$BINARY_DIR"/pam* "$DEST/"
done
chmod -R 600 "$BACKUPBINARYDIR"

# =========================
# 4️⃣ Reinstall PAM Packages (Based on Distro)
# =========================
if command -v apt >/dev/null 2>&1; then
    DEBIAN_FRONTEND=noninteractive
    pam-auth-update --package --force
    apt-get -y --reinstall install libpam-runtime libpam-modules
elif command -v yum >/dev/null 2>&1; then
    yum -y reinstall pam
    if command -v authconfig >/dev/null; then
        authconfig --updateall
    fi
elif command -v pacman >/dev/null 2>&1; then
    pacman -S --noconfirm pam
elif command -v zypper >/dev/null 2>&1; then
    zypper install -f -y pam
    pam-config --update
elif command -v pkg >/dev/null 2>&1 || command -v pkg_info >/dev/null; then
    pkg install -f pam || pkg_add -f pam
fi

# =========================
# 5️⃣ Restore PAM Configuration (If Needed)
# =========================
if [ ! -z "$REVERT" ]; then
    cp -R "$BACKUPCONFDIR"/* /etc/pam.d/
    find "$BACKUPBINARYDIR" -type f | while read -r file; do
        ORIGINAL_DIR=$(echo "$file" | sed "s|$BACKUPBINARYDIR||g" | xargs dirname)
        mkdir -p "$ORIGINAL_DIR"
        cp "$file" "$ORIGINAL_DIR"
    done
fi

# =========================
# ✅ PAM Security Management Complete
# =========================
echo "[+] PAM security settings applied successfully."
