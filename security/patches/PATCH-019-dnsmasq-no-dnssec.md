# PATCH-019: dnsmasq No DNSSEC Support

**Vulnerability:** VULN-019
**Complexity:** Medium
**Requires Recompilation:** Yes
**Risk Level:** Medium

## Recommended Fix

Enable DNSSEC validation and bind dnsmasq to specific interfaces. Without DNSSEC, DNS responses can be spoofed, enabling MitM attacks, phishing, and data exfiltration via DNS.

## Changes Required

### /etc/dnsmasq.conf
```
 # dnsmasq configuration
 
 # Listen on specific interfaces only
-interface=br0
-interface=eth1
+interface=br0
+interface=eth1
+bind-interfaces
 
 # DNSSEC
-dnssec=no
+dnssec=trust-anchor=/etc/dnsmasq.d/root.key
+dnssec-check-unsigned
 
 # Upstream DNS servers
-server=8.8.8.8
-server=8.8.4.4
+server=1.1.1.1
+server=1.0.0.1
+server=8.8.8.8
 
 # Disable DNS rebind protection (keep enabled)
-domain-needed
+bogus-priv
 
 # Log queries for debugging (disable in production)
 #log-queries
```

### /etc/dnsmasq.d/root.key (new file)
```
# DNSSEC trust anchor - root zone KSK
# Update from: https://www.internic.org/domain/root.zone
. 172800 IN DS 20326 8 2 E05396B2B93D5033 B07656336985D985 65C0A35A 8D19C432
```

### /etc/init.d/S50dnsmasq
```
 #!/bin/sh
 
+# Verify DNSSEC trust anchor exists
+if [ ! -f /etc/dnsmasq.d/root.key ]; then
+    echo "Warning: DNSSEC trust anchor missing, DNSSEC disabled"
+    sed -i 's/^dnssec=/#dnssec=/' /etc/dnsmasq.conf
+fi
+
 case "$1" in
     start)
         echo "Starting dnsmasq..."
```

## Verification

```bash
# Check dnsmasq is listening on correct interfaces
netstat -unl | grep :53

# Test DNSSEC validation
dig sigok.verisignlabs.com +dnssec
# Should return NOERROR with RRSIG

dig sigfail.verisignlabs.com +dnssec
# Should return SERVFAIL (invalid DNSSEC)

# Verify dnsmasq config
dnsmasq --test

# Check for DNSSEC queries in logs
logread | grep dnssec
```

## Notes

- Requires dnsmasq compiled with DNSSEC support (check `dnsmasq -V | grep DNSSEC`)
- Trust anchor must be updated periodically (automate via cron or use `dnssec-archive`)
- Some ISPs may not support DNSSEC; fallback to upstream without validation is handled automatically
- Binding to specific interfaces prevents DNS amplification attacks from external interfaces
