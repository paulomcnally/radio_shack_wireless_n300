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
- **Requires Recompilation:** Yes (rootfs)
- **Rollback Complexity:** Medium

---

# PATCH-007 Implementation Status

**Vulnerability:** VULN-007 - Console Shell Without Authentication
**Severity:** CRITICAL
**CWE:** CWE-306
**CVSS:** 6.8
**Issue:** #7
**PR:** #28

## Implementation Checklist

- [x] Modify inittab to use /bin/login instead of -/bin/sh
- [x] Ensure root password exists in /etc/shadow
- [ ] Test: Serial console shows login prompt
- [ ] Test: Cannot login without credentials
- [ ] Test: Root login works with password
- [ ] Test: Change persists after reboot

## Files to Modify

- `/etc/inittab` - Change respawn to use /bin/login
- `/etc/shadow` - Ensure root has valid password hash

## Risk Assessment

- **Breaking Risk:** Low
- **Requires Recompilation:** Yes (inittab)
- **Rollback Complexity:** Low

---

# PATCH-004 Implementation Status

**Vulnerability:** VULN-004 - Private Key Hardcoded in Firmware
**Severity:** CRITICAL
**CWE:** CWE-321
**CVSS:** 9.1
**Issue:** #4
**PR:** #25

## Implementation Checklist

- [x] Remove privateKey.key from firmware image
- [x] Create key generation script using openssl
- [x] Store keys in /var/etc/ssl/ with restrictive permissions
- [x] Add factory reset cleanup
- [ ] Test: Key generated at first boot
- [ ] Test: Key unique per device
- [ ] Test: Factory reset regenerates keys
- [ ] Test: SSH/HTTPS uses new device-specific key

## Files to Modify

- `/etc/privateKey.key` - Remove from firmware
- `/etc/init.d/generate_keys.sh` - New key generation script
- `/etc/init.d/rcS_32M` - Call generate_keys.sh at boot

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (rootfs)
- **Rollback Complexity:** Medium

---

# PATCH-005 Implementation Status

**Vulnerability:** VULN-005 - Passwords Rendered in Plaintext HTML
**Severity:** CRITICAL
**CWE:** CWE-200
**CVSS:** 8.6
**Issue:** #5
**PR:** #26

## Implementation Checklist

- [x] Change password fields from type="text" to type="password"
- [x] Update routermain.html (pppPassword, pptpPassword, l2tpPassword, pskValue0/1, key0/1)
- [x] Update extendermain.html (password2ghz, password5ghz, rpPassword)
- [x] Update accesspointmain.html (password2ghz, password5ghz)
- [ ] Test: All password fields display dots/bullets
- [ ] Test: Form submission still works correctly
- [ ] Test: No plaintext passwords visible in web UI

## Files to Modify

- `/www/main/routermain.html` - Password fields for PPPoP, PPTP, L2TP, WPA PSK, WEP
- `/www/main/extendermain.html` - Password fields for extender mode
- `/www/main/accesspointmain.html` - Password fields for AP mode

## Risk Assessment

- **Breaking Risk:** Low
- **Requires Recompilation:** Yes (HTML files)
- **Rollback Complexity:** Low

---

# PATCH-006 Implementation Status

**Vulnerability:** VULN-006 - Firewall Disabled
**Severity:** CRITICAL
**CWE:** CWE-284
**CVSS:** 8.1
**Issue:** #6
**PR:** #27

## Implementation Checklist

- [x] Rewrite firewall.sh with full iptables rule set
- [x] Set default DROP policies for INPUT and FORWARD
- [x] Allow loopback, established, ICMP, DHCP, DNS, HTTP from LAN
- [x] Block WAN input, add NAT masquerade
- [x] Add firewall startup to rcS_32M
- [x] Create firewall.html web interface
- [ ] Test: Firewall rules loaded at boot
- [ ] Test: WAN cannot initiate connections
- [ ] Test: LAN devices can access internet
- [ ] Test: Web interface accessible from LAN

## Files to Modify

- `/bin/firewall.sh` - Rewrite with iptables rules
- `/etc/init.d/rcS_32M` - Add firewall startup
- `/www/firewall.html` - New firewall management page

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (rootfs)
- **Rollback Complexity:** Medium

---

# PATCH-008 Implementation Status

**Vulnerability:** VULN-008 - Telnet Exposed on WAN
**Severity:** CRITICAL
**CWE:** CWE-284
**CVSS:** 9.8
**Issue:** #8
**PR:** #29

## Implementation Checklist

- [x] Remove WanTelnetEnable checkbox from internet.html
- [x] Remove JavaScript validation for WanTelnetEnable
- [x] Add iptables rule to block WAN port 23
- [ ] Test: WAN Telnet option no longer visible in web UI
- [ ] Test: Port 23 not accessible from WAN
- [ ] Test: Telnet still accessible from LAN

## Files to Modify

- `/www/internet.html` - Remove WanTelnetEnable UI elements
- `/bin/firewall.sh` - Add WAN port 23 block rule

## Risk Assessment

- **Breaking Risk:** Low
- **Requires Recompilation:** Yes (HTML + firewall)
- **Rollback Complexity:** Low
