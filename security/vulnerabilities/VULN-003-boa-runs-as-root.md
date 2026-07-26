# VULN-003: Boa Web Server Runs as Root

**Severity:** CRITICAL
**CWE:** CWE-250 (Execution with Unnecessary Privileges)
**CVSS Estimation:** 9.1
**Component:** `/etc/boa/boa.conf`

## Description

The Boa web server is configured to run as `root:root` instead of dropping privileges to a non-privileged user (e.g., `nobody:nogroup`). The default safe configuration (`User nobody` / `Group nogroup`) is commented out. This means any vulnerability in the web server process—buffer overflow, command injection in CGI scripts, path traversal, or authentication bypass—immediately yields full root access to the device with no further privilege escalation required.

## Evidence

**`/etc/boa/boa.conf` (lines 48-51):**
```
#User nobody
#Group nogroup
User root
Group root
```

The commented-out safe defaults (`User nobody` / `Group nogroup`) are overridden with `User root` and `Group root`. The Boa process inherits full root privileges.

Additionally, the web server listens on port 80 with no HTTPS by default (line 25):
```
Port 80
```

## Impact

- Any vulnerability in Boa or its CGI scripts provides immediate root access.
- CGI scripts in `/web/cgi-bin/` execute with root privileges.
- Attackers can read/write any file on the filesystem, install persistent backdoors, or modify firmware.
- The web interface also handles sensitive operations (WAN config, wireless settings, VPN credentials) all under the root process.
- Combined with cleartext password exposure (VULN-005), the attack surface is maximized.

## References

- CWE-250: https://cwe.mitre.org/data/definitions/250.html
- Boa HTTP Server security documentation recommends running as non-privileged user
- Similar: CVE-2022-3034 (Netgear web server privilege issues)

## Status
- [ ] Not patched (default firmware)
