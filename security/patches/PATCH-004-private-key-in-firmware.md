# PATCH-004: Generate Unique RSA Keypair Per Device at First Boot

**Vulnerability:** VULN-004 (Private key in firmware)
**Complexity:** High
**Requires Recompilation:** Yes (key generation at first boot)
**Risk Level:** Medium (risk of breaking functionality)

## Recommended Fix

Remove the hardcoded RSA private key from the firmware image. Instead, generate a unique RSA keypair on each device at first boot using the device's hardware entropy source. Store the private key in /var (volatile storage) so it is regenerated if the device is reset to factory defaults.

## Changes Required

### /etc/init.d/rcS_32M (add at boot, before SSH/web server start)
```
+# Generate unique RSA keypair at first boot
+generate_device_keys() {
+    local KEY_DIR="/var/etc/ssl"
+    local KEY_FILE="${KEY_DIR}/device.key"
+    local CERT_FILE="${KEY_DIR}/device.crt"
+
+    # Only generate if keys don't exist
+    if [ ! -f "$KEY_FILE" ]; then
+        mkdir -p "$KEY_DIR"
+
+        # Generate 2048-bit RSA private key
+        openssl genrsa -out "$KEY_FILE" 2048 2>/dev/null
+
+        # Generate self-signed certificate (valid for device lifetime)
+        openssl req -new -x509 -key "$KEY_FILE" -out "$CERT_FILE" \
+            -days 3650 -subj "/CN=$(hostname)" 2>/dev/null
+
+        # Set restrictive permissions
+        chmod 600 "$KEY_FILE"
+        chmod 644 "$CERT_FILE"
+        chown root:root "$KEY_DIR" "$KEY_FILE" "$CERT_FILE"
+
+        logger "Device RSA keypair generated"
+    fi
+}
+
+generate_device_keys
```

### /etc/init.d/factory_reset (add key cleanup)
```
+# Clear generated keys on factory reset
+clear_device_keys() {
+    rm -f /var/etc/ssl/device.key
+    rm -f /var/etc/ssl/device.crt
+}
+
+# Hook into factory reset process
+if [ "$ACTION" = "factory_reset" ]; then
+    clear_device_keys
+fi
```

### /etc/ssl/device.crt (generated at boot, not in firmware)
```
+# This file is generated per-device, NOT included in firmware
+# Location: /var/etc/ssl/device.key (private) and /var/etc/ssl/device.crt (public)
```

## Implementation Steps

1. **Remove from firmware build:**
   - Delete the static private key from the rootfs source
   - Remove any hardcoded key references in the build system

2. **Add key generation script:**
   - Create `/etc/init.d/generate_keys.sh` with the logic above
   - Make it executable: `chmod +x /etc/init.d/generate_keys.sh`

3. **Update services to use generated keys:**
   - Modify SSH server config to use `/var/etc/ssl/device.key`
   - Update any HTTPS services to use the generated certificate

4. **Handle edge cases:**
   - If entropy source is unavailable, fall back to `/dev/urandom`
   - Log warnings if key generation fails
   - Ensure keys persist across reboots but not factory resets

## Verification

1. Flash firmware to a device and boot it
2. Verify `/var/etc/ssl/device.key` and `/var/etc/ssl/device.crt` exist after boot
3. Confirm the key is unique by comparing across multiple devices
4. Perform factory reset and confirm keys are regenerated
5. Verify SSH/HTTPS connections use the new device-specific key
6. Run `openssl x509 -in /var/etc/ssl/device.crt -text -noout` to verify certificate

## Notes

- 2048-bit RSA is recommended for embedded devices (balance of security/performance)
- Consider using ECC keys (secp256r1) for better performance on constrained hardware
- Ensure the device has sufficient entropy (hardware RNG if available)
- Document that factory resets generate new keys, which may require re-establishing trust
