#!/bin/bash
# ─────────────────────────────────────────────────────────
#  webz-monitor.sh
#  Runs every 5 min via Jenkins.
#  Curls the floating IP, logs: timestamp + node name + response.
#  Uses >> so records are APPENDED, never overwritten.
# ─────────────────────────────────────────────────────────

FLOATING_IP="172.20.0.100"
PORT="80"
LOG_FILE="/var/log/webz/monitor.log"

mkdir -p /var/log/webz

RUN_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# set +e so that a non-zero curl exit doesn't abort the script under sh -xe
set +e
HTTP_RESPONSE=$(curl -s --max-time 10 "http://${FLOATING_IP}:${PORT}")
CURL_EXIT=$?
set -e

if [ $CURL_EXIT -ne 0 ]; then
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "Time     : $RUN_TIME"                     >> "$LOG_FILE"
    echo "Status   : FAILED (curl exit code: $CURL_EXIT)" >> "$LOG_FILE"
    echo "Node     : unreachable"                   >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    exit 1
fi

# grep returns exit 1 when there's no match; || true prevents sh -xe from aborting
SERVING_NODE=$(echo "$HTTP_RESPONSE" | grep "Served by" | sed 's/<[^>]*>//g' | xargs || true)

echo "----------------------------------------" >> "$LOG_FILE"
echo "Time     : $RUN_TIME"                     >> "$LOG_FILE"
echo "Node     : $SERVING_NODE"                 >> "$LOG_FILE"
echo "Response : $HTTP_RESPONSE"                >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

echo "Done. Logged response from: $SERVING_NODE"
