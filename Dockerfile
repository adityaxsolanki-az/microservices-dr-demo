FROM httpd:latest

# Install envsubst (template engine)
RUN apt-get update && apt-get install -y gettext-base

# Copy template file instead of static HTML
COPY ./src/index.html.template /usr/local/apache2/htdocs/index.html.template

# Replace environment variables at container startup
CMD envsubst < /usr/local/apache2/htdocs/index.html.template > /usr/local/apache2/htdocs/index.html && httpd-foreground
