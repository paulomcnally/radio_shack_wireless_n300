# VULN-009: WPS PIN Brute-Force Vulnerability

**Severity:** HIGH
**CWE:** CWE-307 (Improper Restriction of Excessive Authentication Attempts)
**CVSS Estimation:** 7.5
**Component:** Wi-Fi Protected Setup daemon (`etc/wscd.conf`)

## Description

Wi-Fi Protected Setup (WPS) is enabled by default in the firmware configuration. The `wscd.conf` file shows WPS is fully configured with `use_ie = 1`, `config_method = 0x2788` (supporting PIN and PBC methods), and `search_external_registrar = 0`. The `MaxPinFailThresHold` parameter is commented out (defaulting to 10), but enforcement of lockout may be incomplete or absent in the Realtek WPS daemon.

The 8-digit WPS PIN is vulnerable to offline brute-force attacks using tools like Reaver or Bully. The second half of the PIN (digits 7-8) is a checksum of the first half, reducing the keyspace from 10^8 to approximately 10^7 + 10^3 combinations. With no effective rate-limiting or lockout enforced, an attacker within Wi-Fi range can recover the WPS PIN and use it to derive the WPA/WPA2 PSK.

## Evidence

**File:** `/squashfs-root/etc/wscd.conf`

WPS enabled with PIN and PBC methods (line 60):
```
config_method =  0x2788
```

External registrar search disabled (line 33):
```
search_external_registrar = 0
```

MaxPinFailThresHold commented out (lines 69-71):
```
#when PIN failed number >= MaxPinFailThresHold AP will indefinitely auto-lock-down 
#until user intervenes to unlock ; vaild value 1~10
#MaxPinFailThresHold = 10
```

WPS device parameters (lines 1-25):
```
use_ie = 1
auth_type_flags = 39
encrypt_type_flags = 15
uuid = 112233445566778899aaaabbccddeeff
device_attrib_id = 1
device_oui = 0050f204
device_category_id = 6
device_sub_category_id = 1
device_password_id = 0
```

## Impact

- **Wi-Fi Network Compromise:** An attacker within radio range can brute-force the WPS PIN within hours, obtaining the WPA/WPA2 pre-shared key.
- **Unauthorized Network Access:** Gained PSK allows full access to the wireless network and all resources behind the router.
- **No User Interaction Required:** The attack works passively; the router does not require any user action during the brute-force attempt.

## References

- CWE-307: Improper Restriction of Excessive Authentication Attempts
- "Brute Forcing Wi-Fi Protected Setup" (US-CERT VU#723755)
- Reaver / Bully WPS brute-force tools

## Status

- [ ] Not patched (default firmware)
