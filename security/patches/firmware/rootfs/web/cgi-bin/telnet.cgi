#!/bin/sh

# CGI script to toggle Telnet daemon on/off
# VULN-002 fix: Telnet disabled by default, configurable via web UI

echo "Content-type: text/html"
echo ""

# Parse query string for ACTION parameter
ACTION=""
for param in $(echo "$QUERY_STRING" | tr '&' ' '); do
    key=$(echo "$param" | cut -d'=' -f1)
    value=$(echo "$param" | cut -d'=' -f2)
    if [ "$key" = "ACTION" ]; then
        ACTION="$value"
    fi
done

case "$ACTION" in
    enable)
        touch /var/etc/telnet_enabled
        /usr/sbin/telnetd &
        logger "Telnet daemon enabled via web UI"
        echo "<html><body><script>alert('Telnet enabled');window.location='/system.html';</script></body></html>"
        ;;
    disable)
        rm -f /var/etc/telnet_enabled
        killall telnetd 2>/dev/null
        logger "Telnet daemon disabled via web UI"
        echo "<html><body><script>alert('Telnet disabled');window.location='/system.html';</script></body></html>"
        ;;
    status)
        if [ -f /var/etc/telnet_enabled ]; then
            echo "enabled"
        else
            echo "disabled"
        fi
        ;;
    *)
        echo "<html><body>Invalid action</body></html>"
        ;;
esac