# VULN-002: Unconditional Telnet Daemon at Boot

**Severity:** CRITICAL
**CWE:** CWE-250 (Execution with Unnecessary Privileges) / CWE-319 (Cleartext Transmission of Sensitive Information)
**CVSS Estimation:** 9.8
**Component:** `/etc/init.d/rcS_32M`

## Description

The boot script `rcS_32M` starts the Telnet daemon (`telnetd`) unconditionally on every boot with no access controls, no authentication requirement, and no conditional logic. Telnet transmits all credentials and session data in cleartext, making it trivially interceptable via network sniffing. Combined with the hardcoded root password (VULN-001), this provides an unauthenticated remote root shell to any attacker on the network.

## Evidence

**`/etc/init.d/rcS_32M` (line 115):**
```bash
# start web server
boa

#jeff01
telnetd&
```

The `telnetd&` command is the final line of the boot script. It launches the telnet daemon in the background with no flags, no access restrictions, and no conditional checks. There is no firewall rule preventing external access (VULN-006).

## Impact

- Any attacker with network access to the router can connect via Telnet (port 23).
- Telnet transmits credentials in cleartext; local network attackers can sniff the root password.
- Combined with VULN-001 (hardcoded password), this yields immediate remote root access.
- No authentication is required beyond the known default password.
- Even if the user changes the web admin password, the telnet root password may remain unchanged.

## References

- CWE-319: https://cwe.mitre.org/data/definitions/319.html
- CWE-250: https://cwe.mitre.org/data/definitions/250.html
- RFC 854 (Telnet Protocol) - deprecated for security purposes
- Similar: Multiple IoT devices with unconditional telnet (CVE-2019-16920)

## Status
- [ ] Not patched (default firmware)
