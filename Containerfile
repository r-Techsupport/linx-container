FROM golang:1.22-alpine3.20 AS build

RUN set -ex \
        && apk add --no-cache --virtual .build-deps git

COPY linx-server /app
WORKDIR /app
RUN mkdir dist && go build -o dist/

FROM alpine:3.20

COPY --from=build /app/dist/linx-server /app/linx-server

ENV SSL_CERT_FILE /etc/ssl/cert.pem

COPY linx-server/static /app/static/
COPY linx-server/templates /app/templates/

RUN mkdir -p /data/files && mkdir -p /data/meta && mkdir -p /data/locks && chown -R 65534:65534 /data

VOLUME ["/data/files", "/data/meta", "/data/locks"]

EXPOSE 8080
USER nobody
ENTRYPOINT ["/app/linx-server", "-bind=0.0.0.0:8080", "-filespath=/data/files/", "-metapath=/data/meta/", "-lockspath=/data/locks/"]
CMD ["-sitename=linx", "-allowhotlink"]