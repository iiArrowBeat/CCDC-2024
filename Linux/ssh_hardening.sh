#!/bin/sh

# =========================
# SSH Security Hardening Commands
# =========================
# These commands modify the SSH daemon configuration to enhance security.
# This script applies settings manually without requiring additional scripts.

FILE=/etc/ssh/sshd_config

# =========================
# 1️⃣ Ensure SSH is Installed
# =========================
if ! command -v sshd >/dev/null 2>&1; then
    echo "[+] SSH server not found. Installing OpenSSH..."
    if command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y openssh-server
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y openssh-server
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm openssh
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y openssh
    fi
fi

# =========================
# 2️⃣ Check if sshd_config exists
# =========================
if [ ! -f "$FILE" ]; then
    echo "Could not find sshd config"
    exit 1
fi

# =========================
# 3️⃣ Disable TCP Forwarding (Prevents port forwarding abuse)
# =========================
sed -i 's/^AllowTcpForwarding/# AllowTcpForwarding/' "$FILE"
echo 'AllowTcpForwarding no' >> "$FILE"

# =========================
# 4️⃣ Disable X11 Forwarding (Prevents X11 hijacking attacks)
# =========================
sed -i 's/^X11Forwarding/# X11Forwarding/' "$FILE"
echo 'X11Forwarding no' >> "$FILE"

# =========================
# 5️⃣ Disable Root Login (Prevents unauthorized root SSH access)
# =========================
sed -i 's/^PermitRootLogin/# PermitRootLogin/' "$FILE"
echo 'PermitRootLogin no' >> "$FILE"

# =========================
# 6️⃣ Enforce Strong Key Exchange Algorithms
# =========================
echo "KexAlgorithms curve25519-sha256,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256" >> "$FILE"

# =========================
# 7️⃣ Enforce Strong Ciphers and MACs
# =========================
echo "Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr" >> "$FILE"
echo "MACs hmac-sha2-512,hmac-sha2-256" >> "$FILE"

# =========================
# 8️⃣ Disable Empty Passwords (Prevents unauthorized logins)
# =========================
sed -i 's/^PermitEmptyPasswords/# PermitEmptyPasswords/' "$FILE"
echo 'PermitEmptyPasswords no' >> "$FILE"

# =========================
# 9️⃣ Disable Password Authentication (Only use public key authentication)
# =========================
sed -i 's/^PasswordAuthentication/# PasswordAuthentication/' "$FILE"
echo 'PasswordAuthentication no' >> "$FILE"

# =========================
# 🔟 Set Idle Timeout Interval (Auto-logout inactive SSH sessions)
# =========================
echo "ClientAliveInterval 300" >> "$FILE"
echo "ClientAliveCountMax 0" >> "$FILE"

# =========================
# 1️⃣1️⃣ Disable SSH Protocol 1 (Only allow secure SSH protocol 2)
# =========================
sed -i 's/^Protocol/# Protocol/' "$FILE"
echo 'Protocol 2' >> "$FILE"

# =========================
# 1️⃣2️⃣ Restart SSH Service
# =========================
sys=$(command -v service || command -v systemctl)

if [ -z "$sys" ]; then
    if [ -f "/etc/rc.d/sshd" ]; then
        RC="/etc/rc.d/sshd"
    else
        RC="/etc/rc.d/rc.sshd"
    fi
    $RC restart
else
    $sys restart ssh || $sys ssh restart || $sys restart sshd || $sys sshd restart
fi

# =========================
# ✅ SSH Hardening Complete
# =========================
echo "[+] SSH security settings applied successfully."
