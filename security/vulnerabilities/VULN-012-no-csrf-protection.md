# VULN-012: Cross-Site Request Forgery (CSRF) - No Token Protection

**Severity:** HIGH
**CWE:** CWE-352 (Cross-Site Request Forgery)
**CVSS Estimation:** 8.0
**Component:** All web UI form handlers (`web/*.html`)

## Description

The entire web administration interface lacks CSRF token protection. Analysis of all HTML files reveals 69 form submissions using `method=POST` across 40+ pages, none of which include a CSRF token or any anti-CSRF mechanism. All forms simply POST to `/boafrm/*` endpoints with no nonce, token, or origin validation.

An attacker on the same LAN can craft a malicious webpage that, when visited by an authenticated router admin, will silently submit POST requests to reconfigure the router. This enables password changes, firewall rule modifications, port forwarding, DNS changes, and complete device takeover without the administrator's knowledge.

## Evidence

**File:** `/squashfs-root/web/admin.html` - Password change form (line 74):
```html
<form action=/boafrm/formPasswordSetup method=POST name="password">
```

**File:** `/squashfs-root/web/internet.html` - WAN configuration (line 1456):
```html
<form action=/boafrm/formWanTcpipSetup method=POST name="tcpip" id="tcpip">
```

**File:** `/squashfs-root/web/system.html` - Config save (line 147):
```html
<form action=/boafrm/formSaveConfig method=POST name="saveConfig">
```

**File:** `/squashfs-root/web/snmp.html` - SNMP settings (line 141):
```html
<form action=/boafrm/formSetSNMP method=POST name="snmp">
```

**File:** `/squashfs-root/web/wlsecurity.html` - Wi-Fi security (line 227):
```html
<form action=/boafrm/formWlEncrypt method=POST name="formEncrypt">
```

**File:** `/squashfs-root/web/portforwarding.html` - Port forwarding (lines 41, 61, 134):
```html
<form action=/boafrm/formPortFw method=POST name="formPortFwAdd_btn">
<form action=/boafrm/formPortFw method=POST name="formPortFwAdd">
<form action=/boafrm/formPortFw method=POST name="formPortFwDel">
```

**File:** `/squashfs-root/web/dmz.html` - DMZ configuration (lines 43, 54):
```html
<form action=/boafrm/formDMZ method=POST name="formDMZ_button">
<form action=/boafrm/formDMZ method=POST name="formDMZ">
```

Full list of affected form endpoints (69 POST forms across firmware):
- `/boafrm/formWanTcpipSetup` (WAN config)
- `/boafrm/formPasswordSetup` (admin password)
- `/boafrm/formSaveConfig` (backup/restore)
- `/boafrm/formAutoRestart` (reboot)
- `/boafrm/formSetSNMP` (SNMP)
- `/boafrm/formWlEncrypt` (Wi-Fi password)
- `/boafrm/formPortFw` (port forwarding)
- `/boafrm/formDMZ` (DMZ)
- `/boafrm/formFilter` (MAC/URL/IP filters)
- `/boafrm/formTcpipSetup` (LAN config)
- `/boafrm/formDdns` (DDNS)
- `/boafrm/formNtp` (time settings)
- `/boafrm/formOpMode` (operation mode)
- `/boafrm/formRoute` (static routes)
- `/boafrm/formSysLog` (system log)
- `/boafrm/formDosCfg` (DoS protection)
- `/boafrm/formWsc` (WPS)
- `/boafrm/formAdvanceSetup` (advanced wireless)
- `/boafrm/formWlanSetup` (wireless setup)
- `/boafrm/formWizard` (setup wizard)
- `/boafrm/formTR069Config` (TR-069)
- `/boafrm/formIpQoS` (QoS)
- `/boafrm/formIpv6Setup` (IPv6)
- `/boafrm/formVlan` (VLAN)
- `/boafrm/formStaticDHCP` (static DHCP)
- `/boafrm/formParentCtrl` (parental controls)
- `/boafrm/formNewSchedule` (scheduling)
- `/boafrm/formRuleSettings` (rule settings)
- `/boafrm/formWlAc` (wireless access control)
- `/boafrm/formWlSiteSurvey` (site survey)
- `/boafrm/formWlanMultipleAP` (multiple AP)
- `/boafrm/formStats` (statistics)

## Impact

- **Router Reconfiguration:** An attacker can change WAN settings, DNS servers, firewall rules, port forwarding, DMZ, and all other router settings.
- **Password Change:** The admin password can be changed via crafted POST to `/boafrm/formPasswordSetup`, locking out the legitimate administrator.
- **Wi-Fi Key Disclosure/Change:** The attacker can extract or change the Wi-Fi PSK via `/boafrm/formWlEncrypt`.
- **Firmware Upload:** Combined with firmware upload forms, an attacker could potentially flash modified firmware.
- **Complete Device Takeover:** Any combination of the above can lead to full compromise of the router.

## References

- CWE-352: Cross-Site Request Forgery
- OWASP CSRF Prevention Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html

## Status

- [ ] Not patched (default firmware)
