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

---

# PATCH-009 Implementation Status

**Vulnerability:** VULN-009 - WPS Brute-Force
**Severity:** HIGH
**CWE:** CWE-307
**CVSS:** 7.5
**Issue:** #9
**PR:** #30

## Implementation Checklist

- [x] Disable WPS by default in wscd.conf
- [x] Add lockout parameters (max 3 attempts, 10 min cooldown)
- [ ] Test: WPS is disabled after reflash
- [ ] Test: Lockout triggers after 3 failed PIN attempts
- [ ] Test: Lockout persists for 10 minutes

## Files to Modify

- `/etc/wscd.conf` - Disable WPS, add lockout params

## Risk Assessment

- **Breaking Risk:** Low
- **Requires Recompilation:** Yes (wscd.conf)
- **Rollback Complexity:** Low

---

# PATCH-010 Implementation Status

**Vulnerability:** VULN-010 - Samba Guest Access
**Severity:** HIGH
**CWE:** CWE-284
**CVSS:** 7.5
**Issue:** #10
**PR:** #31

## Implementation Checklist

- [x] Change smb.conf security from share to user
- [x] Disable guest account, set map to guest = Never
- [x] Restrict anonymous access
- [x] Add validation script to rcS_32M
- [ ] Test: Anonymous SMB connection fails
- [ ] Test: Authenticated connection works

## Files to Modify

- `/etc/samba/smb.conf` - Change security mode, disable guest
- `/etc/init.d/rcS_32M` - Add validation check

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (firmware)
- **Rollback Complexity:** Low

---

# PATCH-017 Implementation Status

**Vulnerability:** VULN-017 - TR-069 Remote Management Enabled by Default
**Severity:** MEDIUM
**CWE:** CWE-284
**CVSS:** 5.3
**Issue:** #17
**PR:** #38

## Implementation Checklist

- [x] Add enable check in rcS_32M for TR-069
- [x] TR-069 disabled by default (requires opt-in via web UI)
- [x] Existing tr069.html already has toggle for enable/disable
- [ ] Test: TR-069 disabled by default on boot
- [ ] Test: TR-069 can be enabled via web UI

## Files to Modify

- `/etc/init.d/rcS_32M` - Added enable check for TR-069

## Risk Assessment

- **Breaking Risk:** Low
- **Requires Recompilation:** Yes (rcS_32M)
- **Rollback Complexity:** Low

---

# PATCH-011 Implementation Status

**Vulnerability:** VULN-011 - vsftpd Anonymous Upload
**Severity:** HIGH
**CWE:** CWE-284
**CVSS:** 7.5
**Issue:** #11
**PR:** #32

## Implementation Checklist

- [x] Disable anonymous access in vsftpd.conf
- [x] Disable write permissions for anonymous users
- [x] Enable local user authentication
- [x] Add chroot_local_user=YES for jail
- [x] Add validation script to rcS_32M
- [ ] Test: Anonymous FTP connection fails
- [ ] Test: Local user authentication works
- [ ] Test: Write permissions restricted

## Files to Modify

- `/etc/vsftpd.conf` - Disable anonymous, enable local auth
- `/etc/init.d/rcS_32M` - Add validation check

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (firmware)
- **Rollback Complexity:** Low

---

# PATCH-017 Implementation Status

**Vulnerability:** VULN-017 - TR-069 Remote Management Enabled by Default
**Severity:** MEDIUM
**CWE:** CWE-284
**CVSS:** 5.3
**Issue:** #17
**PR:** #38

## Implementation Checklist

- [x] Add enable check in rcS_32M for TR-069
- [x] TR-069 disabled by default (requires opt-in via web UI)
- [x] Existing tr069.html already has toggle for enable/disable
- [ ] Test: TR-069 disabled by default on boot
- [ ] Test: TR-069 can be enabled via web UI

## Files to Modify

- `/etc/init.d/rcS_32M` - Added enable check for TR-069

## Risk Assessment

- **Breaking Risk:** Low
- **Requires Recompilation:** Yes (rcS_32M)
- **Rollback Complexity:** Low

---

# PATCH-018 Implementation Status

**Vulnerability:** VULN-018 - uShare Telnet Control Port Exposed
**Severity:** MEDIUM
**CWE:** CWE-284
**CVSS:** 5.3
**Issue:** #18
**PR:** #39

## Implementation Checklist

- [x] Set USHARE_TELNET_PORT=0 in ushare.conf
- [ ] Test: Telnet port 1337 not listening
- [ ] Test: uShare web UI (port 49200) still works

## Files to Modify

- `/etc/ushare.conf` - Set USHARE_TELNET_PORT=0

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (firmware)
- **Rollback Complexity:** Low

---

# PATCH-019 Implementation Status

**Vulnerability:** VULN-019 - dnsmasq No DNSSEC
**Severity:** MEDIUM
**CWE:** CWE-350
**CVSS:** 5.3
**Issue:** #19
**PR:** #40

## Implementation Checklist

- [x] Cross-compile dnsmasq 2.90 with DNSSEC support (nettle + gmp)
- [x] Replace dnsmasq binary in firmware
- [x] Enable dnssec=trust-anchor in dnsmasq.conf
- [x] Add dnssec-check-unsigned directive
- [x] Bind to specific interfaces with bind-interfaces
- [x] Create /etc/dnsmasq.d/root.key trust anchor
- [ ] Test: DNSSEC validation works
- [ ] Test: DNS resolution still functions

## Files to Modify

- `/bin/dnsmasq` - Replaced with dnsmasq 2.90 compiled with DNSSEC
- `/etc/dnsmasq.conf` - Added DNSSEC + bind-interfaces
- `/etc/dnsmasq.d/root.key` - New DNSSEC trust anchor

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (firmware)
- **Rollback Complexity:** Low

---

# PATCH-012 Implementation Status

**Vulnerability:** VULN-012 - No CSRF Protection
**Severity:** HIGH
**CWE:** CWE-352
**CVSS:** 8.0
**Issue:** #12
**PR:** #33

## Implementation Checklist

- [x] Create CSRF token generator CGI (csrf.cgi)
- [x] Create CSRF validation CGI (csrf-check.cgi)
- [x] Add CSRF JavaScript to all HTML forms (csrf.js)
- [x] Update lighttpd.conf to validate POST /boafrm/* tokens
- [ ] Test: CSRF token generated on page load
- [ ] Test: Token injected into all forms
- [ ] Test: POST without token returns 403
- [ ] Test: POST with mismatched token returns 403
- [ ] Test: POST with valid token succeeds

## Files to Create/Modify

- `/web/cgi-bin/csrf.cgi` - Token generator and validator
- `/web/cgi-bin/csrf-check.cgi` - POST validation endpoint
- `/web/csrf.js` - JavaScript token injection
- `/etc/lighttpd/lighttpd.conf` - Rewrite rules for CSRF
- `/web/*.html` - Add csrf.js script tag

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** No (CGI + JS only)
- **Rollback Complexity:** Low

---

# PATCH-013 Implementation Status

**Vulnerability:** VULN-013 - SNMP Plaintext Community Strings
**Severity:** HIGH
**CWE:** CWE-200
**CVSS:** 7.5
**Issue:** #13
**PR:** #34

## Implementation Checklist

- [x] Generate random community strings on first boot
- [x] Restrict SNMP access to localhost via iptables
- [x] Mask community string fields in web UI (type=password)
- [x] Add community initialization flag file
- [ ] Test: SNMP not accessible from WAN
- [ ] Test: Community strings are random, not defaults
- [ ] Test: Web UI shows password fields

## Files to Modify

- `/bin/snmpd.sh` - Generate random strings, restrict to localhost
- `/web/snmp.html` - Mask community string inputs

## Risk Assessment

- **Breaking Risk:** Low
- **Requires Recompilation:** Yes (snmpd.sh + snmp.html)
- **Rollback Complexity:** Low

---

# PATCH-014 Implementation Status

**Vulnerability:** VULN-014 - Outdated Boa Web Server
**Severity:** HIGH
**CWE:** CWE-1104
**CVSS:** 7.5
**Issue:** #14
**PR:** #35

## Implementation Checklist

- [x] Create lighttpd configuration file
- [x] Update rcS_32M startup script
- [x] Create migration script
- [x] Cross-compile lighttpd for MIPS
- [x] Install lighttpd binary
- [ ] Test: lighttpd starts correctly
- [ ] Test: CGI scripts work
- [ ] Test: Security headers present

## Files to Modify

- `/etc/lighttpd/lighttpd.conf` - New lighttpd config
- `/etc/init.d/rcS_32M` - Use lighttpd instead of Boa
- `/etc/lighttpd/migrate.sh` - Migration script

## Risk Assessment

- **Breaking Risk:** High
- **Requires Recompilation:** Yes (lighttpd binary)
- **Rollback Complexity:** Medium (restore Boa binary)

---

# PATCH-015 Implementation Status

**Vulnerability:** VULN-015 - Expired TLS Certificate Hardcoded
**Severity:** HIGH
**CWE:** CWE-295
**CVSS:** 7.5
**Issue:** #15
**PR:** #36

## Implementation Checklist

- [x] Remove expired certificate from firmware
- [x] Add cert generation script to rcS_32M (first boot)
- [x] Use device MAC for unique CN
- [x] 10-year validity, 2048-bit RSA
- [x] Restrict key permissions (chmod 600)
- [ ] Test: Cert generated on first boot
- [ ] Test: Cert is unique per device

## Files to Modify

- `/etc/certificate.crt` - Removed (expired cert)
- `/etc/init.d/rcS_32M` - Added cert generation script

## Risk Assessment

- **Breaking Risk:** Low
- **Requires Recompilation:** Yes (rcS_32M)
- **Rollback Complexity:** Low

---

# PATCH-016 Implementation Status

**Vulnerability:** VULN-016 - jQuery XSS Vulnerabilities
**Severity:** MEDIUM
**CWE:** CWE-79
**CVSS:** 6.1
**Issue:** #16
**PR:** #37

## Implementation Checklist

- [x] Replace jQuery 1.11.1 with 3.7.1
- [x] Update all HTML references from old jQuery versions to jquery.min.js
- [ ] Test: All web UI pages load correctly
- [ ] Test: AJAX forms still work

## Files to Modify

- `/web/js/jquery.min.js` - Updated to jQuery 3.7.1
- `/web/*.html` - Updated jQuery references

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (firmware)
- **Rollback Complexity:** Low
