#!/usr/bin/env bash

URL=${1:-localhost:3000}

echo -n "check 404 ... "
res='HTTP/1.1 404
Content-Type: application/json
Content-Length: 22

{"Chirp!": "Chirp!"}
'
diff --strip-trailing-cr \
  <(curl -s -D - $URL/unknown | tr -d '\r') \
  <(echo -n "$res")
echo ok!


echo -n "check jwt_key ... "
curl -s $URL/jwt_key | jq -e '.pub | length > 10' > /dev/null
echo ok!


echo -n "check bird registration ..."
res='{"bid":1,"name":"peepchirp","role":"worker"}'
diff --strip-trailing-cr \
  <(curl -s $URL/bird --data '{"name": "PeepChirp"}' | tr -d '\r\n') \
  <(echo -n "$res")
echo ok!


echo -n "check duplicate bird registration ..."
curl -s $URL/bird --data '{"name": "PeepChirp"}' \
  | jq -e '.error | test("UNIQUE constraint failed")' \
  > /dev/null
echo ok!



echo -n "check dog registration ..."
res='{"error": "Invalid bird name"}'
diff --strip-trailing-cr \
  <(curl -s $URL/bird --data '{"name": "Fido"}' | tr -d '\r\n') \
  <(echo -n "$res")
echo ok!


echo -n "check bird authentication ..."
curl -s $URL/bird/login --data '{"name": "PeepChirp"}' \
  | jq -e '.jwt | length > 10' > /dev/null
echo ok!
