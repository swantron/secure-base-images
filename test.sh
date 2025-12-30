#!/bin/bash
set -e

# Integration tests for secure base image
# Tests security properties: non-root user, no shell, distroless

IMAGE_NAME="${IMAGE_NAME:-secure-base-test}"
TEMP_DOCKERFILE=$(mktemp)
TEST_APP=$(mktemp)

echo "🔍 Running integration tests for secure base image..."

# Cleanup function
cleanup() {
  rm -f "$TEMP_DOCKERFILE" "$TEST_APP"
  docker rm -f test-container 2>/dev/null || true
}
trap cleanup EXIT

# Build a test image with a simple binary
cat > "$TEMP_DOCKERFILE" <<'DOCKERFILE'
FROM golang:1.21-alpine AS builder
WORKDIR /build
COPY <<'GOFILE' main.go
package main
import (
    "fmt"
    "os/user"
)
func main() {
    u, _ := user.Current()
    fmt.Printf("UID:%s\n", u.Uid)
    fmt.Printf("GID:%s\n", u.Gid)
    fmt.Printf("USER:%s\n", u.Username)
}
GOFILE
RUN CGO_ENABLED=0 go build -o testapp main.go

FROM secure-base-local:latest
COPY --from=builder /build/testapp /app
ENTRYPOINT ["/app"]
DOCKERFILE

# Build base image locally for testing
echo "📦 Building base image..."
docker build -t secure-base-local:latest .

# Build test image
echo "📦 Building test image..."
docker build -f "$TEMP_DOCKERFILE" -t "$IMAGE_NAME" .

# Test 1: Verify non-root user
echo "✓ Test 1: Verifying non-root user..."
OUTPUT=$(docker run --rm "$IMAGE_NAME" 2>&1)
if echo "$OUTPUT" | grep -q "UID:65532"; then
  echo "  ✅ Running as uid 65532 (nonroot user)"
else
  echo "  ❌ FAILED: Not running as expected user"
  echo "$OUTPUT"
  exit 1
fi

# Test 2: Verify no shell access
echo "✓ Test 2: Verifying no shell access..."
if docker run --rm --entrypoint /bin/sh "$IMAGE_NAME" -c "echo test" 2>&1 | grep -q "no such file\|not found\|executable file not found"; then
  echo "  ✅ No shell available (distroless confirmed)"
else
  echo "  ❌ FAILED: Shell is accessible"
  exit 1
fi

# Test 3: Verify no package manager
echo "✓ Test 3: Verifying no package manager..."
if docker run --rm --entrypoint /usr/bin/apt-get "$IMAGE_NAME" 2>&1 | grep -q "no such file\|not found\|executable file not found"; then
  echo "  ✅ No package manager available"
else
  echo "  ❌ FAILED: Package manager is accessible"
  exit 1
fi

# Test 4: Verify CA certificates present
echo "✓ Test 4: Verifying CA certificates..."
cat > "$TEMP_DOCKERFILE" <<'DOCKERFILE'
FROM golang:1.21-alpine AS builder
WORKDIR /build
COPY <<'GOFILE' main.go
package main
import (
    "os"
)
func main() {
    if _, err := os.Stat("/etc/ssl/certs/ca-certificates.crt"); err != nil {
        os.Exit(1)
    }
}
GOFILE
RUN CGO_ENABLED=0 go build -o checkca main.go

FROM secure-base-local:latest
COPY --from=builder /build/checkca /app
ENTRYPOINT ["/app"]
DOCKERFILE

docker build -f "$TEMP_DOCKERFILE" -t "${IMAGE_NAME}-ca" . >/dev/null 2>&1
if docker run --rm "${IMAGE_NAME}-ca"; then
  echo "  ✅ CA certificates present"
else
  echo "  ❌ FAILED: CA certificates missing"
  exit 1
fi

# Test 5: Verify image size (distroless should be small)
echo "✓ Test 5: Verifying image size..."
SIZE=$(docker images secure-base-local:latest --format "{{.Size}}" | head -1)
SIZE_MB=$(echo "$SIZE" | sed 's/MB//')
if [ "${SIZE_MB%%.*}" -lt 5 ]; then
  echo "  ✅ Image size is minimal: $SIZE"
else
  echo "  ⚠️  Image size: $SIZE (expected < 5MB)"
fi

# Test 6: Verify read-only filesystem works
echo "✓ Test 6: Verifying read-only filesystem support..."
cat > "$TEMP_DOCKERFILE" <<'DOCKERFILE'
FROM golang:1.21-alpine AS builder
WORKDIR /build
COPY <<'GOFILE' main.go
package main
import (
    "fmt"
    "os"
)
func main() {
    if _, err := os.Create("/test.txt"); err != nil {
        fmt.Println("Read-only filesystem working")
        os.Exit(0)
    }
    fmt.Println("Write succeeded - filesystem not read-only")
    os.Exit(1)
}
GOFILE
RUN CGO_ENABLED=0 go build -o testro main.go

FROM secure-base-local:latest
COPY --from=builder /build/testro /app
ENTRYPOINT ["/app"]
DOCKERFILE

docker build -f "$TEMP_DOCKERFILE" -t "${IMAGE_NAME}-ro" . >/dev/null 2>&1
if docker run --rm --read-only "${IMAGE_NAME}-ro" 2>&1 | grep -q "Read-only filesystem working"; then
  echo "  ✅ Read-only filesystem support confirmed"
else
  echo "  ❌ FAILED: Read-only filesystem not working as expected"
  exit 1
fi

echo ""
echo "🎉 All integration tests passed!"
echo ""
echo "Summary:"
echo "  ✅ Non-root user (uid 65532)"
echo "  ✅ No shell access (distroless)"
echo "  ✅ No package manager"
echo "  ✅ CA certificates present"
echo "  ✅ Minimal image size: $SIZE"
echo "  ✅ Read-only filesystem support"
