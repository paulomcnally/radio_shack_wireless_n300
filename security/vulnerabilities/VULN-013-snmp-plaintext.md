# VULN-013: SNMP Community Strings Stored in Plaintext

**Severity:** HIGH
**CWE:** CWE-200 (Exposure of Sensitive Information)
**CVSS Estimation:** 7.5
**Component:** SNMP daemon startup script (`bin/snmpd.sh`), SNMP web UI (`web/snmp.html`)

## Description

The SNMP daemon configuration script reads community strings from NVRAM using `flash get` and writes them directly into the `/etc/net-snmp/snmpd.conf` file in cleartext. Both read-only (`SNMP_ROCOMMUNITY`) and read-write (`SNMP_RWCOMMUNITY`) community strings are stored without encryption. The SNMP web UI further exposes these strings in plain `type="text"` input fields rather than `type="password"` fields, meaning they are visible on screen and easily observable via shoulder surfing or screen capture.

The combination of cleartext storage, no authentication (SNMPv1/v2c), and weak default community strings ("public"/"private") allows any network attacker to query and potentially reconfigure the router via SNMP.

## Evidence

**File:** `/squashfs-root/bin/snmpd.sh`

Reading community strings from NVRAM (lines 36-41):
```sh
eval `$GETMIB SNMP_ENABLED`
eval `$GETMIB SNMP_NAME`
eval `$GETMIB SNMP_LOCATION`
eval `$GETMIB SNMP_CONTACT`
eval `$GETMIB SNMP_RWCOMMUNITY`
eval `$GETMIB SNMP_ROCOMMUNITY`
```

Writing community strings to config file in cleartext (lines 53-54):
```sh
echo "rocommunity  $SNMP_ROCOMMUNITY" >> $CONFILE
echo "rwcommunity  $SNMP_RWCOMMUNITY" >> $CONFILE
```

**File:** `/squashfs-root/web/snmp.html`

Read/Write Community in plaintext text field (lines 167-169):
```html
<tr>
    <th><% multilang("Read / Write Community"); %>:</th>
    <td><input type="text" id="snmp_rwcommunity" name="snmp_rwcommunity" class="input-style" maxlength="30" value="<% getInfo("snmp_rwcommunity"); %>"></td>
</tr>
```

Read-Only Community in plaintext text field (lines 171-173):
```html
<tr>
    <th><% multilang("Read-Only Community"); %>:</th>
    <td><input type="text" id="snmp_rocommunity" name="snmp_rocommunity" class="input-style" maxlength="30" value="<% getInfo("snmp_rocommunity"); %>"></td>
</tr>
```

Form submission endpoint with no authentication (line 141):
```html
<form action=/boafrm/formSetSNMP method=POST name="snmp">
```

## Impact

- **Information Disclosure:** SNMP queries can extract device configuration, network topology, connected clients, and system information using the default or weak community strings.
- **Configuration Modification:** The read-write community string allows full router reconfiguration via SNMP, including changing network settings, disabling security features, and modifying access controls.
- **Credential Exposure:** Community strings visible in the web UI can be captured via CSRF (VULN-012) or shoulder surfing.
- **Network Reconnaissance:** SNMP enumeration provides detailed network intelligence for further attacks.

## References

- CWE-200: Exposure of Sensitive Information
- RFC 1157 - SNMPv1 Community String Security
- RFC 3584 - Coexistence between SNMPv1 and SNMPv2

## Status

- [ ] Not patched (default firmware)
