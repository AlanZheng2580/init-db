FROM golang:1.22.3-alpine3.18 AS build

RUN go install github.com/rubenv/sql-migrate/...@latest

FROM alpine:3.18.6

RUN apk add --no-cache mysql-client zip unzip wget bash curl gettext \
    && rm -rf /tmp/* \
    && rm -fr /var/cache/apk/*
WORKDIR /usr/bin/app
COPY --from=build /go/bin /bin
COPY ./sql ./sql
COPY entrypoint.sh .
RUN chmod +x ./entrypoint.sh ./sql/run.sh
ENTRYPOINT [ "/bin/bash", "-c" ]
CMD ["/usr/bin/app/entrypoint.sh"]