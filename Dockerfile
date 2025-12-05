FROM httpd:latest

RUN apt-get update && apt-get install -y gettext-base postgresql-client bc

# Enable CGI module
RUN sed -i 's/#LoadModule cgid_module/LoadModule cgid_module/' /usr/local/apache2/conf/httpd.conf

# Add CGI configuration
RUN echo "" >> /usr/local/apache2/conf/httpd.conf && \
    echo "# --- Custom CGI Configuration ---" >> /usr/local/apache2/conf/httpd.conf && \
    echo "ScriptAlias /fetch /usr/local/apache2/cgi-bin/db_fetch.sh" >> /usr/local/apache2/conf/httpd.conf && \
    echo "ScriptAlias /write /usr/local/apache2/cgi-bin/db_write.sh" >> /usr/local/apache2/conf/httpd.conf && \
    echo "<Directory \"/usr/local/apache2/cgi-bin\">" >> /usr/local/apache2/conf/httpd.conf && \
    echo "    AllowOverride None" >> /usr/local/apache2/conf/httpd.conf && \
    echo "    Options +ExecCGI" >> /usr/local/apache2/conf/httpd.conf && \
    echo "    Require all granted" >> /usr/local/apache2/conf/httpd.conf && \
    echo "    AddHandler cgi-script .sh" >> /usr/local/apache2/conf/httpd.conf && \
    echo "</Directory>" >> /usr/local/apache2/conf/httpd.conf

COPY src/index.html.template /usr/local/apache2/htdocs/index.html.template
COPY db_fetch.sh /usr/local/apache2/cgi-bin/db_fetch.sh
COPY db_write.sh /usr/local/apache2/cgi-bin/db_write.sh
COPY .env /usr/local/apache2/cgi-bin/.env

RUN chmod +x /usr/local/apache2/cgi-bin/*.sh

CMD ["httpd-foreground"]
