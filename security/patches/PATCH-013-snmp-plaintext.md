# PATCH-013: Fix SNMP Plaintext Community Strings

**Vulnerability:** VULN-013 (SNMP plaintext)
**Complexity:** Medium
**Requires Recompilation:** Yes (snmpd.sh + snmp.html)
**Risk Level:** Medium

## Recommended Fix

Upgrade to SNMPv3 with authentication and encryption, or at minimum mask community strings in the web interface and restrict SNMP access to localhost only.

## Changes Required

### /etc/snmp/snmpd.conf

```conf
- rocommunity public
- rwcommunity private
+ # PATCH-013: Restrict SNMP to localhost only
+ rocommunity <strong_random_string> 127.0.0.1
+ # Remove or comment out WAN-accessible community strings
+ # rocommunity public
+ # rwcommunity private
+
+ # SNMPv3 configuration (preferred)
+ createUser admin SHA <auth_password> DES <priv_password>
+ rouser admin priv
+ rwuser admin priv
```

Generate strong random community strings:

```bash
+ # PATCH-013: Generate secure community strings
+ RO_COMMUNITY=$(openssl rand -hex 16)
+ RW_COMMUNITY=$(openssl rand -hex 16)
+ echo "rocommunity $RO_COMMUNITY 127.0.0.1" >> /etc/snmp/snmpd.conf
+ echo "rwcommunity $RW_COMMUNITY 127.0.0.1" >> /etc/snmp/snmpd.conf
```

### /www/snmp.html

Change community string input fields from plaintext to password type:

```html
- <tr>
-   <td>Read Community:</td>
-   <td><input type="text" name="ro_community" value="<% get_ro_community(); %>" /></td>
- </tr>
- <tr>
-   <td>Write Community:</td>
-   <td><input type="text" name="rw_community" value="<% get_rw_community(); %>" /></td>
- </tr>

+ <tr>
+   <td>Read Community:</td>
+   <td><input type="password" name="ro_community" value="" placeholder="Enter new community string" /></td>
+ </tr>
+ <tr>
+   <td>Write Community:</td>
+   <td><input type="password" name="rw_community" value="" placeholder="Enter new community string" /></td>
+ </tr>
```

### SNMP CGI handler

Do not echo back community strings in responses:

```c
- snprintf(response, "ro_community=%s", get_ro_community());
+ /* PATCH-013: Never expose community strings in responses */
+ snprintf(response, "ro_community=****");
```

### /etc/init.d/snmp startup

Add iptables rules to restrict SNMP access:

```bash
+ # PATCH-013: Restrict SNMP to localhost
+ iptables -A INPUT -p udp --dport 161 -s 127.0.0.1 -j ACCEPT
+ iptables -A INPUT -p udp --dport 161 -j DROP
+ iptables -A INPUT -p tcp --dport 161 -s 127.0.0.1 -j ACCEPT
+ iptables -A INPUT -p tcp --dport 161 -j DROP
```

## Verification

1. Confirm community strings are masked in web UI:
   ```bash
   curl http://router/snmp.html | grep 'type="text"'
   # Should return no matches for community string fields
   ```
2. Verify SNMP is only accessible from localhost:
   ```bash
   snmpwalk -v2c -c public <router_ip> system
   # Should timeout or fail from external host
   ```
3. Check snmpd.conf does not contain default community strings:
   ```bash
   grep -E "^(ro|rw)community" /etc/snmp/snmpd.conf
   # Should show random strings, not "public" or "private"
   ```

## Notes

- SNMPv3 with authPriv is the preferred solution but may not be supported by all monitoring tools.
- If SNMPv3 cannot be implemented, restricting to localhost + strong community strings is an acceptable mitigation.
- Community strings should be stored encrypted if possible; plaintext in snmpd.conf is acceptable only if the file has restricted permissions (0600).
- Consider disabling SNMP entirely if not used, by removing snmpd from startup.
