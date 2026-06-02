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

# --- make sure log dir exists ---
mkdir -p /var/log/webz

# --- timestamp for this run ---
RUN_TIME=$(date '+%Y-%m-%d %H:%M:%S')

# --- curl the floating IP ---
# -s  = silent (no progress bar)
# -o  = write response body to variable
# -w  = write HTTP status code after
# --max-time 10 = fail after 10s so job doesn't hang
HTTP_RESPONSE=$(curl -s --max-time 10 "http://${FLOATING_IP}:${PORT}")
CURL_EXIT=$?

# --- extract the serving node name from the response HTML ---
# The index.html page contains: "Served by: webz-00X"
# grep pulls that line, then sed strips the HTML tags
SERVING_NODE=$(echo "$HTTP_RESPONSE" | grep "Served by" | sed 's/<[^>]*>//g' | xargs)

# --- handle curl failure (e.g. cluster is down) ---
if [ $CURL_EXIT -ne 0 ]; then
    echo "----------------------------------------" >> "$LOG_FILE"
    echo "Time     : $RUN_TIME"                     >> "$LOG_FILE"
    echo "Status   : FAILED (curl exit code: $CURL_EXIT)" >> "$LOG_FILE"
    echo "Node     : unreachable"                   >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
    exit 1
fi

# --- append the record ---
echo "----------------------------------------" >> "$LOG_FILE"
echo "Time     : $RUN_TIME"                     >> "$LOG_FILE"
echo "Node     : $SERVING_NODE"                 >> "$LOG_FILE"
echo "Response : $HTTP_RESPONSE"                >> "$LOG_FILE"
echo "----------------------------------------" >> "$LOG_FILE"

echo "Done. Logged response from: $SERVING_NODE"