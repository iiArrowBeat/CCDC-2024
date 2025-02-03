#!/bin/bash

# =========================
# Linux Security Command Reference Guide
# =========================
# This guide provides security-related commands for Ubuntu/Debian,
# CentOS/RHEL, and Arch Linux. All commands are fully commented.
# This is a reference document.

# =========================
# Ubuntu/Debian Security Investigation Commands
# =========================

# ===== User Management & Privilege Escalation Checks =====

# List all user accounts
cut -d: -f1 /etc/passwd

# List all users who have logged in
last -a

# Check for unauthorized users currently logged in
who
w
users

# List users with root privileges (UID 0)
awk -F: '($3 == 0) {print}' /etc/passwd

# Display all users with sudo privileges
sudo grep -Po '^sudo.+:\K.*$' /etc/group

# Show users with empty passwords (security risk)
awk -F: '($2 == "") {print $1}' /etc/shadow

# Identify any accounts that can run commands without passwords
sudo grep -R "NOPASSWD" /etc/sudoers*

# Find all users with a shell (check for unauthorized accounts)
awk -F: '$7 !~ /nologin/ {print $1 " -> " $7}' /etc/passwd

# Show all users who recently switched to root
sudo grep "session opened for user root" /var/log/auth.log

# Check for users with unauthorized cron jobs
for user in $(cut -f1 -d: /etc/passwd); do echo "Cron jobs for $user"; sudo crontab -u $user -l 2>/dev/null; done

# ===== Log Analysis & System Monitoring =====

# View authentication logs
sudo less /var/log/auth.log

# Monitor real-time system logs
sudo tail -f /var/log/syslog

# Search for failed login attempts
sudo grep 'Failed password' /var/log/auth.log

# Show last 50 failed login attempts
sudo journalctl -u sshd | grep 'Failed password' | tail -50

# Show kernel logs (look for system errors)
sudo dmesg | tail -50

# Search for unauthorized SSH access
sudo grep 'Accepted password' /var/log/auth.log

# List sudo command usage by users
sudo cat /var/log/auth.log | grep sudo

# Identify any processes running as root
ps aux | grep '^root'

# ===== Advanced Network & Firewall Investigation =====

# List all active network connections
sudo netstat -tulpn

# Identify unusual open ports
sudo ss -tulnp | grep -v ':22 '

# View network connections sorted by traffic usage
sudo nethogs

# View top connections (requires iftop package)
sudo iftop -P -n -i eth0

# List all firewall rules (UFW)
sudo ufw status verbose

# Check if IP forwarding is enabled (should be disabled)
sudo sysctl net.ipv4.ip_forward

# Monitor real-time network traffic on interface eth0
sudo tcpdump -i eth0 -nn -c 100

# ===== Malware, Rootkits & Unauthorized Changes =====

# Check for known rootkits
sudo rkhunter --checkall

# Scan for unauthorized system file changes
sudo aide --check

# Identify running processes that do not belong to installed packages
sudo ps aux | grep -vE "($(dpkg --get-selections | awk '{print $1}' | tr '\n' '|'))"

# Scan for suspicious binary modifications
sudo debsums -s

# Check for hidden files in home directories
find /home -type f -name ".*" 2>/dev/null

# Check if system files have been recently modified
sudo find /etc -type f -mtime -1 -ls 2>/dev/null

# ===== Advanced System Integrity Checks =====

# Check for unauthorized system accounts
awk -F: '($3 < 1000) {print}' /etc/passwd

# Identify all files owned by specific users
sudo find / -user username 2>/dev/null

# Locate recent changes to configuration files
sudo find /etc -mtime -2 -ls 2>/dev/null

# Identify unmounted partitions and hidden data storage
sudo fdisk -l
sudo lsblk

# Monitor file system changes in real-time
sudo inotifywait -m /etc

# ===== System-Wide Security Auditing (All Distributions) =====

# List all installed packages (check for rogue installs)
sudo dpkg --get-selections | grep -v deinstall  # Debian-based
rpm -qa  # RHEL-based
pacman -Q  # Arch-based

# Check for unauthorized user privilege escalation (sudo logs)
sudo cat /var/log/sudo.log | grep -i 'failed'

# Scan for unauthorized new services added
sudo systemctl list-unit-files --type=service | grep enabled

# Check for rogue kernel modules
sudo lsmod | awk '{print $1}' | while read mod; do modinfo $mod; done | grep -i "author"

# Verify system startup scripts (potential persistence mechanisms)
sudo find /etc/rc*.d -type f -exec ls -lh {} \;

# Scan for suspicious processes running in memory
sudo lsof -nP +L1 | grep deleted

# Check for cron jobs running as root
sudo crontab -l
sudo ls -lah /etc/cron.* /etc/crontab /var/spool/cron/crontabs/

# Perform memory dump for forensic analysis
sudo dd if=/dev/mem of=/root/mem.dump bs=1M count=512

# Identify network services running without a known process
sudo netstat -anp | grep LISTEN | grep -v 'sshd'

# Find files with recent SUID/SGID permission changes (potential escalation risk)
sudo find / -perm /6000 -type f -mtime -1 -ls 2>/dev/null

# Compare system binaries with known good checksums
sudo debsums -c  # Debian-based
rpm -Va  # RHEL-based

# Verify SELinux/AppArmor status (confirm mandatory access controls are active)
sudo getenforce  # SELinux (RHEL)
sudo aa-status  # AppArmor (Ubuntu)

# List all established network connections (detect unusual remote connections)
sudo netstat -an | grep ESTABLISHED

# Detect unauthorized use of raw network sockets (e.g., potential malware)
sudo lsof -i -n | grep -E 'RAW|udp'

# Validate kernel parameters for hardening
sudo sysctl -a | grep -E 'exec-shield|randomize_va_space|tcp_syncookies'

# =========================
# Hardening Complete
# =========================
# This document provides essential security investigation commands
# for Ubuntu/Debian, CentOS/RHEL, and Arch Linux systems. Regular audits
# and monitoring are necessary to maintain a strong security posture.

