#!/bin/bash
set -euo pipefail

echo "- Automatic CloudFlare set_real_ip updating tool";
echo "https://npm-config-generator.lael.app/set_real_ip";
echo "https://www.cloudflare.com/ips/";
echo ""
sleep 1

CONF_FILE="/etc/nginx/conf.d/_set_real_ip.conf"
TMP_FILE=$(mktemp)

echo "TARGET_PATH : $CONF_FILE"
echo ""
sleep 1

# IPv4
mapfile -t ips_v4 < <(curl -fsSL https://www.cloudflare.com/ips-v4/)
for ip in "${ips_v4[@]}"; do
    echo "set_real_ip_from $ip;" >> "$TMP_FILE"
done

# IPv6
mapfile -t ips_v6 < <(curl -fsSL https://www.cloudflare.com/ips-v6/)
for ip in "${ips_v6[@]}"; do
    echo "set_real_ip_from $ip;" >> "$TMP_FILE"
done

# Add real_ip_header setting
echo "real_ip_header X-Forwarded-For;" >> "$TMP_FILE"

# Line count validation
LINE_COUNT=$(wc -l < "$TMP_FILE")
if (( LINE_COUNT < 15 || LINE_COUNT > 40 )); then
    echo "Invalid data (LINE_COUNT: $LINE_COUNT). ABORT."
    rm -f "$TMP_FILE"
    exit 1
fi

echo "#################################"
cat "$TMP_FILE"
echo "#################################"
echo ""

# Update (Overwrite)
mv "$TMP_FILE" "$CONF_FILE"
chmod 600 "$CONF_FILE"

if nginx -t; then
    systemctl reload nginx
    echo "Cloudflare IP update completed."
else
    echo "nginx config test failed. Please check manually."
    exit 1
fi
