FROM ubuntu

RUN apt-get update && apt-get install -y --no-install-recommends \
  unzip curl bash jq ncat openssl sqlite3 xxd \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY *.sh lib/

CMD ["lib/test_all.sh"]
