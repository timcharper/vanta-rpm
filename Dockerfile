# Dockerfile.vanta
FROM debian:bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates lsb-release procps && \
  rm -rf /var/lib/apt/lists/*

RUN curl --progress-bar -L https://app.vanta.com/osquery/download/linux > /tmp/vanta-amd64.deb

# Discoverable default workdir
WORKDIR /opt/vanta
