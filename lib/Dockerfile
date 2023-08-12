FROM ubuntu

RUN apt-get update && apt-get install -y --no-install-recommends \
  unzip curl bash jq ncat openssl sqlite3 xxd \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install redpanda CLI
RUN \
  curl -ksL -o rpk.zip \
    "https://github.com/redpanda-data/redpanda/releases/download/v23.2.4/rpk-linux-amd64.zip" \
  && unzip rpk.zip \
  && rm rpk.zip \
  && chmod +x rpk \
  && mv rpk /bin/

COPY *.sh lib/

CMD ["lib/test_all.sh"]
