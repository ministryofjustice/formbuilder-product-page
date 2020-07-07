FROM httpd:latest

COPY build/ /usr/local/apache2/htdocs/
COPY httpd.conf /usr/local/apache2/conf/
