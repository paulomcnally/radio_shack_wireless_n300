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
**Issue:** #3

## Implementation Checklist

- [x] Change boa.conf: User nobody, Group nogroup
- [x] Add SuexecOwner/SuexecGroup for CGI
- [x] Update init script: chown directories for nobody
- [ ] Test: Boa process runs as nobody
- [ ] Test: Web UI pages load correctly
- [ ] Test: CGI functionality works
- [ ] Test: Log files created with correct ownership

## Files to Modify

- `/etc/boa/boa.conf` - Change User/Group to nobody/nogroup
- `/etc/init.d/rcS_32M` - Add chown commands before boa startup

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (boa.conf + binary)
- **Rollback Complexity:** Medium
