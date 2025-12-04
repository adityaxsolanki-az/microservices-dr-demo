#!/bin/bash
DB_MESSAGE=$(psql "host=${DB_HOST} user=${DB_USER} dbname=${DB_NAME} password=${DB_PASS} sslmode=require" \
    -t -c "SELECT msg FROM dr_test ORDER BY id DESC LIMIT 1;")

# Query DB
DB_MESSAGE=$(psql "host=${DB_HOST} user=${DB_USER} dbname=${DB_NAME} password=${DB_PASS} sslmode=require" \
    -t -c "SELECT msg FROM dr_test ORDER BY id DESC LIMIT 1;")

# Fallback if DB unreachable
if [ -z "$DB_MESSAGE" ]; then
    DB_MESSAGE="Unable to fetch from DB"
fi

# First substitute ENV variables (REGION etc)
envsubst < /usr/local/apache2/htdocs/index.html.template \
> /tmp/rendered.html

# Then insert DB message
sed "s|{{ DB_MESSAGE }}|$DB_MESSAGE|" /tmp/rendered.html \
> /usr/local/apache2/htdocs/index.html

# Start apache
httpd-foreground
