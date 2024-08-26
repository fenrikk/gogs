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
  rsync

RUN adduser -D -h /home/git -s /bin/bash git

RUN mkdir -p /usr/local/bin/gogs /gogs-repositories
WORKDIR /usr/local/bin/gogs

COPY --from=builder /app/gogs .

RUN chown -R git:git /usr/local/bin/gogs /gogs-repositories

USER git

VOLUME /gogs-repositories

CMD ["./gogs", "web"]