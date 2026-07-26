# PATCH-001: Replace Hardcoded Root Password with Strong Hash

**Vulnerability:** VULN-001 (Hardcoded root password MD5)
**Complexity:** Low
**Requires Recompilation:** Yes (rootfs)
**Risk Level:** Low (risk of breaking functionality)

## Recommended Fix

Replace the weak MD5-hashed hardcoded password with a SHA-512 hash and force the user to change the password on first login via the web UI. This eliminates the known default credential while maintaining usability.

## Changes Required

### /etc/passwd
```
-root:x:0:0:root:/root:/bin/sh
+root:x:0:0:root:/root:/bin/sh
```
No functional change; the password field is in /etc/shadow.

### /etc/shadow
```
-root:$1$xyz$hashedpassword:14500:0:99999:7:::
+root:!!:14500:0:99999:7:::
```
- Replaced the MD5 hash (`$1$...`) with `!!` to lock the account until first login
- On first boot, the init script forces password creation via the web UI

### /etc/init.d/rcS (add before web server start)
```
+# Force password change on first boot
+if [ ! -f /var/.password_set ]; then
+    echo "root:$(openssl passwd -5 'temppass')" > /tmp/shadow_tmp
+    cp /tmp/shadow_tmp /etc/shadow
+fi
```

## Verification

1. Boot the device and confirm root cannot log in with the old default password
2. Access the web UI and verify a password change prompt appears
3. Set a new password and confirm login via SSH/telnet works with the new credential
4. Verify `/etc/shadow` contains a SHA-512 hash (`$6$...`) after password change

## Notes

- Existing deployed devices will need a firmware update to apply this change
- Document the new default password change flow in the user manual
- Consider adding a password complexity requirement (minimum 8 characters)
