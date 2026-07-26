# PATCH-015 Implementation Status

**Vulnerability:** VULN-015 - TLS Certificate Expired
**Severity:** HIGH
**CWE:** CWE-295
**Issue:** #15

## Implementation Checklist

- [ ] Remove expired certificate from firmware
- [ ] Add certificate generation at first boot
- [ ] Use device MAC for unique CN
- [ ] Generate 2048-bit RSA key
- [ ] Set 10-year validity
- [ ] Test: Unique cert per device
- [ ] Test: Cert matches key
- [ ] Test: No security warnings in browser

## Files to Modify

- `/etc/certificate.crt` - Remove from firmware
- `/etc/init.d/rcS` - Add cert generation at boot

## Risk Assessment

- **Breaking Risk:** High
- **Requires Recompilation:** Yes
- **Rollback Complexity:** High
