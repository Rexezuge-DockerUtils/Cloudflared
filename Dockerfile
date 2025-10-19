FROM rexezugedockerutils/upx AS upx

FROM debian:12 AS builder

COPY --from=upx /upx /usr/local/bin/upx

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential curl unzip zlib1g-dev libpcre2-dev perl ca-certificates

RUN curl -L -o /tmp/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
 && chmod +x /tmp/cloudflared \
 && upx --best --lzma /tmp/cloudflared

FROM scratch

COPY --from=builder /tmp/cloudflared /cloudflared

ENTRYPOINT ["/cloudflared"]
