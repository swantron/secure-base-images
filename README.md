# Secure Base Images

Minimal, security-hardened base image for static Go binaries. Distroless, non-root, zero vulnerabilities.

## Usage

```dockerfile
FROM swantron/secure-base:latest
COPY myapp /app
ENTRYPOINT ["/app"]
```

## Features

- Distroless base (no shell, no package manager)
- Non-root user (uid 65532)
- Automated Trivy security scanning
- Build fails on CRITICAL/HIGH vulnerabilities

## Setup

1. **Add GitHub Secrets:**
   - `DOCKERHUB_USERNAME`
   - `DOCKERHUB_TOKEN`

2. **Create a release:**
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

The workflow automatically builds, scans, and publishes to Docker Hub.

## License

MIT