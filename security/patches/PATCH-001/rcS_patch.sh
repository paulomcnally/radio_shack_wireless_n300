#!/bin/sh
# PATCH-001: rcS patch for first-boot password change
# Add this BEFORE the web server (boa) startup in /etc/init.d/rcS_32M
#
# This ensures the force_password_change script runs before the web UI

# --- BEGIN PATCH-001: Force password change on first boot ---
if [ -x /etc/init.d/force_password_change ]; then
    /etc/init.d/force_password_change
fi
# --- END PATCH-001 ---

# Existing rcS_32M continues below:
# boa
# telnetd&
