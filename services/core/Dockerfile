# syntax=docker/dockerfile:1
FROM golang:1.26-alpine AS builder

RUN apk add --no-cache git

WORKDIR /workspace

COPY go.work go.work.sum ./
COPY services/gen/go.mod services/gen/go.sum ./services/gen/
COPY services/core/go.mod services/core/go.sum ./services/core/

RUN --mount=type=cache,target=/go/pkg/mod \
    cd services/core && go mod download

COPY services/gen ./services/gen
COPY services/core ./services/core

WORKDIR /workspace/services/core

RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg/mod \
    CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o app ./cmd/api/main.go

FROM alpine:3.20 AS runner

WORKDIR /app

RUN adduser -D appuser

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /workspace/services/core/app .

USER appuser

EXPOSE 8080 50051

ENTRYPOINT ["./app"]
