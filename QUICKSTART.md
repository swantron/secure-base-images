# Quick Start

Get your secure base image published to Docker Hub in 10 minutes.

## 1. Create Docker Hub Token

1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name: `GitHub Actions`, Permissions: Read, Write, Delete
4. Copy the token

## 2. Add GitHub Secrets

Go to repo Settings → Secrets → Actions, add:
- `DOCKERHUB_USERNAME` - your Docker Hub username
- `DOCKERHUB_TOKEN` - token from step 1

## 3. Release

```bash
git tag v1.0.0
git push origin v1.0.0
```

Create a GitHub Release from the tag. The workflow will automatically build, scan, and publish.

## 4. Verify

```bash
docker pull YOUR_USERNAME/secure-base:latest
```

Done! Your image is live on Docker Hub.
