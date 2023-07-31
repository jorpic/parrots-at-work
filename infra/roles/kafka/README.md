
Based on https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-20-04

Requires `sudo` so please include it like this:

```
---
- hosts: prod
  roles:
    - { role: kafka, become: yes }
```
