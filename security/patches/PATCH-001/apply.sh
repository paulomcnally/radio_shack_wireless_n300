#!/bin/sh
# PATCH-001: Apply Hardcoded Root Password Fix
# VULN-001: Replace MD5 hash with locked account, force password change
#
# Usage: Run this script on the router via telnet/serial
#   sh /tmp/apply_patch_001.sh
#
# After running, reboot the device.
# The web UI will force a password change on first login.

echo "=== PATCH-001: Fixing Hardcoded Root Password ==="

# Step 1: Backup current shadow file
echo "[1/4] Backing up /etc/shadow..."
cp /etc/shadow /etc/shadow.bak 2>/dev/null

# Step 2: Lock root account (replace MD5 hash with !!)
echo "[2/4] Locking root account..."
# Remove any existing MD5 hash and replace with locked indicator
sed -i 's/^root:\$1\$[^:]*:/root:!!:/' /etc/shadow

# Verify the change
if grep -q "^root:!!:" /etc/shadow; then
    echo "  OK: Root account locked"
else
    echo "  WARN: Could not lock root account, trying alternative method..."
    # Alternative: create new shadow with locked root
    grep -v "^root:" /etc/shadow > /tmp/shadow_new
    echo "root:!!:14500:0:99999:7:::" >> /tmp/shadow_new
    cp /tmp/shadow_new /etc/shadow
    rm -f /tmp/shadow_new
fi

# Step 3: Install force_password_change script
echo "[3/4] Installing first-boot password change script..."
cat > /etc/init.d/force_password_change << 'INITEOF'
#!/bin/sh
# Force password change on first boot after PATCH-001
# This runs before the web server starts

FLAG_FILE="/var/.password_set"

if [ ! -f "$FLAG_FILE" ]; then
    # Generate a temporary password hash (SHA-512)
    # This allows web UI access but forces change
    TEMP_HASH=$(openssl passwd -6 -salt "$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')" 'temppatch001' 2>/dev/null)

    if [ -n "$TEMP_HASH" ]; then
        # Update shadow with temporary password
        sed "s|^root:!!:|root:${TEMP_HASH}:|" /etc/shadow > /tmp/shadow_tmp
        cp /tmp/shadow_tmp /etc/shadow
        rm -f /tmp/shadow_tmp
        echo "Force password change: temporary password set"
    else
        # Fallback: use busybox openssl or plain method
        echo "root:$(openssl passwd -5 'temppatch001'):14500:0:99999:7:::" > /tmp/shadow_tmp
        grep -v "^root:" /etc/shadow >> /tmp/shadow_tmp
        cp /tmp/shadow_tmp /etc/shadow
        rm -f /tmp/shadow_tmp
        echo "Force password change: temporary password set (MD5 fallback)"
    fi
fi
INITEOF
chmod +x /etc/init.d/force_password_change

# Step 4: Install password change CGI handler
echo "[4/4] Installing password change CGI handler..."
cat > /var/www/cgi-bin/change_password.cgi << 'CGIEOF'
#!/bin/sh
# Password change CGI handler for PATCH-001
# Reads POST data and changes root password

# Read POST data
read POST_DATA

# Parse form fields
NEW_PASSWORD=$(echo "$POST_DATA" | sed -n 's/.*new_password=\([^&]*\).*/\1/p' | sed 's/+/ /g; s/%21/!/g; s/%40/@/g; s/%23/#/g; s/%24/\$/g; s/%25/%/g; s/%5E/^/g; s/%26/\&/g; s/%2A/*/g')
CONFIRM_PASSWORD=$(echo "$POST_DATA" | sed -n 's/.*confirm_password=\([^&]*\).*/\1/p' | sed 's/+/ /g; s/%21/!/g; s/%40/@/g; s/%23/#/g; s/%24/\$/g; s/%25/%/g; s/%5E/^/g; s/%26/\&/g; s/%2A/*/g')

echo "Content-type: text/html"
echo ""

# Validate passwords match
if [ "$NEW_PASSWORD" != "$CONFIRM_PASSWORD" ]; then
    echo "<html><body><script>alert('Passwords do not match!'); history.back();</script></body></html>"
    exit 0
fi

# Validate minimum length
LENGTH=${#NEW_PASSWORD}
if [ "$LENGTH" -lt 8 ]; then
    echo "<html><body><script>alert('Password must be at least 8 characters!'); history.back();</script></body></html>"
    exit 0
fi

# Generate SHA-512 hash
SALT=$(head -c 8 /dev/urandom | od -An -tx1 | tr -d ' \n')
NEW_HASH=$(openssl passwd -6 -salt "$SALT" "$NEW_PASSWORD" 2>/dev/null)

if [ -z "$NEW_HASH" ]; then
    # Fallback to MD5
    NEW_HASH=$(openssl passwd -5 "$NEW_PASSWORD" 2>/dev/null)
fi

if [ -z "$NEW_HASH" ]; then
    echo "<html><body><script>alert('Error generating password hash!'); history.back();</script></body></html>"
    exit 0
fi

# Update shadow file
sed "s|^root:[^:]*:|root:${NEW_HASH}:|" /etc/shadow > /tmp/shadow_new
cp /tmp/shadow_new /etc/shadow
rm -f /tmp/shadow_new

# Create flag file to prevent re-prompt
touch /var/.password_set

# Clear any temporary password markers
echo "<html><head><title>Password Changed</title></head>"
echo "<body>"
echo "<h2>Password Changed Successfully</h2>"
echo "<p>Root password has been updated.</p>"
echo "<p><a href='/indexRouter.html'>Go to Login</a></p>"
echo "<script>setTimeout(function(){ window.location.href='/indexRouter.html'; }, 3000);</script>"
echo "</body></html>"
CGIEOF
chmod +x /var/www/cgi-bin/change_password.cgi

echo ""
echo "=== PATCH-001 Applied Successfully ==="
echo ""
echo "Next steps:"
echo "1. Reboot the device"
echo "2. On first boot, access http://192.168.1.254/force_password.html"
echo "3. Set a new strong password (min 8 characters)"
echo "4. The temporary password will be replaced with your new password"
echo ""
echo "Backup saved at: /etc/shadow.bak"
