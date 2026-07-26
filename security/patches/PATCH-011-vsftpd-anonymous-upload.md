# PATCH-011: Disable vsftpd Anonymous Upload

**Vulnerability:** VULN-011 (vsftpd anonymous upload)
**Complexity:** Low
**Requires Recompilation:** Yes (vsftpd.conf)
**Risk Level:** High

## Recommended Fix

Disable anonymous access entirely in vsftpd, require local user authentication for all FTP connections, and restrict write permissions to authenticated users only.

## Changes Required

### /etc/vsftpd.conf

```conf
- anonymous_enable=YES
- anon_upload_enable=YES
- anon_mkdir_write_enable=YES
- anon_other_write_enable=YES
- anon_world_readable_only=YES
- write_enable=YES
+ # PATCH-011: Anonymous access disabled
+ anonymous_enable=NO
+ # anon_upload_enable=NO
+ # anon_mkdir_write_enable=NO
+ # anon_other_write_enable=NO
+ anon_world_readable_only=NO
+ write_enable=NO
+ local_enable=YES
+ chroot_local_user=YES
+ allow_writeable_chroot=NO
+ local_umask=022
+ file_open_mode=0644
+ dirmessage_enable=YES
+ use_localtime=YES
+ secure_chroot_dir=/var/run/vsftpd/empty
+ pam_service_name=vsftpd
+ tcp_wrappers=YES
```

### /etc/vsftpd.chroot_list

Create a restricted list of allowed local users:

```bash
+ # PATCH-010: Local FTP users (one per line)
+ admin
```

### /etc/init.d/vsftpd startup

Add configuration validation:

```bash
+ # PATCH-011: Validate vsftpd configuration
+ if grep -q "^anonymous_enable=YES" /etc/vsftpd.conf; then
+     sed -i 's/^anonymous_enable=YES/anonymous_enable=NO/' /etc/vsftpd.conf
+ fi
+ if grep -q "^anon_upload_enable=YES" /etc/vsftpd.conf; then
+     sed -i 's/^anon_upload_enable=YES/anon_upload_enable=NO/' /etc/vsftpd.conf
+ fi
```

### Directory permissions

Restrict anonymous upload directory:

```bash
- chmod 777 /tmp/ftp_upload
+ # PATCH-011: Remove world-writable upload directory
+ rm -rf /tmp/ftp_upload
+ mkdir -p /home/ftp/uploads
+ chmod 750 /home/ftp/uploads
+ chown ftp:ftp /home/ftp/uploads
```

## Verification

1. Confirm anonymous access is disabled:
   ```bash
   vsftpd -v
   # Check config
   grep -E "^(anonymous_enable|anon_upload_enable)" /etc/vsftpd.conf
   # Should show NO for both
   ```
2. Attempt anonymous login and verify it fails:
   ```bash
   ftp <router_ip>
   # User: anonymous, Pass: test@test.com
   # Should fail with "Login incorrect"
   ```
3. Verify local user login works:
   ```bash
   ftp <router_ip>
   # User: admin, Pass: <password>
   ```

## Notes

- Anonymous FTP was likely intended for firmware updates or public file sharing; consider alternative distribution methods.
- If anonymous read-only access is needed, re-enable `anonymous_enable=YES` but keep all upload/write options disabled.
- FTP transmits credentials in cleartext; consider SFTP as an alternative.
