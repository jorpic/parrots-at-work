# parrots-at-work

 - [Архитектура](./doc/README.md)


```
$ docker build -t paw/lib -f lib/Dockerfile lib
...

$ docker run -it paw/lib
lib/base64url.sh
lib/ed25519.sh
    ed25519_test ... ok!
lib/http.sh
lib/jwt.sh
    jwt_test_payload ... ok!
    jwt_test_sig ... ok!

$ docker build -t paw/auth -f auth/Dockerfile auth
$ docker run -it paw/auth test_auth.sh
```
