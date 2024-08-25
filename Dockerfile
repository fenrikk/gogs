FROM golang:1.20-alpine AS builder

WORKDIR /app

COPY . .

RUN go build -o gogs

FROM alpine:3.17

RUN apk add --no-cache git ca-certificates

RUN mkdir -p /usr/local/bin/gogs
WORKDIR /usr/local/bin/gogs

COPY --from=builder /app/gogs .

CMD ["./gogs", "web"]
