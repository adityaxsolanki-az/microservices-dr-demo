#!/bin/bash

source /usr/local/apache2/htdocs/.env

# Extract query string from environment variable
RAW_QUERY="$QUERY_STRING"

# Parse GET param: msg=
MESSAGE=$(echo "$RAW_QUERY" | sed 's/msg=//g' | sed 's/+/\ /g')

if [ -z "$MESSAGE" ]; then
    MESSAGE="(empty)"
fi

# Insert into DB
psql "host=$DB_HOST user=$DB_USER password=$DB_PASS dbname=$DB_NAME" \
  -c "INSERT INTO dr_test(msg, created_at) VALUES('$MESSAGE', NOW());"

# Redirect back to homepage
echo "HTTP/1.1 302 Found"
echo "Location: /"
echo ""
