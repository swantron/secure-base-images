# Integration Tests

Automated tests to verify security properties of the base image.

## Running Tests

```bash
./test.sh
```

## Tests Included

1. **Non-root user** - Verifies the container runs as uid 65532 (nonroot)
2. **No shell access** - Confirms distroless image has no shell
3. **No package manager** - Ensures no apt/apk/yum available
4. **CA certificates** - Verifies SSL certificates are present
5. **Minimal size** - Checks image size is under 5MB
6. **Read-only filesystem** - Tests the image works with read-only root filesystem

## CI Integration

Tests are automatically run in GitHub Actions on every push and PR.

## Manual Testing

To run individual test scenarios:

```bash
# Build the base image
docker build -t secure-base-local:latest .

# Test non-root user
docker run --rm secure-base-local:latest id

# Test no shell
docker run --rm --entrypoint /bin/sh secure-base-local:latest
# Should fail with "not found"

# Test read-only filesystem
docker run --rm --read-only secure-base-local:latest
# Should work without errors
```
