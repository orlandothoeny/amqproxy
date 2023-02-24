FROM 84codes/crystal:latest-alpine AS builder
WORKDIR /tmp
COPY shard.yml shard.lock ./
RUN shards install --production
COPY src/ src/
RUN shards build --production --release --debug

FROM alpine:latest
RUN apk add --no-cache libssl1.1 pcre libevent libgcc \
    && addgroup --gid 1000 amqpproxy \
    && adduser --no-create-home --disabled-password --uid 1000 amqpproxy -G amqpproxy
COPY --from=builder /tmp/bin/amqproxy /usr/bin/amqproxy
USER 1000:1000
EXPOSE 5673
ENTRYPOINT ["/usr/bin/amqproxy", "--listen=0.0.0.0"]
