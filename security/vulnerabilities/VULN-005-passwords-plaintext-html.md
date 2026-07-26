# VULN-005: Passwords Exposed in Plaintext in Web Interface

**Severity:** CRITICAL
**CWE:** CWE-200 (Exposure of Sensitive Information)
**CVSS Estimation:** 8.6
**Component:** `/web/main/routermain.html`, `/web/wlwps.html`, `/web/main/accesspointmain.html`

## Description

Multiple pages in the web administration interface render passwords using `type="text"` input fields or embed them directly in JavaScript variables, making them visible in the browser and extractable from page source. Affected credentials include PPPoE passwords, PPTP passwords, L2TP passwords, WPA/WPA2 PSK keys, and WPS keys. Even where `type="password"` is used in some sections, the same passwords are exposed in plaintext via JavaScript variables and other form fields on the same page.

## Evidence

**PPPoE password as `type="text"` (`/web/main/routermain.html`, line 2165):**
```html
<td><input type="text" name="pppPassword" size="18" maxlength="128" class="input-style" value="<% getInfo("pppPassword"); %>"></td>
```

**PPTP password as `type="text"` (`/web/main/routermain.html`, line 2255):**
```html
<td><input type="text" name="pptpPassword" size="18" maxlength="128" class="input-style" value="<% getInfo("pptpPassword"); %>"></td>
```

**L2TP password as `type="text"` (`/web/main/routermain.html`, line 2342):**
```html
<input type="text" name="l2tpPassword" size="18" maxlength="128" class="input-style" value="<% getInfo("l2tpPassword"); %>">
```

**WPA PSK key rendered in plaintext via JavaScript (`/web/main/routermain.html`, lines 1523, 1604):**
```javascript
pskValue[0]='<% getInfo("pskValue");%>';
```
```html
<script>document.write('<input type="text" name="pskValue0" style= "width: 225px" class="input-style" value="' + status_password_5g + '">');</script>
```

**WPS key exposed in plaintext (`/web/wlwps.html`, line 39):**
```javascript
var wps_key="<%getInfo("wps_key");%>";
```

**WiFi password in plaintext on AP page (`/web/main/accesspointmain.html`, line 292):**
```html
document.write('<input type="text" id="password2ghz" name="pskValue1" value="' + password_2g + '" maxlength="64" class="input-style" style="width:225px">');
```

## Impact

- Any user who accesses the admin panel (even on the local network) can view all saved passwords.
- An attacker on the local network who can perform XSS or view browser history can extract all credentials.
- PPPoE, PPTP, and L2TP passwords provide ISP account credentials—exposing them allows account takeover.
- WiFi PSK exposure allows unauthorized network access.
- Page source and browser developer tools reveal all credentials without authentication in some configurations.

## References

- CWE-200: https://cwe.mitre.org/data/definitions/200.html
- OWASP: Sensitive Data Exposure
- Similar: CVE-2022-1361 (Zyxel password exposure in web interface)

## Status
- [ ] Not patched (default firmware)
