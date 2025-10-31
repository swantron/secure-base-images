# Security Policy

## Reporting a Vulnerability

Email security issues to: [joe@swantroncom]

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact

## Security Features

- Distroless runtime (no shell/package manager)
- Non-root user execution (uid 65532)
- Automated Trivy scanning for CRITICAL/HIGH vulnerabilities
- Multi-stage builds
- Build fails if vulnerabilities detected
