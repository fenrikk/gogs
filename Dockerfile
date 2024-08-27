FROM golang:1.20-alpine AS builder

WORKDIR /app

COPY . .

RUN go build -o gogs

FROM alpine:3.17

RUN apk --no-cache --no-progress add \
  bash \
  ca-certificates \
  curl \
  git \
  linux-pam \
  openssh \
  shadow \
  socat \
  tzdata \
  rsync \
  gettext

RUN adduser -D -h /home/git -s /bin/bash git

RUN mkdir -p /usr/local/bin/gogs /gogs-repositories /usr/local/bin/gogs/custom/conf
WORKDIR /usr/local/bin/gogs

COPY --from=builder /app/gogs .
COPY docker/app.ini.template /usr/local/bin/gogs/custom/conf/app.ini.template

RUN chown -R git:git /usr/local/bin/gogs /gogs-repositories

USER git

VOLUME /gogs-repositories

COPY docker/create_app_ini.sh /create_app_ini.sh
USER root
RUN chmod +x /create_app_ini.sh
USER git

ENTRYPOINT ["/create_app_ini.sh"]
CMD ["./gogs", "web"]