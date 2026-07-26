# PATCH-020 Implementation Status

**Vulnerability:** VULN-020 - config.dat Accessible via HTTP
**Severity:** CRITICAL (listed as MEDIUM in assessment)
**CWE:** CWE-200
**Issue:** #20

## Implementation Checklist

- [ ] Remove /www/config.dat symlink
- [ ] Block direct access in httpd.conf
- [ ] Sanitize CGI output (mask passwords)
- [ ] Set restrictive permissions on config.dat
- [ ] Test: Direct access returns 403
- [ ] Test: CGI output masks passwords
- [ ] Test: Config file permissions are 600

## Files to Modify

- `/www/config.dat` - Remove symlink
- HTTP server config - Block access to config.dat
- CGI scripts - Sanitize output

## Risk Assessment

- **Breaking Risk:** High
- **Requires Recompilation:** Yes
- **Rollback Complexity:** Medium
