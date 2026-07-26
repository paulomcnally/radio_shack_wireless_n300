# PATCH-018: uShare Telnet Control Port Exposed

**Vulnerability:** VULN-018
**Complexity:** Low
**Requires Recompilation:** Yes
**Risk Level:** Medium

## Recommended Fix

Remove USHARE_TELNET_PORT or set it to 0 to disable telnet control. uShare exposes a telnet-based control interface that allows unauthenticated command execution for media server management.

## Changes Required

### /etc/ushare.conf
```
 # /etc/ushare.conf
 # uShare configuration file
 
 # Network interface
 USHARE_IFACE="br0"
 
 # Shared directories
 USHARE_DIR="/mnt/usb"
 
 # Enable Web interface
 USHARE_ENABLE_web="yes"
 
 # Telnet control interface
-USHARE_TELNET_PORT=2020
+USHARE_TELNET_PORT=0
 
 # HTTP port
 USHARE_HTTP_PORT=49200
```

### /etc/init.d/S53ushare
```
 #!/bin/sh
+
+# Ensure telnet control is disabled regardless of config
+sed -i 's/^USHARE_TELNET_PORT=.*/USHARE_TELNET_PORT=0/' /etc/ushare.conf
 
 case "$1" in
     start)
         echo "Starting uShare..."
```

### /etc/ushare.conf (alternative: remove telnet entirely)
```
 # /etc/ushare.conf
 # uShare configuration file
 
 USHARE_IFACE="br0"
 USHARE_DIR="/mnt/usb"
 USHARE_ENABLE_web="yes"
-USHARE_TELNET_PORT=2020
 USHARE_HTTP_PORT=49200
```

## Verification

```bash
# Check if telnet port is listening
netstat -tlnp | grep 2020

# Verify config change
grep USHARE_TELNET_PORT /etc/ushare.conf

# Test uShare starts without telnet
/etc/init.d/S53ushare start
netstat -tlnp | grep ushare

# Attempt telnet connection (should fail)
telnet 192.168.1.1 2020
```

## Notes

- uShare control port provides unauthenticated media server management
- Web UI (port 49200) should remain accessible for legitimate use
- If media server features are unused entirely, consider disabling uShare completely
- Setting port to 0 is safer than removing the line (some versions default to enabled)
