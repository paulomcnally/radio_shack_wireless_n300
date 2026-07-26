# PATCH-008: Remove Telnet Exposure on WAN Interface

**Vulnerability:** VULN-008 (Telnet exposed on WAN)
**Complexity:** Low
**Requires Recompilation:** Yes (HTML + backend)
**Risk Level:** High

## Recommended Fix

Remove the `WanTelnetEnable` checkbox from the internet settings page and disable WAN-accessible telnet by default. Telnet should only be accessible from the LAN side for local administration. The backend CGI handler must also ignore or reject the `WanTelnetEnable` parameter.

## Changes Required

### /www/internet.html

Remove the WAN Telnet Enable checkbox element entirely:

```html
- <tr>
-   <td class="td_label">WAN Telnet Enable</td>
-   <td>
-     <input type="checkbox" name="WanTelnetEnable" value="1" <% get_wan_telnet_enable(); %> />
-     Allow Telnet from WAN
-   </td>
- </tr>
```

Also remove any corresponding JavaScript validation or submission logic referencing `WanTelnetEnable`.

### Backend CGI (goform or boa handler)

In the form submission handler that processes internet settings, remove or hardcode the WAN telnet setting:

```c
- if (strcmp(para, "WanTelnetEnable") == 0) {
-     set_wan_telnet_enable(val);
- }
+ /* WAN Telnet disabled permanently - VULN-008 fix */
+ /* Do not process WanTelnetEnable parameter */
```

### /etc/init.d/rcS or default configuration

Ensure the default configuration disables WAN telnet:

```bash
- # WAN telnet may be enabled via web UI
+ # WAN telnet permanently disabled (PATCH-008)
+ iptables -A INPUT -i wan -p tcp --dport 23 -j DROP
```

## Verification

1. After recompilation, confirm the internet.html page no longer shows a Telnet Enable option.
2. Verify port 23 is not accessible from the WAN interface:
   ```bash
   nmap -p 23 <wan_ip>
   ```
3. Confirm telnet is still accessible from the LAN side:
   ```bash
   telnet <lan_ip>
   ```

## Notes

- This is a straightforward removal with minimal regression risk.
- LAN-side telnet remains functional for local troubleshooting.
- If remote access is needed, consider SSH with key-based authentication instead.
