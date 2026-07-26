# Security Assessment Report

## Device Information

| Field | Value |
|-------|-------|
| **Device** | RadioShack Wireless N300M Router |
| **Model** | 2505002 |
| **Serial Number** | 2505002192600563 |
| **Chipset** | Realtek RTL8196E |
| **Firmware** | `RER4_A_v3411bN_2T2R_RAD_02_180301` |
| **SDK** | Realtek SDK v3.4.11-r38403 |
| **Kernel** | Linux 3.10.90 (MIPS) |
| **Build Date** | Thu Mar 1 14:57:44 CST 2018 |
| **Flash** | 8 MB (SquashFS 4.0, XZ) |
| **RAM** | 24 MB |
| **Web Server** | Boa 0.94.14rc21 |
| **BusyBox** | v1.13.4 |
| **Assessment Date** | July 26, 2026 |
| **Analyst** | Forensic Firmware Analysis |

---

## Executive Summary

This security assessment was performed on the RadioShack Wireless N300M router (model 2505002) firmware. The firmware was extracted via telnet root access and HTTP download methods. The analysis identified **21 security vulnerabilities** across multiple severity levels.

### Key Findings

- **8 CRITICAL vulnerabilities** that allow immediate root access or credential exposure
- **7 HIGH vulnerabilities** that enable privilege escalation or network attacks
- **6 MEDIUM vulnerabilities** that increase the attack surface

### Risk Assessment

| Severity | Count | Summary |
|----------|-------|---------|
| CRITICAL | 8 | Root compromise via default credentials, telnet, Boa as root, exposed keys, plaintext passwords, no firewall, console shell, WAN telnet |
| HIGH | 7 | WPS brute-force, Samba guest, anonymous FTP, no CSRF, SNMP plaintext, outdated Boa, expired TLS |
| MEDIUM | 6 | jQuery XSS, TR-069 remote mgmt, uShare telnet, DNSSEC, config.dat credentials, WiFi password plaintext |

### Most Dangerous Attack Chain

1. Attacker connects to LAN (WiFi or Ethernet)
2. Uses default credentials (root:password via telnet, admin via web)
3. Gains full root access with no firewall阻拦
4. Extracts all credentials from config.dat
5. Can enable WAN telnet for persistent remote access
6. Can flash custom firmware via upgrade page

---

## Vulnerability Index

| ID | Severity | Title | CWE | File |
|----|----------|-------|-----|------|
| [VULN-001](vulnerabilities/VULN-001-hardcoded-root-password.md) | CRITICAL | Hardcoded Root Password (MD5) | CWE-798 | `passwd_orig`, `shadow.sample` |
| [VULN-002](vulnerabilities/VULN-002-telnet-unconditional.md) | CRITICAL | Telnet Unconditionally Enabled | CWE-250 | `rcS_32M` |
| [VULN-003](vulnerabilities/VULN-003-boa-runs-as-root.md) | CRITICAL | Boa Web Server Runs as Root | CWE-250 | `boa.conf` |
| [VULN-004](vulnerabilities/VULN-004-private-key-in-firmware.md) | CRITICAL | Private Key Embedded in Firmware | CWE-321 | `privateKey.key` |
| [VULN-005](vulnerabilities/VULN-005-passwords-plaintext-html.md) | CRITICAL | Passwords in Plaintext in HTML | CWE-200 | `routermain.html`, `wlwps.html` |
| [VULN-006](vulnerabilities/VULN-006-firewall-disabled.md) | CRITICAL | Firewall Disabled by Default | CWE-284 | `firewall.sh` |
| [VULN-007](vulnerabilities/VULN-007-console-shell-no-auth.md) | CRITICAL | Console Shell Without Authentication | CWE-306 | `inittab` |
| [VULN-008](vulnerabilities/VULN-008-telnet-wan-exposed.md) | CRITICAL | Telnet Exposed on WAN | CWE-284 | `internet.html` |
| [VULN-009](vulnerabilities/VULN-009-wps-brute-force.md) | HIGH | WPS PIN Brute-Force Vulnerable | CWE-307 | `wscd.conf` |
| [VULN-010](vulnerabilities/VULN-010-samba-guest-access.md) | HIGH | Samba Guest Access with Write | CWE-284 | `smb.conf` |
| [VULN-011](vulnerabilities/VULN-011-vsftpd-anonymous-upload.md) | HIGH | vsftpd Anonymous Upload Enabled | CWE-284 | `vsftpd.conf` |
| [VULN-012](vulnerabilities/VULN-012-no-csrf-protection.md) | HIGH | No CSRF Protection on Forms | CWE-352 | All HTML forms |
| [VULN-013](vulnerabilities/VULN-013-snmp-plaintext.md) | HIGH | SNMP Community Strings in Plaintext | CWE-200 | `snmpd.sh`, `snmp.html` |
| [VULN-014](vulnerabilities/VULN-014-boa-outdated.md) | HIGH | Boa v0.94 Outdated and Unpatched | CWE-1104 | `boa` binary |
| [VULN-015](vulnerabilities/VULN-015-tls-cert-expired.md) | HIGH | TLS Certificate Expired and Hardcoded | CWE-295 | `certificate.crt`, `privateKey.key` |
| [VULN-016](vulnerabilities/VULN-016-jquery-xss.md) | MEDIUM | jQuery 1.x XSS Vulnerabilities | CWE-79 | `jquery-1.2.1.min.js` |
| [VULN-017](vulnerabilities/VULN-017-tr069-remote-mgmt.md) | MEDIUM | TR-069 Remote Management Enabled | CWE-284 | `cwmpClient`, `tr069.html` |
| [VULN-018](vulnerabilities/VULN-018-ushare-telnet-port.md) | MEDIUM | uShare Telnet Port 1337 Defined | CWE-284 | `ushare.conf` |
| [VULN-019](vulnerabilities/VULN-019-dnsmasq-no-dnssec.md) | MEDIUM | dnsmasq Without DNSSEC | CWE-350 | `dnsmasq.conf` |
| [VULN-020](vulnerabilities/VULN-020-config-dat-credentials.md) | CRITICAL | config.dat Accessible via HTTP with Credentials | CWE-200 | `config.dat` symlink |
| [VULN-021](vulnerabilities/VULN-021-wifi-password-plaintext.md) | HIGH | WiFi Password in Plaintext in Config | CWE-312 | `config.dat` |

---

## Patch Priority

### Immediate (CRITICAL - Patch within 24 hours)

1. **VULN-001**: Change default root password hash to SHA-512
2. **VULN-002**: Make telnet opt-in, not default
3. **VULN-003**: Run Boa as nobody:nogroup
4. **VULN-004**: Generate unique keypair per device
5. **VULN-005**: Use type="password" for all credential fields
6. **VULN-006**: Enable basic iptables rules
7. **VULN-007**: Require login on console
8. **VULN-008**: Disable WAN telnet by default

### Short-term (HIGH - Patch within 1 week)

9. **VULN-009**: Disable WPS or implement lockout
10. **VULN-010**: Require authentication for Samba
11. **VULN-011**: Disable anonymous FTP upload
12. **VULN-012**: Add CSRF tokens to forms
13. **VULN-013**: Use SNMPv3 or disable by default
14. **VULN-014**: Update or replace Boa
15. **VULN-015**: Generate unique cert per device

### Medium-term (MEDIUM - Patch within 1 month)

16. **VULN-016**: Update jQuery to 3.x
17. **VULN-017**: Disable TR-069 if not needed
18. **VULN-018**: Remove or disable uShare telnet
19. **VULN-019**: Enable DNSSEC in dnsmasq
20. **VULN-020**: Restrict config.dat access
21. **VULN-021**: Encrypt WiFi password in config

---

## Methodology

1. **Firmware Extraction**: Extracted via telnet root shell (root:password) and HTTP config.dat download
2. **Static Analysis**: Analyzed SquashFS rootfs, binary strings, configuration files
3. **Web Interface Analysis**: Reviewed all HTML/JS/CSS for credential exposure and CSRF
4. **Service Enumeration**: Identified all running services from init scripts and binaries
5. **Configuration Review**: Analyzed Boa, Samba, vsftpd, dnsmasq, and SNMP configurations

## Disclaimer

This assessment is for educational and research purposes only. The vulnerabilities identified are inherent to the firmware version analyzed. Always follow responsible disclosure practices.
