FROM golang:latest

WORKDIR /app

COPY ./src/ ./src/
COPY ./go.mod ./
COPY ./go.sum ./

RUN go mod download
RUN go build -o api ./src/cmd/app/main.go

CMD ["/app/api"]
