FROM alpine:3.21

WORKDIR /app

# Docker buildx 会在构建时自动填充这些变量
ARG TARGETOS
ARG TARGETARCH

RUN apk add --no-cache tzdata

# 提前 COPY 所有二进制，放在 /src，后续根据架构选择
COPY komari-* /src/

ARG TARGETPLATFORM
RUN case "${TARGETPLATFORM}" in \
    "linux/amd64") BIN_NAME="komari-linux-amd64" ;; \
    "linux/arm64") BIN_NAME="komari-linux-arm64" ;; \
    "linux/arm/v7") BIN_NAME="komari-linux-arm-v7" ;; \
    *) echo "Unsupported platform: ${TARGETPLATFORM}" && exit 1 ;; \
    esac && \
    cp /src/$BIN_NAME /app/komari && \
    chmod +x /app/komari

ENV GIN_MODE=release
ENV KOMARI_DB_TYPE=sqlite
ENV KOMARI_DB_FILE=/app/data/komari.db
ENV KOMARI_DB_HOST=localhost
ENV KOMARI_DB_PORT=3306
ENV KOMARI_DB_USER=root
ENV KOMARI_DB_PASS=
ENV KOMARI_DB_NAME=komari
ENV KOMARI_LISTEN=0.0.0.0:25774

EXPOSE 25774

CMD ["/app/komari", "server"]
