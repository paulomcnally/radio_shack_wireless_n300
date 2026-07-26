# PATCH-002: Disable Telnet by Default, Make Configurable via Web UI

**Vulnerability:** VULN-002 (Telnet unconditionally enabled)
**Complexity:** Low
**Requires Recompilation:** Yes (init script)
**Risk Level:** Low (risk of breaking functionality)

## Recommended Fix

Remove the unconditional `telnetd&` startup from the init script. Instead, make telnet configurable through the web UI with a toggle switch. Telnet should be disabled by default and only enabled when explicitly requested by the user.

## Changes Required

### /etc/init.d/rcS_32M
```
 # Start telnet daemon
-telnetd&
+# Telnet disabled by default - configurable via web UI
+# if [ -f /var/etc/telnet_enabled ]; then
+#     telnetd&
+# fi
```

### /etc/init.d/rcS_32M (add conditional block)
```
+# Start telnet daemon only if enabled via web UI
+if [ -f /var/etc/telnet_enabled ]; then
+    /usr/sbin/telnetd &
+    logger "Telnet daemon started"
+fi
```

### /www/cgi-bin/telnet.cgi (new file or modify existing)
```
+# Toggle telnet on/off
+case "$ACTION" in
+    enable)
+        touch /var/etc/telnet_enabled
+        /usr/sbin/telnetd &
+        ;;
+    disable)
+        rm -f /var/etc/telnet_enabled
+        killall telnetd 2>/dev/null
+        ;;
+esac
```

### /www/routermain.html (add telnet toggle to UI)
```
+<tr>
+  <td>Telnet Access</td>
+  <td>
+    <input type="checkbox" name="telnet_enable" value="1"
+      <% [ -f /var/etc/telnet_enabled ] && echo "checked" %>>
+    Enable Telnet (not recommended)
+  </td>
+</tr>
```

## Verification

1. Boot the device and confirm telnet port (23) is not listening: `netstat -tlnp | grep :23`
2. Access the web UI and verify a Telnet toggle option exists
3. Enable telnet via web UI and confirm telnetd starts
4. Disable telnet and confirm the service stops
5. Reboot and confirm telnet remains disabled

## Notes

- SSH should be the preferred remote access method
- If telnet must remain enabled, add a warning in the UI about security risks
- Consider adding IP-based access control as an additional restriction
