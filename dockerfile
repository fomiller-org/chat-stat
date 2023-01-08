FROM golang:latest

RUN mkdir /app

ADD ./src/ /app/
ADD ./go.mod /app/
ADD ./go.sum /app/

WORKDIR /app

RUN go mod tidy
RUN go build -o api ./src/cmd/app/main.go

CMD ["/app/api"]
