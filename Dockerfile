FROM httpd:2.4.43-alpine

ARG UID=1001

RUN apk update && apk upgrade && \
    apk add --no-cache build-base bash libcurl apache2 libxml2 apache2-utils

RUN addgroup -g ${UID} -S appgroup && \
    adduser -u ${UID} -S appuser -G appgroup

RUN chown -R appuser:appgroup /usr/local/

COPY build/ /usr/local/apache2/htdocs/
COPY httpd.conf /usr/local/apache2/conf/

USER ${UID}