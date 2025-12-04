FROM httpd:latest

# Copy index.html to Apache root directory
COPY ./src/index.html /usr/local/apache2/htdocs/index.html
