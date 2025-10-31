# Hello World Example

Simple Go web server using the secure base image.

## Build

```bash
docker build -t hello-world .
```

## Run

```bash
docker run -p 8080:8080 hello-world
curl http://localhost:8080/
```

## Verify Security

```bash
# No shell available
docker run -it hello-world sh
# Error: executable file not found

# Scan for vulnerabilities
trivy image hello-world
```
