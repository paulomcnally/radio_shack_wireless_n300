# PATCH-014: Replace Outdated Boa Web Server

**Vulnerability:** VULN-014 (Boa outdated)
**Complexity:** High
**Requires Recompilation:** Yes (entire boa binary)
**Risk Level:** High

## Recommended Fix

Replace the outdated Boa web server with a maintained alternative. For embedded MIPS systems, the recommended options are:

1. **lighttpd** (preferred): Lightweight, actively maintained, supports CGI, small footprint
2. **busybox httpd**: Already present on many embedded systems, minimal features
3. **Update Boa**: If a patched version is available (Boa has not been actively maintained since 2005)

## Option A: Replace with lighttpd (Recommended)

### 1. Cross-compile lighttpd for MIPS

```bash
# Download lighttpd source
wget https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.76.tar.gz
tar xzf lighttpd-1.4.76.tar.gz
cd lighttpd-1.4.76

# Cross-compile for MIPS (adjust toolchain path)
export CC=mips-linux-gnu-gcc
export STRIP=mips-linux-gnu-strip
./configure \
    --host=mips-linux-gnu \
    --prefix=/usr \
    --without-pcre \
    --without-brotli \
    --without-zstd \
    --disable-ipv6 \
    --without-openssl \
    --without-stat-cache \
    --without-lua \
    --without-webdav-props \
    --without-xml-xattr \
    --without-xmlattr \
    --without-dbi \
    --without-ldap \
    --without-pam \
    --without-fam

make
make install DESTDIR=/path/to/rootfs
```

### 2. lighttpd configuration

Create `/etc/lighttpd/lighttpd.conf`:

```conf
server.modules = (
    "mod_cgi",
    "mod_access",
    "mod_alias",
    "mod_rewrite"
)

server.document-root = "/www"
server.port = 80
server.bind = "0.0.0.0"

# Security headers
server.modules += ("mod_setenv")
setenv.add-response-header = (
    "X-Frame-Options" => "SAMEORIGIN",
    "X-Content-Type-Options" => "nosniff",
    "X-XSS-Protection" => "1; mode=block"
)

# CGI configuration
cgi.assign = (".cgi" => "/usr/bin/lua", ".asp" => "/usr/bin/lua")

# Deny access to sensitive files
$HTTP["url"] =~ "^/\.|^/cgi-bin/\." {
    url.access-deny = ("")
}

# Deny access to config files
$HTTP["url"] =~ "\.(conf|ini|log)$" {
    url.access-deny = ("")
}

mimetype.assign = (
    ".html" => "text/html",
    ".htm" => "text/html",
    ".js" => "application/javascript",
    ".css" => "text/css",
    ".png" => "image/png",
    ".jpg" => "image/jpeg",
    ".gif" => "image/gif",
    ".svg" => "image/svg+xml",
    ".ico" => "image/x-icon"
)
```

### 3. Migration steps

```bash
# Stop Boa
killall boa 2>/dev/null
/etc/init.d/boa stop 2>/dev/null

# Backup Boa config
cp -r /etc/boa /etc/boa.bak

# Install lighttpd
cp lighttpd /usr/sbin/lighttpd
chmod 755 /usr/sbin/lighttpd
mkdir -p /etc/lighttpd
# Copy lighttpd.conf from above

# Preserve existing HTML files - no changes needed
# CGI scripts should work with minor path adjustments

# Update startup script
sed -i 's/boa/lighttpd/g' /etc/init.d/rcS

# Start lighttpd
lighttpd -f /etc/lighttpd/lighttpd.conf
```

### 4. CGI compatibility layer

Ensure existing CGI scripts work. Create a wrapper if needed:

```bash
#!/bin/sh
# /usr/bin/cgi-wrapper.sh - compatibility for old CGI paths
export SCRIPT_NAME=$1
export QUERY_STRING=$2
exec /www/cgi-bin/$SCRIPT_NAME
```

## Option B: Update Boa (If Patched Version Available)

```bash
# Check for patched Boa from vendor or OpenWrt
wget http://downloads.openwrt.org/sources/boa-0.94.14.tar.gz
tar xzf boa-0.94.14.tar.gz
cd boa-0.94.14/src

# Cross-compile
./configure --host=mips-linux-gnu
make
# Replace /usr/sbin/boa with new binary
```

## Option C: Use Busybox httpd (Minimal)

```bash
# If busybox is already installed
busybox httpd -f -p 80 -h /www -c /etc/httpd.conf
```

## Verification

1. Confirm Boa is no longer running:
   ```bash
   ps | grep boa
   # Should return nothing
   ```
2. Confirm new server is running:
   ```bash
   ps | grep lighttpd
   # Should show lighttpd process
   ```
3. Test web interface functionality:
   ```bash
   curl -I http://router/
   # Should return 200 with new server headers
   ```
4. Verify CGI scripts work:
   ```bash
   curl http://router/cgi-bin/goform/getStatus
   ```
5. Check for security headers:
   ```bash
   curl -I http://router/ | grep -E "X-Frame|X-Content"
   ```

## Notes

- This is the highest complexity patch as it replaces a core system component.
- All existing HTML files should work unchanged if the document root is preserved.
- CGI scripts may need path adjustments depending on the new server's CGI configuration.
- lighttpd has a smaller memory footprint than nginx and is better suited for this class of device.
- If the device has less than 8MB RAM, consider busybox httpd instead.
- Test thoroughly on a backup device before deploying to production.
- The web interface authentication mechanism (if any) must be re-implemented for the new server.
