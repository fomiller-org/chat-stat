FROM golang:latest

ARG TWITCH_CLIENT_ID
ARG TWITCH_CLIENT_SECRET
ENV TWITCH_CLIENT_ID=${TWITCH_CLIENT_ID}
ENV TWITCH_CLIENT_SECRET=${TWITCH_CLIENT_SECRET}

WORKDIR /app

COPY ./channels.txt ./
COPY ./src/ ./src/
COPY ./go.mod ./
COPY ./go.sum ./

RUN go mod download
RUN go build -o api ./src/cmd/app/main.go

CMD ["/app/api"]
