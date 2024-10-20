FROM golang:1.22.5-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go test -cover -v ./...
RUN go build -o s3-listing
RUN chmod +x /src/s3-listing


FROM alpine:3.16

WORKDIR /app

COPY --from=builder /src/s3-listing /app/
EXPOSE 8010

CMD ["/app/s3-listing"]