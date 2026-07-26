# PATCH-020: config.dat Accessible via HTTP

**Vulnerability:** VULN-020
**Complexity:** Low
**Requires Recompilation:** Yes
**Risk Level:** High

## Recommended Fix

Remove symlink, restrict access to config.dat, or encrypt sensitive fields. The configuration file contains WiFi passwords, admin credentials, and ISP credentials in plaintext, accessible via HTTP at `/config.dat`.

## Changes Required

### /etc/httpd.conf
```
 # HTTP server configuration
 
+# Block direct access to sensitive files
+<Location /config.dat>
+    Deny from all
+</Location>
+
+<Location /etc/config>
+    Deny from all
+</Location>
+
 # CGI scripts
 /cgi-bin:/www/cgi-bin
```

### /www/cgi-bin/get_config.cgi
```
 #!/bin/sh
 
+# Remove sensitive fields from output
+sanitize_config() {
+    sed -e 's/password=.*/password=******/g' \
+        -e 's/psk=.*/psk=******/g' \
+        -e 's/key=.*/key=******/g' \
+        -e 's/secret=.*/secret=******/g'
+}
+
 echo "Content-type: text/plain"
 echo ""
-cat /etc/config.dat
+cat /etc/config.dat | sanitize_config
```

### /etc/init.d/S80httpd
```
 #!/bin/sh
 
+# Remove config.dat symlink if it exists
+rm -f /www/config.dat
+
 case "$1" in
     start)
         echo "Starting HTTP server..."
```

### /www/config.dat (symlink removal)
```
-/www/config.dat -> /etc/config.dat
+(symlink removed)
```

### /etc/config.dat
```
-# File world-readable
+# Restrict permissions
 chmod 600 /etc/config.dat
 chown root:root /etc/config.dat
```

## Verification

```bash
# Verify symlink is removed
ls -la /www/config.dat

# Test direct access is blocked
curl -I http://192.168.1.1/config.dat
# Should return 403 Forbidden

# Test CGI output is sanitized
curl -s http://192.168.1.1/cgi-bin/get_config.cgi | grep password
# Should show ****** instead of actual password

# Check file permissions
ls -la /etc/config.dat
stat -c "%a" /etc/config.dat
```

## Notes

- If config.dat is needed for backup, create a separate CGI endpoint with authentication
- Consider moving to UCI format (`uci show`) for better access control
- If web UI needs to modify config, use authenticated CGI with session tokens
- Backup config.dat before applying changes
