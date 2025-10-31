# Multi-stage build for secure static Go binary base image
# Build stage: contains SDK and build tools
FROM golang:1.21-alpine AS builder

# Install build dependencies
RUN apk add --no-cache git ca-certificates

WORKDIR /build

# Production stage: minimal distroless image
FROM gcr.io/distroless/static-debian12:nonroot

# Copy CA certificates from builder
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Run as non-root user (uid 65532)
USER nonroot:nonroot

# Default entrypoint - override in derived images
ENTRYPOINT ["/app"]
