FROM golang:1.22 AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 go build -o parcel-tracker .

FROM alpine:3.19

RUN apk add --no-cache sqlite

WORKDIR /app

COPY --from=builder /app/parcel-tracker .

RUN sqlite3 tracker.db "CREATE TABLE IF NOT EXISTS parcel (number INTEGER PRIMARY KEY AUTOINCREMENT, client INTEGER NOT NULL, status VARCHAR(128) NOT NULL, address VARCHAR(512) NOT NULL, created_at TEXT NOT NULL);"

CMD ["./parcel-tracker"]