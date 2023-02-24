FROM golang:latest

WORKDIR /app

COPY ./go.mod ./
COPY ./go.sum ./
COPY ./src/ ./src/

RUN go mod download
RUN go build -o api ./src/cmd/app/main.go

# CMD ["/app/api"]
