# PATCH-007: Require Authentication for Console Shell

**Vulnerability:** VULN-007 (Console shell without auth)
**Complexity:** Low
**Requires Recompilation:** Yes (inittab)
**Risk Level:** Low (risk of breaking functionality)

## Recommended Fix

Modify the inittab configuration to require login authentication for the console shell instead of providing an unauthenticated root shell. This prevents physical access attackers from gaining immediate root access to the device.

## Changes Required

### /etc/inittab
```
 # Console shell (direct access)
-ttyS0::respawn:-/bin/sh
+ttyS0::respawn:/bin/login
```

### /etc/inittab (alternative - getty style)
```
 # Serial console with login prompt
-ttyS0::respawn:-/bin/sh
+ttyS0::respawn:/sbin/getty -L ttyS0 115200 vt100
```

### /etc/passwd (ensure root has password)
```
-root::0:0:root:/root:/bin/sh
+root:x:0:0:root:/root:/bin/sh
```
Note: The `x` indicates password is in /etc/shadow; ensure a password is set.

### /etc/shadow (set initial password)
```
-root::14500:0:99999:7:::
+root:$6$rounds=5000$salt$hashed_password:14500:0:99999:7:::
```

### /etc/login.conf (optional - set proper permissions)
```
+# Console login settings
+console:
+        :passwd_format=sha512:
+        :copyright@/etc/copyright:
+        :welcome@/etc/welcome:
+        :shell=/bin/sh:
+        :homedir=/root:
+        :path=/bin:/sbin:/usr/bin:/usr/sbin:
+        :passwd_timeout=300:
+        :login_timeout=300:
```

## Verification

1. Connect to the serial console and verify a login prompt appears
2. Attempt to log in without credentials and confirm access is denied
3. Log in with valid credentials and confirm shell access works
4. Test password timeout and session limits
5. Verify the change persists after reboot

## Notes

- Ensure root password is set before applying this change
- Consider adding a timeout for idle console sessions
- Physical access to the serial port should still be restricted physically
- If recovery is needed, the device may need a factory reset procedure
- Document the console login credentials in a secure location
