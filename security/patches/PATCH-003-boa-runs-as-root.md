# PATCH-003: Run Boa Web Server as Non-Root User

**Vulnerability:** VULN-003 (Boa runs as root)
**Complexity:** Medium
**Requires Recompilation:** Yes (boa.conf + boa binary)
**Risk Level:** Medium (risk of breaking functionality)

## Recommended Fix

Configure the Boa web server to run as the `nobody` user with `nogroup` group instead of root. CGI scripts should also drop privileges. This limits the impact of any web server vulnerabilities by reducing the process's effective permissions.

## Changes Required

### /etc/boa/boa.conf
```
-User root
-Group root
+User nobody
+Group nogroup
```

### /etc/boa/boa.conf (CGI directory permissions)
```
 # CGI execution settings
 ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
+SuexecOwner nobody
+SuexecGroup nogroup
```

### /etc/boa/boa.conf (log file permissions)
```
-ErrorLog /var/log/boa/error_log
+ErrorLog /var/log/boa/error_log
+# Ensure log directory is writable by nobody
```

### /etc/init.d/rcS_32M ( boa startup modification)
```
 # Start Boa web server
-boa -c /etc/boa/boa.conf
+# Ensure proper permissions for Boa
+chown -R nobody:nogroup /var/log/boa
+chown -R nobody:nogroup /var/www
+chown -R nobody:nogroup /tmp
+boa -c /etc/boa/boa.conf &
```

### /var/www/cgi-bin/ (CGI script wrapper)
```
+#!/bin/sh
+# CGI wrapper that drops privileges
+# CGI scripts should not run as root
+. /usr/libexec/cgi-bin/actual_script.cgi
```

## Verification

1. Start Boa and verify the process runs as nobody: `ps aux | grep boa`
2. Verify the boa process shows `nobody` in the USER column
3. Access the web UI and confirm all pages load correctly
4. Test CGI functionality (status pages, configuration changes)
5. Verify log files are created with correct ownership
6. Check that CGI scripts cannot modify system files outside their scope

## Notes

- CGI scripts may need to be rewritten if they rely on root privileges
- File permissions in /var/www must allow nobody to read all static files
- CGI scripts writing to /tmp or /var/log need appropriate directory permissions
- Consider using a chroot jail for additional isolation
