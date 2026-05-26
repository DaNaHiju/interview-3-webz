FROM ubuntu:18.04

ENV container=docker
ENV DEBIAN_FRONTEND=noninteractive

# Install required HA packages + dbus
RUN apt-get update && apt-get install -y \
    dbus \
    pacemaker \
    corosync \
    pcs \
    apache2 \
    curl \
    iputils-ping \
    net-tools \
    iproute2 \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set hacluster password (used by pcs cluster auth)
RUN echo "hacluster:hacluster" | chpasswd

# Copy Apache VirtualHost config
COPY apache/webz.conf /etc/apache2/sites-available/webz.conf
RUN a2dissite 000-default.conf && a2ensite webz.conf

# Copy homepage — HOSTNAME placeholder replaced at runtime
COPY apache/index.html /var/www/html/index.html

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

CMD ["/entrypoint.sh"]