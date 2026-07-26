# VULN-011: vsftpd Anonymous Upload Enabled

**Severity:** HIGH
**CWE:** CWE-284 (Improper Access Control)
**CVSS Estimation:** 7.5
**Component:** vsftpd configuration (`etc/vsftpd.conf`)

## Description

The vsftpd FTP server is configured with anonymous upload and directory creation enabled. The combination of `write_enable=YES`, `anon_upload_enable=YES`, and `anon_mkdir_write_enable=YES` allows any user on the network to connect as an anonymous FTP client and upload arbitrary files to the router's filesystem. The `chown_uploads=YES` setting transfers ownership of uploaded files to the FTP daemon user, and the `local_umask=0` setting creates files with world-readable permissions (mode 666 for files, 777 for directories).

## Evidence

**File:** `/squashfs-root/etc/vsftpd.conf`

Write operations enabled globally (line 19):
```
write_enable=YES
```

Anonymous upload enabled (line 28):
```
anon_upload_enable=YES
```

Anonymous directory creation enabled (line 32):
```
anon_mkdir_write_enable=YES
```

Permissive file permissions (line 23):
```
local_umask=0
```

Uploaded files owned by FTP daemon (line 48):
```
chown_uploads=YES
```

ASCII upload enabled (line 82):
```
ascii_upload_enable=YES
```

FTP running in standalone mode (line 111):
```
listen=YES
```

## Impact

- **Unrestricted File Upload:** Any device on the LAN can upload arbitrary files to the router via FTP without authentication.
- **Firmware Tampering:** Malicious binaries or scripts could be uploaded and potentially executed.
- **Storage Exhaustion:** Attackers can fill the router's limited storage, causing denial of service.
- **Malware Distribution:** The router becomes a staging point for distributing malware to other network devices.
- **Configuration File Overwrite:** If upload paths overlap with configuration directories, router settings could be modified.

## References

- CWE-284: Improper Access Control
- vsftpd security documentation: https://security.appspot.com/vsftpd.html

## Status

- [ ] Not patched (default firmware)
