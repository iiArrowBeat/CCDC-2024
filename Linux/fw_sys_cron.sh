#!/bin/bash

# Enable syslog
echo "Enabling syslog..."
systemctl enable --now rsyslog

echo "Configuration completed."


# Ensure firewalld is installed and running
if ! command -v firewall-cmd &>/dev/null; then
    echo "Installing firewalld..."
    apt update && apt install -y firewalld
    systemctl enable --now firewalld
fi

# Configure firewalld
ICMP_TYPE="echo-request"
SERVICE_NAME="ssh" 
PORT_NUMBER="443"  
PORT_TYPE="tcp" 

echo "Configuring firewalld..."
firewall-cmd --add-icmp-block=$ICMP_TYPE
firewall-cmd --add-icmp-block-inversion
firewall-cmd --runtime-to-permanent
firewall-cmd --list-services
firewall-cmd --add-service=$SERVICE_NAME
firewall-cmd --add-port=$PORT_NUMBER/$PORT_TYPE
firewall-cmd --remove-port=$PORT_NUMBER/$PORT_TYPE
firewall-cmd --set-log-denied=all

# Check for root-level cron jobs
echo "Checking for root-level cron jobs..."
if [ -f /var/spool/cron/crontabs/root ]; then
    echo "Root crontab found:"
    cat /var/spool/cron/crontabs/root
else
    echo "No root crontab found."
fi




