# PATCH-004 Implementation Status

**Vulnerability:** VULN-004 - RSA Private Key Embedded in Firmware
**Severity:** CRITICAL
**CWE:** CWE-321
**Issue:** #4

## Implementation Checklist

- [ ] Remove hardcoded privateKey.key from firmware
- [ ] Add key generation script in init.d
- [ ] Generate unique RSA keypair at first boot
- [ ] Store keys in /var/etc/ssl/
- [ ] Set restrictive permissions (600/644)
- [ ] Add factory reset key cleanup
- [ ] Test: Keys generated at first boot
- [ ] Test: Keys unique across devices
- [ ] Test: Factory reset regenerates keys

## Files to Modify

- `/etc/privateKey.key` - Remove from firmware
- `/etc/init.d/rcS_32M` - Add key generation
- `/etc/init.d/factory_reset` - Add key cleanup

## Risk Assessment

- **Breaking Risk:** Medium
- **Requires Recompilation:** Yes (key generation)
- **Rollback Complexity:** Medium
