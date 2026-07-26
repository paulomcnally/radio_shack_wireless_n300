# PATCH-021 Implementation Status

**Vulnerability:** VULN-021 - WiFi Password in Plaintext
**Severity:** HIGH
**CWE:** CWE-312
**Issue:** #21

## Implementation Checklist

- [ ] Encrypt WiFi password in config.dat
- [ ] Add decryption at runtime for hostapd
- [ ] Mask password in web UI (type="password")
- [ ] Encrypt on save in CGI handler
- [ ] Test: config.dat shows encrypted password
- [ ] Test: WiFi still connects after changes
- [ ] Test: Web UI masks password field

## Files to Modify

- `/etc/config.dat` - Store encrypted password
- `/etc/init.d/S40network` - Decrypt at runtime
- `/www/wifi.html` - Mask password field
- CGI handler - Encrypt on save

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes
- **Rollback Complexity:** Medium
