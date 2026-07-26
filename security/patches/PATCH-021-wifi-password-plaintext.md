# PATCH-021: WiFi Password Stored in Plaintext

**Vulnerability:** VULN-021
**Complexity:** Medium
**Requires Recompilation:** Yes
**Risk Level:** Medium

## Recommended Fix

Encrypt WiFi password in config.dat, or at minimum mask it in the web UI. Plaintext storage means any file read vulnerability exposes the WiFi password, allowing network access.

## Changes Required

### /etc/config.dat (encryption approach)
```
 # WiFi configuration
-wifi_psk=MySecretPassword123
+wifi_psk_encrypted=$1$aB3dEfGh$IjKlMnOpQrStUvWxYz
+wifi_psk_salt=aB3dEfGh
```

### /etc/init.d/S40network (decryption at runtime)
```
 #!/bin/sh
 
+# Decrypt WiFi password for hostapd
+decrypt_wifi_psk() {
+    local encrypted=$(uci get wireless.radio0.psk_encrypted 2>/dev/null)
+    local salt=$(uci get wireless.radio0.psk_salt 2>/dev/null)
+    if [ -n "$encrypted" ] && [ -n "$salt" ]; then
+        echo "$encrypted" | openssl enc -d -md5 -pass pass:"${salt}" -base64
+    fi
+}
+
 # Configure WiFi
 setup_wifi() {
-    local psk=$(uci get wireless.radio0.psk)
+    local psk=$(decrypt_wifi_psk)
     # ... hostapd configuration
 }
```

### /www/wifi.html (web UI masking)
```
 <div class="section">
     <h3>WiFi Settings</h3>
     <form method="post" action="/cgi-bin/config">
         <label>Network Name (SSID):</label>
         <input type="text" name="ssid" value="<% uci get wireless.radio0.ssid %>">
         <br>
         <label>Password:</label>
-        <input type="text" name="psk" value="<% uci get wireless.radio0.psk %>">
+        <input type="password" name="psk" value="" placeholder="Enter new password">
         <br>
+        <small>Leave blank to keep current password</small>
+        <br>
         <button type="submit">Save</button>
     </form>
 </div>
```

### /www/cgi-bin/config.cgi (encryption on save)
```
 #!/bin/sh
 
+# Encrypt WiFi password before saving
+encrypt_wifi_psk() {
+    local psk="$1"
+    local salt=$(head -c 8 /dev/urandom | base64 | head -c 8)
+    local encrypted=$(echo "$psk" | openssl enc -e -md5 -pass pass:"${salt}" -base64)
+    echo "${encrypted}|${salt}"
+}
+
 save_wifi_config() {
     local new_psk="$POST_psk"
     if [ -n "$new_psk" ]; then
-        uci set wireless.radio0.psk="$new_psk"
+        local result=$(encrypt_wifi_psk "$new_psk")
+        local encrypted=$(echo "$result" | cut -d'|' -f1)
+        local salt=$(echo "$result" | cut -d'|' -f2)
+        uci set wireless.radio0.psk_encrypted="$encrypted"
+        uci set wireless.radio0.psk_salt="$salt"
+        uci delete wireless.radio0.psk 2>/dev/null
     fi
 }
```

## Verification

```bash
# Check config.dat doesn't contain plaintext password
grep -i "psk" /etc/config.dat
# Should show encrypted value, not plaintext

# Verify decryption works
source /etc/init.d/S40network
decrypt_wifi_psk

# Test web UI masking
curl -s http://192.168.1.1/wifi.html | grep 'type="password"'
# Should return type="password" not type="text"

# Verify WiFi still connects after changes
iw dev wlan0 station dump | grep -i signal
```

## Notes

- Encryption key is derived from salt; consider hardware-specific key for better security
- Backup config.dat before implementing (encrypted values not reversible without salt)
- Some devices use `/proc/config` or `/tmp/config` at runtime - check both locations
- Consider using hostapd's own password file format for WPA3 support
- If web UI requires showing password for support, add re-authentication prompt
