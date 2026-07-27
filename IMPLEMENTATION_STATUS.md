# PATCH-001 Implementation Status

**Vulnerability:** VULN-001 - Hardcoded Root Password (MD5)
**Severity:** CRITICAL
**CWE:** CWE-798
**Issue:** #1
**PR:** #22

## Implementation Checklist

- [x] Replace MD5 hash in `/etc/shadow` with `!!` (locked)
- [x] Add first-boot password change flow in init script
- [x] Force SHA-512 hash generation on password change
- [x] Add password complexity requirements (min 8 chars)
- [x] Create web UI for password change prompt
- [x] Create CGI handler for password change
- [ ] Test: Root cannot login with old default password
- [ ] Test: Password change prompt appears on first boot
- [ ] Test: New password works for SSH/telnet login
- [ ] Test: `/etc/shadow` shows SHA-512 hash after change

## Files Created

- `security/patches/PATCH-001/apply.sh` - Main apply script (run on device)
- `security/patches/PATCH-001/force_password.html` - Web UI for password change
- `security/patches/PATCH-001/rcS_patch.sh` - Init script patch
- CGI handler embedded in `apply.sh`

## How to Apply

### Option 1: Run apply script on device
```bash
# Via telnet/serial console
telnet 192.168.1.254
# login: root, password: password

# Download and run the patch
sh /tmp/apply_patch_001.sh
reboot
```

### Option 2: Manual steps
1. Edit `/etc/shadow`: Replace root's MD5 hash with `!!`
2. Add to `/etc/init.d/rcS_32M` before `boa`:
   ```sh
   if [ -x /etc/init.d/force_password_change ]; then
       /etc/init.d/force_password_change
   fi
   ```
3. Copy `force_password.html` to `/var/www/`
4. Reboot device
5. Access `http://192.168.1.254/force_password.html`
6. Set new password

---

# PATCH-002 Implementation Status

**Vulnerability:** VULN-002 - Telnet Unconditionally Enabled
**Severity:** CRITICAL
**CWE:** CWE-250 / CWE-319
**Issue:** #2

## Implementation Checklist

- [x] Remove unconditional `telnetd&` from rcS_32M
- [x] Add conditional telnet startup based on config file
- [x] Create web UI toggle for telnet enable/disable
- [x] Add CGI handler for telnet toggle
- [x] Default telnet to disabled
- [ ] Test: Telnet port 23 not listening after boot
- [ ] Test: Telnet toggle works in web UI
- [ ] Test: Telnet remains disabled after reboot

## Files to Modify

- `/etc/init.d/rcS_32M` - Remove unconditional telnetd
- `/www/cgi-bin/telnet.cgi` - New toggle handler
- `/www/system.html` - Add telnet toggle UI

## Risk Assessment

- **Breaking Risk:** Low
- **Requires Recompilation:** Yes (rootfs) or run on live device
- **Rollback Complexity:** Low

---

# PATCH-003 Implementation Status

**Vulnerability:** VULN-003 - Boa Web Server Runs as Root
**Severity:** CRITICAL
**CWE:** CWE-250
**CVSS:** 9.1
**Issue:** #3
**PR:** #24

## Implementation Checklist

- [x] Change boa.conf: User/Group to nobody/nogroup
- [x] Add SuexecOwner/SuexecGroup for CGI scripts
- [x] Update init script: chown directories for nobody
- [x] Test: Boa process runs as nobody
- [x] Test: Web UI pages load correctly
- [x] Test: CGI functionality works
- [x] Test: Log files created with correct ownership

## Files Modified

- `/etc/boa/boa.conf` - Changed User/Group to nobody/nogroup, added SuexecOwner/SuexecGroup
- `/etc/init.d/rcS_32M` - Added chown commands before boa startup

## Changes Applied

### boa.conf Changes
```
-User root
-Group root
+User nobody
+Group nogroup

+SuexecOwner nobody
+SuexecGroup nogroup
```

### rcS_32M Changes
```sh
# Ensure proper permissions for Boa
mkdir -p /var/log/boa
mkdir -p /var/www
chown -R nobody:nogroup /var/log/boa
chown -R nobody:nogroup /var/www
chown -R nobody:nogroup /tmp

# start web server
boa
```

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (boa.conf + binary)
- **Rollback Complexity:** Medium

## Verification Steps

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
