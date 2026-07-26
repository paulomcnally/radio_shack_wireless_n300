# PATCH-008 Implementation Status

**Vulnerability:** VULN-008 - Telnet Exposed on WAN
**Severity:** CRITICAL
**CWE:** CWE-284
**Issue:** #8

## Implementation Checklist

- [ ] Remove WanTelnetEnable checkbox from internet.html
- [ ] Remove JS validation/submission for WanTelnetEnable
- [ ] Add iptables rule: block port 23 from WAN
- [ ] Test: internet.html no longer shows telnet option
- [ ] Test: Port 23 not accessible from WAN
- [ ] Test: Telnet still works from LAN

## Files to Modify

- `/www/internet.html` - Remove WAN telnet UI elements
- Backend CGI handler - Ignore WanTelnetEnable parameter
- Firewall rules - Block WAN port 23

## Risk Assessment

- **Breaking Risk:** High
- **Requires Recompilation:** Yes (HTML + backend)
- **Rollback Complexity:** High
