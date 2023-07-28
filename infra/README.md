
Check hosts availability:

```bash
$ ansible -i hosts all -m ping
```

Install deps:

```bash
$ ansible-playbook -i hosts deps.yaml
```
