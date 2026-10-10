# Dockerfile - multi-arch capable, using pre-built binary
# Build binary first (host): cargo build --release --target <target-triple>
#   amd64:  cargo build --release --target x86_64-unknown-linux-musl
#   arm64:  cargo build --release --target aarch64-unknown-linux-musl
# Build frontend first: cd frontend && npm install && npm run build
#
# podman: podman build --platform linux/arm64 -t IMAGE -f Dockerfile .
# docker: TARGETARCH is provided automatically by docker buildx

FROM alpine:3.19

# TARGETARCH: amd64 | arm64 (auto-set by docker buildx; default arm64 for local podman builds)
ARG TARGETARCH=arm64

RUN apk add --no-cache ca-certificates tzdata

WORKDIR /app

# Copy pre-built binary for the target architecture
COPY target/${TARGETARCH}-unknown-linux-musl/release/reader-rust /app/reader-rust

# Copy frontend dist
COPY frontend/dist /app/web/dist

# Create storage directory
RUN mkdir -p /app/storage/assets

# Environment defaults
ENV SERVER_HOST=0.0.0.0
ENV SERVER_PORT=8080
ENV DATABASE_URL=sqlite:/app/storage/reader.db?mode=rwc
ENV STORAGE_DIR=/app/storage
ENV ASSETS_DIR=/app/storage/assets
ENV WEB_ROOT=/app/web/dist
ENV LOG_LEVEL=info

EXPOSE 8080

VOLUME ["/app/storage"]

CMD ["./reader-rust"]
