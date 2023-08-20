FROM ubuntu

RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates gcc build-essential \
  unzip curl bash jq ncat openssl sqlite3 xxd \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Install boon the JSON Schema validator
RUN \
  curl "https://sh.rustup.rs" -sSf | sh -s -- -y \
  && ~/.cargo/bin/cargo install --example boon boon \
  && mv ~/.cargo/bin/boon /bin

# Install redpanda CLI
RUN \
  curl -sL -o rpk.zip \
    "https://github.com/redpanda-data/redpanda/releases/download/v23.2.4/rpk-linux-amd64.zip" \
  && unzip rpk.zip \
  && rm rpk.zip \
  && chmod +x rpk \
  && mv rpk /bin/

COPY *.sh lib/

CMD ["lib/test_all.sh"]
