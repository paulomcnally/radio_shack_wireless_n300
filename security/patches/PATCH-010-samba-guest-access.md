# PATCH-010: Disable Samba Guest Access

**Vulnerability:** VULN-010 (Samba guest access)
**Complexity:** Low
**Requires Recompilation:** Yes (smb.conf)
**Risk Level:** High

## Recommended Fix

Change Samba security from `share` (guest access) to `user` mode, disable guest account access, and require authenticated connections to any shared resources.

## Changes Required

### /etc/samba/smb.conf

```conf
[global]
-   security = share
-   guest account = nobody
-   map to guest = Bad User
+   security = user
+   # PATCH-010: Guest access disabled
+   # guest account = nobody
+   map to guest = Never
+   restrict anonymous = 2

[shared]
-   path = /tmp/samba
-   guest ok = yes
-   writable = yes
-   browseable = yes
+   path = /tmp/samba
+   guest ok = no
+   writable = no
+   browseable = yes
+   valid users = @smbusers
+   write list = @smbusers
+   create mask = 0640
+   directory mask = 0750
```

### /etc/samba/smbpasswd or user database

Ensure at least one authenticated user exists:

```bash
+ # PATCH-010: Create SMB user for authenticated access
+ smbpasswd -a admin
+ # Set a strong password interactively
+ usermod -a -G smbusers admin
```

### /etc/init.d/samba startup

Add a check to ensure guest access is not re-enabled:

```bash
+ # PATCH-010: Validate samba configuration
+ if grep -q "security = share" /etc/samba/smb.conf; then
+     echo "WARNING: Samba guest access detected, patch not applied"
+ fi
```

## Verification

1. Confirm security level:
   ```bash
   testparm -s 2>/dev/null | grep security
   # Should show: security = user
   ```
2. Attempt anonymous connection and verify it fails:
   ```bash
   smbclient -L //router_ip -N
   # Should fail with access denied
   ```
3. Verify authenticated connection works:
   ```bash
   smbclient -L //router_ip -U admin
   ```

## Notes

- Users will need credentials to access SMB shares after this change.
- This may break existing automated backup scripts that rely on guest access.
- Consider providing a setup script for creating SMB users via the web interface.
