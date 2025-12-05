#!/bin/bash

source /usr/local/apache2/cgi-bin/.env

# Extract query string
RAW_QUERY="$QUERY_STRING"
MESSAGE=$(echo "$RAW_QUERY" | sed 's/msg=//g' | sed 's/+/\ /g')

# If empty, fallback
[ -z "$MESSAGE" ] && MESSAGE="(empty)"

# Insert into correct table
psql -q "host=$DB_HOST user=$DB_USER password=$DB_PASS dbname=$DB_NAME" \
  -c "INSERT INTO dr_messages(message, region) VALUES('$MESSAGE', '$REGION');" >/dev/null 2>&1

# Redirect user back to dashboard
echo "Status: 302 Found"
echo "Location: /fetch"
echo ""
