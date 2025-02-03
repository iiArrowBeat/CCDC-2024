#!/bin/sh

# =========================
# Linux Kernel Hardening Script
# =========================
# This script strengthens system security by modifying kernel parameters.
# It appends security-focused configurations to /etc/sysctl.conf and applies them.

file="/etc/sysctl.conf"

# =========================
# TCP Hardening
# =========================

# Enable SYN flood protection (Mitigates DoS attacks)
echo "net.ipv4.tcp_syncookies = 1" >> $file

# Reduce the number of times the system retries SYN-ACK responses (Prevents abuse)
echo "net.ipv4.tcp_synack_retries = 2" >> $file

# Increase challenge ACK limit (Helps mitigate certain TCP attacks)
echo "net.ipv4.tcp_challenge_ack_limit = 1000000" >> $file

# Enable RFC1337 protection (Prevents TIME-WAIT assassination attacks)
echo "net.ipv4.tcp_rfc1337 = 1" >> $file

# Ignore bogus ICMP error responses (Prevents ICMP-based DoS attacks)
echo "net.ipv4.icmp_ignore_bogus_error_responses = 1" >> $file

# Disable ICMP redirects (Prevents man-in-the-middle attacks via ICMP redirects)
echo "net.ipv4.conf.all.accept_redirects = 0" >> $file

echo "net.ipv4.conf.default.accept_redirects = 0" >> $file

echo "net.ipv6.conf.all.accept_redirects = 0" >> $file

echo "net.ipv6.conf.default.accept_redirects = 0" >> $file

# Ignore all ICMP echo requests (Prevents ping-based reconnaissance)
echo "net.ipv4.icmp_echo_ignore_all = 1" >> $file

# =========================
# Kernel Security Hardening
# =========================

# Append process ID to core dumps (Enhances debugging & security)
echo "kernel.core_uses_pid = 1" >> $file

# Restrict access to kernel pointers in /proc (Prevents memory disclosure)
echo "kernel.kptr_restrict = 2" >> $file

# Disable loading of kernel modules (Prevents unauthorized kernel modifications)
echo "kernel.modules_disabled = 1" >> $file

# Restrict access to performance events (Prevents certain side-channel attacks)
echo "kernel.perf_event_paranoid = 2" >> $file

# Enable full Address Space Layout Randomization (ASLR) (Mitigates memory corruption exploits)
echo "kernel.randomize_va_space = 2" >> $file

# Disable magic SysRq key (Prevents unauthorized low-level system control)
echo "kernel.sysrq = 0" >> $file

# Restrict ptrace system call (Prevents process memory snooping attacks)
echo "kernel.yama.ptrace_scope = 2" >> $file

# Prevent unprivileged users from accessing kernel logs
echo "kernel.dmesg_restrict = 1" >> $file

# =========================
# Filesystem Protections
# =========================

# Prevent hardlink exploitation (Mitigates privilege escalation via insecure file linking)
echo "fs.protected_hardlinks = 1" >> $file

# Prevent symlink exploitation (Mitigates symlink race conditions)
echo "fs.protected_symlinks = 1" >> $file

# Prevent core dumps of SUID binaries (Prevents leaking sensitive data)
echo "fs.suid_dumpable = 0" >> $file

# Disable unprivileged user namespace cloning (Reduces attack surface for privilege escalation)
echo "kernel.unprivileged_userns_clone = 0" >> $file

# Protect FIFO and regular files from unauthorized modification
echo "fs.protected_fifos = 2" >> $file
echo "fs.protected_regular = 2" >> $file

# Protect against race conditions in /proc
echo "fs.protected_proc = 2" >> $file

# =========================
# Network Security Hardening
# =========================

# Disable IP forwarding (Prevents unauthorized packet routing)
echo "net.ipv4.ip_forward = 0" >> $file

echo "net.ipv6.conf.all.forwarding = 0" >> $file

# Enable Reverse Path Filtering (Prevents IP spoofing attacks)
echo "net.ipv4.conf.all.rp_filter = 1" >> $file

echo "net.ipv4.conf.default.rp_filter = 1" >> $file

# Log suspicious packets (Detects and logs bad network traffic)
echo "net.ipv4.conf.all.log_martians = 1" >> $file

echo "net.ipv4.conf.default.log_martians = 1" >> $file

# Enable TCP SYN Cookies to prevent SYN flood attacks
echo "net.ipv4.tcp_syncookies = 1" >> $file

# Disable source routing (Prevents attackers from controlling packet routing)
echo "net.ipv4.conf.all.accept_source_route = 0" >> $file

echo "net.ipv6.conf.all.accept_source_route = 0" >> $file

echo "net.ipv4.conf.default.accept_source_route = 0" >> $file

echo "net.ipv6.conf.default.accept_source_route = 0" >> $file

# =========================
# Apply Changes
# =========================
# Reload sysctl settings without rebooting
sysctl -p >/dev/null
