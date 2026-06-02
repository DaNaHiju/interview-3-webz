#!/bin/bash
# ─────────────────────────────────────────────────────────
#  pacemaker-setup.sh
#  Runs on webz-001 at container startup.
#  - Always: authenticates nodes and starts the cluster
#  - First time only: creates resources and constraints
# ─────────────────────────────────────────────────────────

echo "=== Waiting for pcsd to be ready on all nodes ==="
sleep 10  # give pcsd time to start on all 3 nodes

# ── Always: authenticate and start cluster ──────────────
echo "=== Authenticating cluster nodes ==="
pcs cluster auth 172.20.0.2 172.20.0.3 172.20.0.4 \
    -u hacluster -p hacluster

echo "=== Starting cluster ==="
pcs cluster start --all
pcs cluster enable --all

# give cluster time to come up
sleep 5

# ── Always: set global properties ───────────────────────
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore

# ── First time only: create resources and constraints ───
# Check if res_floatingip already exists
if pcs resource show res_floatingip > /dev/null 2>&1; then
    echo "=== Resources already exist, skipping creation ==="
else
    echo "=== Creating resources for the first time ==="

    # Floating IP resource
    pcs resource create res_floatingip ocf:heartbeat:IPaddr2 \
        ip=172.20.0.100 cidr_netmask=24 nic=eth0 \
        op monitor interval=10s

    # Apache resource
    pcs resource create res_apache ocf:heartbeat:apache \
        configfile=/etc/apache2/apache2.conf \
        op monitor interval=10s

    # Constraints
    pcs constraint colocation add res_apache with res_floatingip INFINITY
    pcs constraint order res_floatingip then res_apache
    pcs constraint location res_floatingip prefers webz-001=200
    pcs constraint location res_floatingip prefers webz-002=100
    pcs constraint location res_floatingip prefers webz-003=50

    echo "=== Resources and constraints created ==="
fi

echo "=== Pacemaker setup complete ==="
pcs status