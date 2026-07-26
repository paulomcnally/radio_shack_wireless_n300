# VULN-014: Outdated Boa Web Server (v0.94, circa 2003)

**Severity:** HIGH
**CWE:** CWE-1104 (Use of Unmaintained Third Party Components)
**CVSS Estimation:** 7.5
**Component:** Boa HTTP server binary, configuration (`etc/boa/boa.conf`)

## Description

The firmware uses Boa version 0.94 as its HTTP web server, as indicated by the configuration file header. Boa 0.94 was released around 2003 and the project has been effectively unmaintained since approximately 2005. This version predates many modern security hardening measures and contains numerous known vulnerabilities including buffer overflows, directory traversal, and denial-of-service issues.

The configuration also runs Boa as `User root` and `Group root` (lines 50-51 of boa.conf), meaning any vulnerability in the web server directly yields root-level code execution. Combined with the CGI handler configured for `.cgi` and `.php` extensions, the attack surface is significant.

## Evidence

**File:** `/squashfs-root/etc/boa/boa.conf`

Version identification (lines 1, 13):
```
# Boa v0.94 configuration file
# File format has not changed from 0.93
```
```
# $Id: boa.conf,v 1.3.2.6 2003/02/02 05:02:22 jnelson Exp $
```

Running as root (lines 50-51):
```
User root
Group root
```

CGI execution enabled (lines 230-231):
```
AddType application/x-httpd-cgi cgi
AddType application/x-httpd-cgi php
```

CGI path includes web directory (line 220):
```
CGIPath /bin:/usr/bin:/web/cgi-bin/
```

DocumentRoot pointing to web UI (line 163):
```
DocumentRoot /web
```

ScriptAlias for CGI (line 251):
```
ScriptAlias /cgi-bin/ /web/cgi-bin/
```

## Impact

- **Known Vulnerabilities:** Boa 0.94 has documented CVEs including buffer overflows in HTTP request parsing, chunked transfer encoding handling, and directory traversal attacks.
- **Root-Level Exploitation:** Since Boa runs as root, any code execution vulnerability in the web server immediately grants full system privileges.
- **No Security Updates:** The project has been unmaintained for nearly two decades; no patches will be issued for discovered vulnerabilities.
- **Attack Surface:** The web server is the primary administration interface and is exposed on both LAN and potentially WAN (see VULN-008).
- **CGI Attack Vector:** PHP and CGI script execution provides additional exploitation paths.

## References

- CWE-1104: Use of Unmaintained Third Party Components
- Boa web server project (archived): http://www.boa.org/
- CVE-2007-0011 - Boa directory traversal
- CVE-2007-0012 - Boa chunked encoding buffer overflow
- CVE-2006-4371 - Boa information disclosure

## Status

- [ ] Not patched (default firmware)
