FROM httpd:latest

RUN apt-get update && apt-get install -y gettext-base postgresql-client

COPY ./src/index.html.template /usr/local/apache2/htdocs/index.html.template
COPY db_fetch.sh /db_fetch.sh

RUN chmod +x /db_fetch.sh

CMD ["/db_fetch.sh"]

