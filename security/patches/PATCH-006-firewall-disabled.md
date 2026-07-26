# PATCH-006: Enable Firewall by Default with Basic iptables Rules

**Vulnerability:** VULN-006 (Firewall disabled)
**Complexity:** Medium
**Requires Recompilation:** Yes (firewall.sh)
**Risk Level:** Medium (risk of breaking functionality)

## Recommended Fix

Implement and enable a basic firewall configuration by default. The firewall should block unsolicited incoming traffic from the WAN interface, allow established connections, and permit legitimate LAN traffic. Users can customize rules through the web UI.

## Changes Required

### /etc/init.d/firewall.sh
```
 #!/bin/sh
 # Basic firewall configuration for RadioShack Wireless N300
+
+# Flush existing rules
+iptables -F
+iptables -X
+iptables -t nat -F
+iptables -t nat -X
+
+# Set default policies
+iptables -P INPUT DROP
+iptables -P FORWARD DROP
+iptables -P OUTPUT ACCEPT
+
+# Allow loopback interface
+iptables -A INPUT -i lo -j ACCEPT
+iptables -A OUTPUT -o lo -j ACCEPT
+
+# Allow established and related connections
+iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
+iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT
+
+# Allow ICMP (ping) from LAN
+iptables -A INPUT -i br0 -p icmp --icmp-type echo-request -j ACCEPT
+
+# Allow DHCP from LAN
+iptables -A INPUT -i br0 -p udp --dport 67:68 -j ACCEPT
+
+# Allow DNS from LAN
+iptables -A INPUT -i br0 -p udp --dport 53 -j ACCEPT
+iptables -A INPUT -i br0 -p tcp --dport 53 -j ACCEPT
+
+# Allow HTTP/HTTPS from LAN (web interface)
+iptables -A INPUT -i br0 -p tcp --dport 80 -j ACCEPT
+iptables -A INPUT -i br0 -p tcp --dport 443 -j ACCEPT
+
+# Allow SSH from LAN (if enabled)
+iptables -A INPUT -i br0 -p tcp --dport 22 -j ACCEPT
+
+# Allow UPnP from LAN
+iptables -A INPUT -i br0 -p udp --dport 1900 -j ACCEPT
+iptables -A INPUT -i br0 -p tcp --dport 49152:65535 -j ACCEPT
+
+# Block WAN input (except established)
+iptables -A INPUT -i eth0.2 -m state --state NEW -j DROP
+
+# NAT for internet access
+iptables -t nat -A POSTROUTING -o eth0.2 -j MASQUERADE
+
+# Log dropped packets (optional, limit rate)
+iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "IPTables-Dropped: "
+
+# Save rules
+iptables-save > /etc/iptables.rules
```

### /etc/init.d/rcS_32M (add firewall startup)
```
 # Start firewall
+/etc/init.d/firewall.sh start
```

### /www/firewall.html (new page for firewall management)
```
+<html>
+<head><title>Firewall Settings</title></head>
+<body>
+<h1>Firewall Configuration</h1>
+<form action="/cgi-bin/firewall.cgi" method="post">
+  <p>Firewall Status:
+    <input type="radio" name="firewall" value="1" checked> Enable
+    <input type="radio" name="firewall" value="0"> Disable
+  </p>
+  <p>
+    <input type="submit" value="Apply">
+  </p>
+</form>
+</body>
+</html>
```

## Verification

1. Boot the device and verify firewall rules are loaded: `iptables -L -v`
2. Confirm default policies are DROP for INPUT and FORWARD
3. Verify WAN interface cannot initiate connections to the router
4. Test that LAN devices can access the internet (NAT works)
5. Test that LAN devices can access the web interface
6. Verify DHCP and DNS work from LAN clients
7. Attempt external scan of WAN IP and confirm ports are filtered

## Notes

- The firewall rules are basic; users may need to open specific ports for port forwarding
- Consider adding UPnP support for automatic port mapping
- Log dropped packets can fill storage; consider rotating logs
- Document common port forwarding configurations in the user manual
- Test thoroughly with connected devices to ensure no connectivity loss
