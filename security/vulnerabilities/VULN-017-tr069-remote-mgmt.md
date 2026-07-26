# VULN-017: TR-069 Remote Management Protocol Enabled

**Severity:** MEDIUM
**CWE:** CWE-284 (Improper Access Control)
**CVSS Estimation:** 5.3
**Component:** `/bin/cwmpClient`, `/web/tr069.html`

## Description

The firmware includes TR-069 (CWMP - CPE Wide Area Management Protocol) support via the `cwmpClient` binary. TR-069 is a protocol used by ISPs to remotely manage customer premises equipment (CPE). If enabled, the router will periodically connect to a designated Auto Configuration Server (ACS) and accept remote configuration commands. If the ACS server is compromised or if an attacker can redirect ACS traffic, all routers using this firmware can be reconfigured remotely without user knowledge or consent.

## Evidence

**`/web/tr069.html` configuration page:**
```html
<title>TR-069 Configuration</title>
<% multilang("This page is used to configure the TR-069 CPE. Here you may change the setting for the ACS's parameters."); %>
```

**ACS Configuration Fields (`/web/tr069.html:167-178`):**
```html
<th><% multilang("URL"); %>:</th>
<td><input type="text" id="url1" name="url" class="input-style" maxlength="256" value="<% getInfo("acs_url"); %>"></td>
<th><% multilang("Username"); %>:</th>
<td><input type="text" id="username" name="username" class="input-style" maxlength="256" value="<% getInfo("acs_username"); %>"></td>
<th><% multilang("Password"); %>:</th>
<td><input type="password" id="password" name="password" maxlength="256" value="<% getInfo("acs_password"); %>" class="input-style showpassword" ></td>
```

**TR-069 initialization (`/etc/init.d/rcS_32M:26-30`):**
```
mkdir /var/cwmp_default
mkdir /var/cwmp_config
if [ ! -f /var/cwmp_default/DefaultCwmpNotify.txt ]; then
    cp -p /etc/DefaultCwmpNotify.txt /var/cwmp_default/DefaultCwmpNotify.txt 2>/dev/null
```

**Binary present:**
```
/bin/cwmpClient
```

## Impact

- **Remote Configuration**: An attacker who compromises the ACS server can push arbitrary configuration changes to all routers.
- **Firmware Updates**: TR-069 supports remote firmware upgrades, potentially allowing persistent malware installation.
- **Credential Exposure**: ACS credentials may be transmitted insecurely or stored in plaintext.
- **Mass Exploitation**: A single compromised ACS could simultaneously attack thousands of routers.
- **ISP Dependency**: Users cannot disable this feature without modifying firmware, creating vendor lock-in.

## References

- CWE-284: https://cwe.mitre.org/data/definitions/284.html
- TR-069 Amendment 6: https://www.broadband-forum.org/technical/download/TR-069_Amendment-6.pdf
- Similar: CVE-2020-8589 (TR-069 misconfiguration vulnerabilities)

## Status
- [ ] Not patched (default firmware)
