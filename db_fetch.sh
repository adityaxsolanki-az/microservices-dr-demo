#!/bin/bash
source /usr/local/apache2/cgi-bin/.env

echo "Content-Type: text/html; charset=UTF-8"
echo ""

# Fetch latest row
LATEST_ROW=$(psql "host=$DB_HOST user=$DB_USER password=$DB_PASS dbname=$DB_NAME" \
  -t -c "SELECT message, created_at FROM dr_messages ORDER BY id DESC LIMIT 1;")

DB_MESSAGE=$(echo "$LATEST_ROW" | awk -F '|' '{print $1}')
DB_TIMESTAMP=$(echo "$LATEST_ROW" | awk -F '|' '{print $2}')
NOW=$(date +"%Y-%m-%d %H:%M:%S")

if [ -n "$DB_TIMESTAMP" ]; then
    RPO_LAG=$(echo "$(date -d "$NOW" +%s) - $(date -d "$DB_TIMESTAMP" +%s)" | bc -l)
else
    RPO_LAG=0
fi

if (( $(echo "$RPO_LAG < 1" | bc -l) )); then
    SYNC_STATUS="<span class='green'>🟢 Fully Synced</span>"
elif (( $(echo "$RPO_LAG < 5" | bc -l) )); then
    SYNC_STATUS="<span class='yellow'>🟡 Minor Lag</span>"
else
    SYNC_STATUS="<span class='red'>🔴 Lagging</span>"
fi

export DB_MESSAGE DB_TIMESTAMP NOW RPO_LAG SYNC_STATUS REGION

envsubst < /usr/local/apache2/htdocs/index.html.template
