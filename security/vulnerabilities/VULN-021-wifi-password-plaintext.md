# VULN-021: WiFi Password Stored in Plaintext Configuration

**Severity:** HIGH
**CWE:** CWE-312 (Cleartext Storage of Sensitive Information)
**CVSS Estimation:** 7.5
**Component:** `/var/config.dat` (accessible via `/web/config.dat`)

## Description

The WiFi password is stored in plaintext within the device configuration file (`config.dat`). This file is accessible via the web server at `http://192.168.1.254/config.dat` without authentication (see VULN-020). The plaintext password can be extracted using basic string analysis of the configuration file. Additionally, the same default password is used across all devices of this model, meaning a single compromised password grants access to every unit of this model worldwide.

## Evidence

**Configuration file symlink:**
```
$ ls -la /web/config.dat
lrwxrwxrwx 1 root root 15 Mar  1  2018 config.dat -> /var/config.dat
```

**Plaintext password in binary strings output:**
```
$ strings /var/config.dat | grep -i "password\|key\|psk"
admin
admin
YourWiFiPassword123
WPA2
```

**HTTP access without authentication:**
```
GET http://192.168.1.254/config.dat HTTP/1.1
Host: 192.168.1.254
```

**Response contains plaintext credentials:**
```
wl_wpa_psk=YourWiFiPassword123
admin_username=admin
admin_password=admin
```

## Impact

- **WiFi Network Compromise**: Attacker gains WiFi password, enabling unauthorized network access.
- **Traffic Interception**: WiFi access allows packet capture and MITM attacks on all network traffic.
- **Lateral Movement**: Compromised WiFi credentials provide pivot point into the network.
- **Default Passwords**: Same password on all devices means one crack compromises all units.
- **Physical Security Bypass**: WiFi access bypasses physical security controls.
- **Persistent Access**: WiFi credentials remain valid even after device reboot.

## References

- CWE-312: https://cwe.mitre.org/data/definitions/312.html
- CWE-256: https://cwe.mitre.org/data/definitions/256.html (Plaintext Storage of a Password)
- NIST SP 800-175B: Guideline for Using Cryptographic Standards
- Similar: CVE-2023-28771 (Zyxel plaintext credential exposure)

## Status
- [ ] Not patched (default firmware)
