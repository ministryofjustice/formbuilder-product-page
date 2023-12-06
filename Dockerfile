FROM httpd:2.4.58-alpine3.18

ARG UID=1001

RUN apk update && apk upgrade && \
    apk add --no-cache build-base bash libcurl

RUN addgroup -g ${UID} -S appgroup && \
    adduser -u ${UID} -S appuser -G appgroup

COPY build/ /usr/local/apache2/htdocs/
COPY httpd.conf /usr/local/apache2/conf/

RUN chown -R appuser:appgroup /usr/local/apache2/
USER appuser
