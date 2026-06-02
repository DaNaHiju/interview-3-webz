#!/bin/bash
# Inject real container hostname into the homepage
sed -i "s/HOSTNAME/$(hostname)/g" /var/www/html/index.html

# 1. Start dbus
mkdir -p /run/dbus
dbus-daemon --system --fork

# 2. Start corosync
corosync

# 3. Start pacemaker
/usr/sbin/pacemakerd &

# 4. Start pcsd
/etc/init.d/pcsd start

# 5. Start Apache
/usr/sbin/apache2ctl start

# 6. Run Pacemaker setup ONLY on webz-001
#    webz-002 and webz-003 just wait to be managed
if [ "$(hostname)" = "webz-001" ]; then
    echo "=== Running Pacemaker setup on webz-001 ==="
    /pacemaker-setup.sh &
fi

echo "=== All services started on $(hostname) ==="

# Keep container alive
tail -f /var/log/corosync/corosync.log 2>/dev/null || tail -f /dev/null