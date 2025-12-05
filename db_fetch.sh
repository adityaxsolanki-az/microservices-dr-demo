#!/bin/bash

source /usr/local/apache2/htdocs/.env

handle_write_request() {
    export QUERY_STRING=$(echo "$REQUEST_URI" | cut -d '?' -f2)
    /db_write.sh
    exit 0
}

while true; do

    REQUEST_URI=$(echo "$REQUEST_URI")

    # If request starts with /write → INSERT to DB
    if [[ "$REQUEST_URI" == /write* ]]; then
        handle_write_request
    fi

    # Fetch latest row
    LATEST_ROW=$(psql "host=$DB_HOST user=$DB_USER password=$DB_PASS dbname=$DB_NAME" \
      -t -c "SELECT msg, created_at FROM dr_test ORDER BY id DESC LIMIT 1;")

    DB_MESSAGE=$(echo "$LATEST_ROW" | awk -F '|' '{print $1}')
    DB_TIMESTAMP=$(echo "$LATEST_ROW" | awk -F '|' '{print $2}' | sed 's/ //')

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

    envsubst < /usr/local/apache2/htdocs/index.html.template \
      > /usr/local/apache2/htdocs/index.html

    httpd-foreground &
    sleep 1
done
