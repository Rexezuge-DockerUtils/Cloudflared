FROM rexezugedockerutils/upx AS upx

FROM debian:stable AS builder

COPY --from=upx /upx /usr/local/bin/upx

RUN apt-get update \
 && apt-get install -y --no-install-recommends build-essential curl unzip zlib1g-dev libpcre2-dev perl ca-certificates

RUN ARCH=$(dpkg --print-architecture) \
 && if [ "$ARCH" = "amd64" ]; then CLOUDFLARED_ARCH="amd64_linux"; \
    elif [ "$ARCH" = "arm64" ]; then CLOUDFLARED_ARCH="arm64_linux"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi \
 && curl -L -o /tmp/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-${CLOUDFLARED_ARCH} \
 && chmod +x /tmp/cloudflared \
 && upx --best --lzma /tmp/cloudflared

FROM scratch

COPY --from=builder /tmp/cloudflared /cloudflared

ENTRYPOINT ["/cloudflared"]
