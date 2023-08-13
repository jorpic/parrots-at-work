# parrots-at-work

 - [Архитектура](./doc/README.md)


Запустить всё:
```
$ ./start.sh
```

Посмотреть как работает:
```
$ task/test.sh
```

<details>
<summary>Тут простыня с результатом</summary>
```
======== create a bird
{"bid":1,"name":"peepchirp","role":"worker"}

======== login

======== create a task
[{"tid":1,"created_at":"2023-08-13 15:03:20","status":"created","title":"sudo make me a sandwich","fee":18,"reward":23,"assigned_to":1}]

======== get all tasks...
{"tid":1,"assigned_to":1,"fee":18,"reward":23,"status":"created"}

======== complete nonexistent task
{"error":"Task not found"}

======== complete the task
{"tid":1,"title":"sudo make me a sandwich","status":"completed","assigned_to":1}

======== complete the same task again
{"error":"Already completed"}

======== add more workers
{"bid":2,"name":"peep","role":"worker"}
{"bid":3,"name":"peeppeep","role":"worker"}
{"bid":4,"name":"peeppeepchirp","role":"worker"}
{"bid":5,"name":"peeppeepchirptweet","role":"worker"}
{"bid":6,"name":"peeppeepchirptweetchirrup","role":"manager"}
{"bid":7,"name":"peeppeepchirptweetchirruppeep","role":"admin"}

======== add more tasks
{"tid":1,"assigned_to":1,"fee":18,"reward":23,"status":"completed"}
{"tid":2,"assigned_to":4,"fee":12,"reward":20,"status":"created"}
{"tid":3,"assigned_to":4,"fee":16,"reward":39,"status":"created"}
{"tid":4,"assigned_to":3,"fee":18,"reward":28,"status":"created"}
{"tid":5,"assigned_to":5,"fee":10,"reward":23,"status":"created"}
{"tid":6,"assigned_to":5,"fee":10,"reward":26,"status":"created"}
{"tid":7,"assigned_to":3,"fee":12,"reward":36,"status":"created"}
{"tid":8,"assigned_to":5,"fee":14,"reward":38,"status":"created"}

======== shuffle as a worker
{"error": "You are not a manager!"}

======== register a manager
{"bid":8,"name":"chirpchirp","role":"manager"}

======== login as a manager

======== shuffle
{"done": true}
{"tid":1,"assigned_to":1,"fee":18,"reward":23,"status":"completed"}
{"tid":2,"assigned_to":3,"fee":12,"reward":20,"status":"created"}
{"tid":3,"assigned_to":5,"fee":16,"reward":39,"status":"created"}
{"tid":4,"assigned_to":2,"fee":18,"reward":28,"status":"created"}
{"tid":5,"assigned_to":2,"fee":10,"reward":23,"status":"created"}
{"tid":6,"assigned_to":2,"fee":10,"reward":26,"status":"created"}
{"tid":7,"assigned_to":4,"fee":12,"reward":36,"status":"created"}
{"tid":8,"assigned_to":1,"fee":14,"reward":38,"status":"created"}

======== shuffle
{"done": true}
{"tid":1,"assigned_to":1,"fee":18,"reward":23,"status":"completed"}
{"tid":2,"assigned_to":2,"fee":12,"reward":20,"status":"created"}
{"tid":3,"assigned_to":1,"fee":16,"reward":39,"status":"created"}
{"tid":4,"assigned_to":5,"fee":18,"reward":28,"status":"created"}
{"tid":5,"assigned_to":5,"fee":10,"reward":23,"status":"created"}
{"tid":6,"assigned_to":2,"fee":10,"reward":26,"status":"created"}
{"tid":7,"assigned_to":4,"fee":12,"reward":36,"status":"created"}
{"tid":8,"assigned_to":3,"fee":14,"reward":38,"status":"created"}
```
</details>
