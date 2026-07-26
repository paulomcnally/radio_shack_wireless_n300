# VULN-010: Samba File Sharing with Unauthenticated Guest Access

**Severity:** HIGH
**CWE:** CWE-284 (Improper Access Control)
**CVSS Estimation:** 7.5
**Component:** Samba configuration (`etc/samba/smb.conf`)

## Description

The Samba file server is configured with `security = share` mode and three active shares (`[mnt]`, `[mnt1]`, and `[public]`) that all have `public = yes` and `guest ok = yes`. This means any device on the local network can access these shares without providing a username or password. The shares are configured with `writable = yes`, `writeable = yes`, `create mask = 0777`, and `directory mask = 0777`, allowing anonymous users to read, write, create, and delete files.

The `[homes]` share is also present with `writable = yes`, though `browseable = no` limits discoverability. The global setting `public = yes` at line 45 further weakens access controls.

## Evidence

**File:** `/squashfs-root/etc/samba/smb.conf`

Global security mode (line 87):
```
security = share
```

Global public access (line 45):
```
public = yes
```

`[mnt]` share - USB root with full access (lines 210-224):
```
[mnt]
   comment = Temporary file space
   path = /tmp/usb/
   read only = no
   writeable = yes
   public = yes
   oplocks = no
   kernel oplocks = no
   create mask = 0777
   browseable = yes
   guest ok = yes 
   directory mask = 0777
```

`[mnt1]` share - USB partition 1 (lines 227-239):
```
[mnt1]
   comment = Temporary file space sda1
   path = /tmp/usb/sda1
   read only = no
   writeable = yes
   public = yes
   oplocks = no
   kernel oplocks = no
   create mask = 0777
   browseable = yes
   guest ok = yes 
   directory mask = 0777
```

`[public]` share (lines 291-300):
```
[public]
   path = /var/mnt
   public = yes
   only guest = yes
   writable = yes
   printable = no
   create mask = 0777
   directory mask = 0777
   force user = nobody
   force group = nogroup
```

`[homes]` share (lines 170-173):
```
[homes]
   comment = Home Directories
   browseable = no
   writable = yes
```

## Impact

- **Anonymous File Access:** Any device on the LAN can read all files on connected USB storage without credentials.
- **Data Destruction/Modification:** Anonymous write access allows deletion, modification, or ransomware encryption of files on USB storage.
- **Malware Upload:** Attackers can upload malware or malicious files to the router's USB storage.
- **Pivot Point:** Uploaded files could be served or executed depending on other router services.

## References

- CWE-284: Improper Access Control
- Samba security documentation: https://www.samba.org/samba/docs/

## Status

- [ ] Not patched (default firmware)
