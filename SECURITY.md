# Security Policy

## Reporting a Vulnerability

Email security issues to: [your-email@example.com]

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact

**Response timeline:**
- 24 hours: Acknowledgment
- 7 days: Assessment
- 30 days: Fix (if confirmed)

## Security Features

- Distroless runtime (no shell/package manager)
- Non-root user execution (uid 65532)
- Automated Trivy scanning for CRITICAL/HIGH vulnerabilities
- Multi-stage builds
- Build fails if vulnerabilities detected
