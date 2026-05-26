#!/bin/bash
# Inject real container hostname into the homepage
sed -i "s/HOSTNAME/$(hostname)/g" /var/www/html/index.html

# 1. Start dbus (required by pacemaker and pcsd)
mkdir -p /run/dbus
dbus-daemon --system --fork

# 2. Start corosync
corosync

# 3. Start pacemaker
/usr/sbin/pacemakerd &

# 4. Start pcsd (use init.d — correct for Ubuntu 18.04)
/etc/init.d/pcsd start

# 5. Start Apache
/usr/sbin/apache2ctl start

echo "=== All services started on $(hostname) ==="

# Keep container alive
tail -f /var/log/corosync/corosync.log 2>/dev/null || tail -f /dev/null