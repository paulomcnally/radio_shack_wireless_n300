# VULN-016: Outdated jQuery Versions with Known XSS Vulnerabilities

**Severity:** MEDIUM
**CWE:** CWE-79 (Cross-site Scripting)
**CVSS Estimation:** 6.1
**Component:** `/web/js/jquery-1.2.1.min.js`, `/web/js/jquery-2.1.1.min.js`

## Description

The firmware includes multiple outdated jQuery versions, specifically jQuery 1.2.1 (2007) and jQuery 2.1.1 (2014). Both versions contain known cross-site scripting (XSS) vulnerabilities that have been publicly disclosed and assigned CVE identifiers. jQuery 1.2.1 is particularly ancient and lacks many modern security features. The web administration interface loads these scripts directly, making the management interface vulnerable to XSS attacks if an attacker can inject malicious content.

## Evidence

**`/web/js/` directory listing:**
```
jquery-1.2.1.min.js
jquery-1.4.4.min.js
jquery-1.6.min.js
jquery-1.6.3.min.js
jquery-1.9.1.js
jquery-1.10.1.min.js
jquery-1.11.1.min.js
jquery-2.1.1.min.js
jquery.js
jquery.min.js
```

**jQuery 1.2.1 header (`/web/js/jquery-1.2.1.min.js`):**
```javascript
/*
 * jQuery 1.2.1 - New Wave Javascript
 *
 * Copyright (c) 2007 John Resig (jquery.com)
 * Dual licensed under the MIT (MIT-LICENSE.txt)
```

**jQuery 2.1.1 loaded in TR-069 page (`/web/tr069.html:16`):**
```html
<script src="js/jquery-2.1.1.min.js"></script>
```

## Impact

- **XSS Attacks**: Known vulnerabilities in jQuery <1.6.3 and <2.1.0 allow script injection via crafted HTML content.
- **Session Hijacking**: XSS in the admin interface can steal session cookies and hijack administrator sessions.
- **CSRF Facilitation**: XSS can be chained with CSRF to perform unauthorized configuration changes.
- **Credential Theft**: Malicious scripts can capture admin credentials entered in the web interface.
- **Attack Surface**: Multiple jQuery versions increase the attack surface unnecessarily.

## References

- CWE-79: https://cwe.mitre.org/data/definitions/79.html
- CVE-2012-6708: jQuery <1.6.3 XSS via script tag manipulation
- CVE-2015-9251: jQuery <2.2.0 XSS via cross-domain AJAX requests
- CVE-2019-11358: jQuery <3.4.0 prototype pollution
- CVE-2020-11022/11023: jQuery <3.5.0 XSS in `.html()` and `.append()`

## Status
- [ ] Not patched (default firmware)
