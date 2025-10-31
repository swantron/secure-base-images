# Example: Hello World with Secure Base Image

FROM golang:1.21-alpine AS builder

WORKDIR /build
COPY go.mod go.sum* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -ldflags '-extldflags "-static"' -o hello-world .

# Use the secure base image
FROM gcr.io/distroless/static-debian12:nonroot

COPY --from=builder /build/hello-world /app

EXPOSE 8080

ENTRYPOINT ["/app"]
