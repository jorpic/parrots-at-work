

После долгих споров с руководством так и не удалось убедить их ослабить
требование о том, что у задачи сразу же должна быть назначена цена. При
текущей архитектуре это добавляет синхронную зависимость между сервисами
трекера задач и биллинга.

---

На тайной встрече технических лидеров всех отделов решили, что если никто
нигде не видит задачи без цены, то их как бы и нет. Поэтому цена будет
назначаться асинхронно, но все будут пользоваться вьюшкой, которая скрывает
неоценённые задачи.

---

Руководство неожиданно уволило главного архитектора, а оставшихся техлидов
отправили учиться на курс по асинхронной архитектуре.