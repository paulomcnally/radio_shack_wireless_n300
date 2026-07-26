# VULN-018: uShare Telnet Port Hidden Configuration

**Severity:** MEDIUM
**CWE:** CWE-284 (Improper Access Control)
**CVSS Estimation:** 5.3
**Component:** `/etc/ushare.conf`

## Description

The firmware includes uShare media server with a configured telnet control interface on port 1337. Although telnet is currently disabled in the configuration (`ENABLE_TELNET=no`), the port is explicitly defined and the functionality exists in the binary. This represents a hidden backdoor-like interface that could be trivially re-enabled through configuration modification or exploitation. Port 1337 ("leet") is a well-known backdoor port, suggesting this may have been intentionally designed for remote access during development.

## Evidence

**`/etc/ushare.conf`:**
```
# /etc/ushare.conf
# Configuration file for uShare

# uShare UPnP Friendly Name (default is 'uShare').
USHARE_NAME=myushare

# Interface to listen to (default is eth0).
# Ex : USHARE_IFACE=eth1
USHARE_IFACE=br0

# Port to listen to (default is random from IANA Dynamic Ports range)
# Ex : USHARE_PORT=49200
USHARE_PORT=49200

# Port to listen for Telnet connections
# Ex : USHARE_TELNET_PORT=1337
USHARE_TELNET_PORT=1337

# Directories to be shared (space or CSV list).
# Ex: USHARE_DIR=/dir1,/dir2
USHARE_DIR=/var/tmp/usb/sda6/Media

# Enable Telnet control interface (yes/no)
ENABLE_TELNET=no
```

## Impact

- **Hidden Backdoor**: Port 1337 is a well-known backdoor port; its presence suggests intentional remote access capability.
- **Configuration Tampering**: If an attacker gains write access to `/etc/ushare.conf`, they can enable telnet.
- **Privilege Escalation**: Telnet access typically provides shell access, potentially with elevated privileges.
- **Persistence Mechanism**: Telnet can be used to maintain persistent access to compromised devices.
- **Defense Evasion**: Hidden services are less likely to be detected by standard security audits.

## References

- CWE-284: https://cwe.mitre.org/data/definitions/284.html
- IANA Port Registry: Port 1337 (unassigned, commonly used for backdoors)
- Similar: CVE-2019-15120 (backdoor accounts in network devices)

## Status
- [ ] Not patched (default firmware)
