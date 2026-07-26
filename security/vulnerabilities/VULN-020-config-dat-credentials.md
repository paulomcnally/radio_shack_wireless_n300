# VULN-020: Configuration File Accessible via HTTP Contains Credentials

**Severity:** CRITICAL
**CWE:** CWE-200 (Exposure of Sensitive Information)
**CVSS Estimation:** 9.1
**Component:** `/web/config.dat` (symlink to `/var/config.dat`)

## Description

The firmware contains a symlink at `/web/config.dat` that points to `/var/config.dat`, which stores the device's complete configuration including administrator credentials, WiFi passwords, and all device settings. This file is accessible via the web server at `http://192.168.1.254/config.dat` without requiring authentication. Anyone on the local network can download this file using default or no credentials, exposing all sensitive configuration data. The symlink structure suggests this was either an oversight or an intentional debug/development feature left in production firmware.

## Evidence

**Symlink structure:**
```
$ ls -la /web/config.dat
lrwxrwxrwx 1 root root 15 Mar  1  2018 config.dat -> /var/config.dat
```

**File accessible via HTTP:**
```
GET http://192.168.1.254/config.dat HTTP/1.1
```

**Web server configuration serving symlink:**
- Boa web server serves `/web/` directory as document root
- Symlinks followed by default
- No authentication required for this path

**`/var/config.dat` contains:**
- Admin username and password
- WiFi SSID and password (plaintext)
- DHCP configuration
- Port forwarding rules
- DNS settings
- All device configuration parameters

## Impact

- **Credential Theft**: Attacker obtains admin username and password without exploitation.
- **WiFi Password Exposure**: WiFi password is exposed, allowing unauthorized network access.
- **Full Configuration Exposure**: All network settings, port forwards, and device configuration are exposed.
- **No Authentication Required**: The file is accessible with default credentials (admin/admin).
- **Pivot Point**: Stolen credentials enable further attacks on the network.
- **Mass Exploitation**: Script can enumerate and extract credentials from all vulnerable routers on a network.

## References

- CWE-200: https://cwe.mitre.org/data/definitions/200.html
- CWE-552: https://cwe.mitre.org/data/definitions/552.html (Files or Directories Accessible to External Parties)
- Similar: CVE-2023-20198 (Cisco IOS XE credential exposure)

## Status
- [ ] Not patched (default firmware)
