FROM golang:1.26.1-bookworm AS builder
ARG GITHUB_TOKEN
ARG GITHUB_ACTOR
WORKDIR /build
ENV GOPRIVATE=github.com/luxfi/*
ENV GONOSUMDB=github.com/luxfi/*
ENV GONOSUMCHECK=github.com/luxfi/*
RUN git config --global url."https://${GITHUB_ACTOR}:${GITHUB_TOKEN}@github.com/".insteadOf "https://github.com/"
COPY go.mod ./
RUN rm -f go.sum && go mod download
COPY . .
RUN go mod tidy && CGO_ENABLED=0 go build -o zoo-evm .

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY --from=builder /build/zoo-evm /usr/local/bin/zoo-evm
ENTRYPOINT ["zoo-evm"]
