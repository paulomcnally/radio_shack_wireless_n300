# VULN-019: dnsmasq DNS Resolution Without DNSSEC

**Severity:** MEDIUM
**CWE:** CWE-350 (Improper Validation of a Cryptographically Verifiable Value)
**CVSS Estimation:** 5.3
**Component:** `/etc/dnsmasq.conf`, `/bin/dnsmasq`

## Description

The firmware's dnsmasq DNS resolver is configured without DNSSEC (DNS Security Extensions) support. This means DNS responses are not cryptographically validated, making the router vulnerable to DNS spoofing and cache poisoning attacks. Additionally, dnsmasq is configured to listen on all interfaces without explicit binding, expanding the attack surface. Without DNSSEC validation, an attacker can inject malicious DNS responses to redirect users to phishing sites or malware servers.

## Evidence

**`/etc/dnsmasq.conf`:**
```
# Configuration file for dnsmasq.
#
# Format is one option per line, legal options are the same
# as the long options legal on the command line. See
# "/usr/sbin/dnsmasq --help" or "man 8 dnsmasq" for details.

# Never forward plain names (without a dot or domain part)
domain-needed
# Never forward addresses in the non-routed address spaces.
bogus-priv

# Change this line if you want dns to get its upstream servers from
# somewhere other that /etc/resolv.conf
resolv-file=/etc/resolv.conf

# If you want dnsmasq to listen for DHCP and DNS requests only on
# specified interfaces (and the loopback) give the name of the
# interface (eg eth0) here.
# Repeat the line for more than one interface.
#interface=
# Or you can specify which interface _not_ to listen on
#except-interface=
# Or which to listen on by address (remember to include 127.0.0.1 if
# you use this.)
#listen-address=
```

**Missing DNSSEC configuration:**
- No `dnssec` directive present
- No `dnssec-check-unsigned` directive
- No `trust-anchor` configuration
- No `dnssec-time-stamp` configuration

**Listening on all interfaces:**
- `#interface=` is commented out (default: all interfaces)
- `#except-interface=` is commented out
- `#listen-address=` is commented out

## Impact

- **DNS Spoofing**: Attackers on the same network can inject false DNS responses.
- **Cache Poisoning**: Malicious DNS entries can be injected into the resolver cache.
- **Phishing**: Users can be redirected to fake login pages for banks, email, etc.
- **Malware Distribution**: Software update checks can be redirected to malicious servers.
- **MITM Attacks**: DNS spoofing enables man-in-the-middle attacks on encrypted connections.

## References

- CWE-350: https://cwe.mitre.org/data/definitions/350.html
- RFC 4033: DNS Security Introduction and Requirements
- RFC 4034: Resource Records for the DNS Security Extensions
- Similar: CVE-2008-1447 (DNS cache poisoning - Kaminsky attack)

## Status
- [ ] Not patched (default firmware)
