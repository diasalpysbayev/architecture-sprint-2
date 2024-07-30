# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными и получаем количество документов на шардах

```shell
./scripts/mongo-init.sh
```

## Чтобы посмотреть общее количество документов
```shell
docker exec -it mongos_router mongosh --port 27023 
use somedb
db.helloDoc.countDocuments() 
```

## Чтобы посмотреть общее количество реплик
```shell
docker exec -it mongodb2 mongosh
rs.conf();
exit();
```
