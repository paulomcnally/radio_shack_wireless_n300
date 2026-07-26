# PATCH-015: Expired TLS Certificate

**Vulnerability:** VULN-015
**Complexity:** High
**Requires Recompilation:** Yes
**Risk Level:** High

## Recommended Fix

Generate a unique self-signed certificate per device at first boot, or remove TLS entirely if not used. The current expired certificate disables TLS verification entirely, exposing all HTTPS communication to MitM attacks.

## Changes Required

### /etc/init.d/rcS
```
 #!/bin/sh
 # ... existing init code ...
+
+# Generate unique device certificate on first boot
+if [ ! -f /etc/certs/device.crt ]; then
+    mkdir -p /etc/certs
+    DEVICE_ID=$(cat /sys/class/net/eth0/address | tr -d ':')
+    openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
+        -keyout /etc/certs/device.key \
+        -out /etc/certs/device.crt \
+        -subj "/CN=${DEVICE_ID}/O=RadioShack" 2>/dev/null
+    chmod 600 /etc/certs/device.key
+fi
```

### /etc/httpd.conf
```
-ssl_certificate /etc/certs/server.crt
-ssl_key /etc/certs/server.key
+ssl_certificate /etc/certs/device.crt
+ssl_key /etc/certs/device.key
```

### /etc/httpd.conf (alternative: disable TLS if unused)
```
-listen 443
-listen 80
+listen 80
-#ssl_certificate /etc/certs/server.crt
-#ssl_key /etc/certs/server.key
```

## Verification

```bash
# Check cert expiry
openssl x509 -in /etc/certs/device.crt -noout -dates

# Verify cert matches key
openssl x509 -in /etc/certs/device.crt -noout -modulus | md5sum
openssl rsa -in /etc/certs/device.key -noout -modulus | md5sum

# Confirm unique cert per device (different MAC = different cert)
openssl x509 -in /etc/certs/device.crt -noout -subject
```

## Notes

- Requires cross-compilation toolchain with openssl
- First boot generation adds ~2-3s to boot time
- If TLS is not actively used, removing it entirely is simpler and reduces attack surface
- Cert validity of 3650 days (10 years) is acceptable for embedded devices
