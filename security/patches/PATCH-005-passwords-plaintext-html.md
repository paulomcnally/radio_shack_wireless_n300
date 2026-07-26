# PATCH-005: Mask Password Fields in Web Interface

**Vulnerability:** VULN-005 (Passwords in plaintext HTML)
**Complexity:** Low
**Requires Recompilation:** Yes (HTML files)
**Risk Level:** Low (risk of breaking functionality)

## Recommended Fix

Change all password and credential input fields from `type="text"` to `type="password"` in the web interface HTML files. This prevents passwords from being visible on screen and being captured via shoulder surfing or screen recording.

## Changes Required

### /www/routermain.html
```
-<input type="text" name="password" size="20" maxlength="64">
+<input type="password" name="password" size="20" maxlength="64">
```

```
-<input type="text" name="confirm_password" size="20" maxlength="64">
+<input type="password" name="confirm_password" size="20" maxlength="64">
```

### /www/wlwps.html
```
-<input type="text" name="wpa_psk" size="20" maxlength="63">
+<input type="password" name="wpa_psk" size="20" maxlength="63">
```

```
-<input type="text" name="wep_key" size="20" maxlength="26">
+<input type="password" name="wep_key" size="20" maxlength="26">
```

### /www/wlwpakey.html
```
-<input type="text" name="radius_key" size="20" maxlength="64">
+<input type="password" name="radius_key" size="20" maxlength="64">
```

### /www/wlwep.html
```
-<input type="text" name="wep_key1" size="20" maxlength="26">
+<input type="password" name="wep_key1" size="20" maxlength="26">
```

```
-<input type="text" name="wep_key2" size="20" maxlength="26">
+<input type="password" name="wep_key2" size="20" maxlength="26">
```

```
-<input type="text" name="wep_key3" size="20" maxlength="26">
+<input type="password" name="wep_key3" size="20" maxlength="26">
```

```
-<input type="text" name="wep_key4" size="20" maxlength="26">
+<input type="password" name="wep_key4" size="20" maxlength="26">
```

### /www/wlsecurity.html
```
-<input type="text" name="admin_password" size="20" maxlength="32">
+<input type="password" name="admin_password" size="20" maxlength="32">
```

### /www/wlsurvey.html (if applicable)
```
-<input type="text" name="connect_key" size="20" maxlength="63">
+<input type="password" name="connect_key" size="20" maxlength="63">
```

### /www/wizard.html (if applicable)
```
-<input type="text" name="wifi_password" size="20" maxlength="63">
+<input type="password" name="wifi_password" size="20" maxlength="63">
```

## Verification

1. Access the web interface and navigate to all pages with password fields
2. Verify all password fields display dots/bullets instead of plaintext
3. Test that form submission still works correctly with masked fields
4. Inspect HTML source to confirm `type="password"` is present on all credential fields
5. Verify no password fields remain as `type="text"`

## Notes

- Consider adding a "show password" toggle button for user convenience
- Ensure all language versions of the HTML files are updated
- This fix is purely cosmetic; does not encrypt data in transit (still needs HTTPS)
- Search for any additional HTML files with credential fields using: `grep -r 'type="text"' /www/ | grep -i pass`
