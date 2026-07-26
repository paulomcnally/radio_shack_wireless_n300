# PATCH-017: TR-069 Remote Management Enabled by Default

**Vulnerability:** VULN-017
**Complexity:** Low
**Requires Recompilation:** Yes
**Risk Level:** High

## Recommended Fix

Disable cwmpClient by default and make it opt-in via the web UI. TR-069 allows ISP-level remote configuration and firmware updates, creating a backdoor for unauthorized access if ACS credentials are compromised.

## Changes Required

### /etc/init.d/S98cwmpclient
```
 #!/bin/sh
+
+# TR-069 (CWMP) - Disabled by default, opt-in via web UI
+ENABLE_CWMP=$(uci get cwmp.cwmp.enable 2>/dev/null || echo "0")
+
+if [ "$ENABLE_CWMP" != "1" ]; then
+    echo "CWMP disabled (opt-in required)"
+    exit 0
+fi
+
 case "$1" in
     start)
         echo "Starting cwmpClient..."
         /usr/sbin/cwmpClient &
```

### /www/advanced.html
```
 <div class="section">
     <h3>Remote Management (TR-069)</h3>
-    <p>TR-069 is enabled for automatic updates.</p>
+    <p>TR-069 allows your ISP to remotely manage this device.</p>
+    <form method="post" action="/cgi-bin/config">
+        <label>
+            <input type="checkbox" name="cwmp_enable" value="1"
+                <% [ "$(uci get cwmp.cwmp.enable)" = "1" ] && echo "checked" %>>
+            Enable TR-069 Remote Management
+        </label>
+        <br>
+        <label>ACS URL:</label>
+        <input type="text" name="acs_url" value="<% uci get cwmp.cwmp.acs_url %>">
+        <br>
+        <label>Username:</label>
+        <input type="text" name="acs_user" value="<% uci get cwmp.cwmp.username %>">
+        <br>
+        <label>Password:</label>
+        <input type="password" name="acs_pass" value="">
+        <br>
+        <button type="submit">Save</button>
+    </form>
 </div>
```

### /etc/config/cwmp (default config)
```
 config cwmp 'cwmp'
-    option enable '1'
-    option acs_url 'http://acs.isp.example.com:7547'
+    option enable '0'
+    option acs_url ''
+    option username ''
+    option password ''
```

## Verification

```bash
# Check if cwmpClient is running
ps | grep cwmpClient

# Verify UCI default
uci get cwmp.cwmp.enable

# Check init script behavior
/etc/init.d/S98cwmpclient start
cat /tmp/messages | grep CWMP

# Verify web UI checkbox state
curl -s http://192.168.1.1/advanced.html | grep -A2 "cwmp_enable"
```

## Notes

- ISPs may require TR-069 for provisioning; document this for support teams
- If disabling entirely, also remove `/usr/sbin/cwmpClient` binary to prevent accidental activation
- Consider adding ACL rules to restrict TR-069 to specific source IPs when enabled
- Default ACS URL should be empty to prevent connection to unknown servers
