# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

Заполняем mongodb данными и получаем количество документов на шардах

```shell
docker exec -it configSrv mongosh --port 27017
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27017" }
    ]
  }
);
exit();
```

```shell
docker exec -it shard1 mongosh --port 27018
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27018" },
      ]
    }
);
exit();
```

```shell
docker exec -it shard2 mongosh --port 27019
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 1, host : "shard2:27019" }
      ]
    }
);
exit();
```

```shell
docker exec -it mongos_router mongosh --port 27020
sh.addShard( "shard1/shard1:27018");
sh.addShard( "shard2/shard2:27019");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments()
```

```shell
docker compose exec -T shard1 mongosh --port 27018 --quiet
use somedb
db.helloDoc.countDocuments()
```

```shell
docker compose exec -T shard2 mongosh --port 27019 --quiet
use somedb
db.helloDoc.countDocuments()
```

## Чтобы посмотреть общее количество документов
```shell
docker exec -it mongos_router mongosh --port 27020 
use somedb
db.helloDoc.countDocuments() 
```
