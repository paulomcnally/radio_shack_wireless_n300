# PATCH-009: Prevent WPS Brute-Force Attacks

**Vulnerability:** VULN-009 (WPS brute-force)
**Complexity:** Medium
**Requires Recompilation:** Yes (wscd.conf)
**Risk Level:** High

## Recommended Fix

Disable WPS by default in the WPS daemon configuration. If WPS must remain available, implement a PIN lockout mechanism that temporarily disables WPS after 3 failed PIN attempts, preventing online brute-force attacks.

## Changes Required

### /etc/wscd.conf

Disable WPS entirely by default:

```conf
- wps_device_pin=12345670
- wps_enable=1
- wps_config_method=0x0002
- wps_scstate=UNCONFIGURED

+ # PATCH-009: WPS disabled by default to prevent brute-force
+ wps_device_pin=00000000
+ wps_enable=0
+ wps_config_method=0x0002
+ wps_scstate=UNCONFIGURED
+ # Lockout: max 3 attempts, 10 minute cooldown
+ wps_max_attempts=3
+ wps_lockout_time=600
```

If WPS must remain enabled, add lockout parameters:

```conf
+ # PATCH-009: WPS brute-force mitigation
+ wps_enable=1
+ wps_max_attempts=3
+ wps_lockout_time=600
+ wps_lockout_action=disable
```

### /etc/init.d/wps脚本 or startup script

Add a check in the WPS startup script to enforce the lockout state:

```bash
+ # PATCH-009: Enforce WPS lockout policy
+ WPS_ATTEMPTS_FILE="/tmp/.wps_attempts"
+ WPS_LOCKOUT_FILE="/tmp/.wps_lockout"
+ MAX_ATTEMPTS=3
+ LOCKOUT_TIME=600
+
+ check_wps_lockout() {
+     if [ -f "$WPS_LOCKOUT_FILE" ]; then
+         local lock_time=$(cat "$WPS_LOCKOUT_FILE")
+         local now=$(date +%s)
+         if [ $((now - lock_time)) -lt $LOCKOUT_TIME ]; then
+             echo "WPS locked out, too many failed attempts"
+             wps_enable=0
+             return 1
+         else
+             rm -f "$WPS_LOCKOUT_FILE"
+             echo "0" > "$WPS_ATTEMPTS_FILE"
+         fi
+     fi
+ }
```

## Verification

1. Verify WPS is disabled by default after recompilation:
   ```bash
   cat /etc/wscd.conf | grep wps_enable
   # Should show: wps_enable=0
   ```
2. Attempt to brute-force WPS PIN and verify lockout after 3 attempts.
3. Confirm lockout persists for the configured timeout period.

## Notes

- WPS PIN brute-force is feasible because the 8-digit PIN is validated in two halves (4+3+1), reducing the keyspace to ~11,000 attempts.
- If WPS is needed for setup, consider only enabling it during initial configuration and disabling it afterward via a firmware setting.
- This fix may impact users who rely on WPS for device pairing.
