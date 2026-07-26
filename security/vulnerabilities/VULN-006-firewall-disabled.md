# VULN-006: Firewall Effectively Disabled by Default

**Severity:** CRITICAL
**CWE:** CWE-284 (Improper Access Control)
**CVSS Estimation:** 8.1
**Component:** `/bin/firewall.sh`

## Description

The firewall script `firewall.sh` is a thin wrapper that delegates entirely to `sysconf firewall`, with no visible iptables rules, no default deny policy, and no explicit filtering configuration. The script contains no rule definitions, no chain creation, and no packet filtering logic. This means the device ships with effectively no firewall, leaving all services (telnet, HTTP, SSH if present) accessible from the WAN interface and the local network without any access control.

## Evidence

**`/bin/firewall.sh`:**
```bash
#!/bin/sh

sysconf firewall $*
```

The entire firewall script is 3 lines: a shebang, a single `sysconf` call, and a passthrough of arguments. There are no `iptables` commands, no `DROP` rules, no `ACCEPT` rules, no NAT rules, and no default policy statements. The `sysconf` binary's behavior is opaque and may not implement any meaningful filtering.

Additionally, the boot script (`rcS_32M`) configures conntrack parameters but does not invoke any firewall rules (lines 97-106):
```bash
echo "4096" > /proc/sys/net/netfilter/nf_conntrack_max
echo "600" > /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established
```

## Impact

- All services (telnet port 23, HTTP port 80) are accessible from the WAN/Internet.
- No ingress or egress filtering protects the device or the local network.
- Attackers from the Internet can directly exploit VULN-001, VULN-002, VULN-003, and VULN-005.
- The device can be used as a pivot point into the local network.
- UPnP and other services may be exposed without restriction.

## References

- CWE-284: https://cwe.mitre.org/data/definitions/284.html
- OWASP: Missing Function-level Access Control
- Similar: CVE-2021-20038 (SonicWall firewall bypass)

## Status
- [ ] Not patched (default firmware)
