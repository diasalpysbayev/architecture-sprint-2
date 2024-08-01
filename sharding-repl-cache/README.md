# pymongo-api

## Как запустить

Запускаем mongodb и приложение

```shell
docker compose up -d
```

```shell
docker exec -it redis_1 sh
echo "yes" | redis-cli --cluster create 127.0.0.1:6379 127.0.0.1:6379 127.0.0.1:6379 127.0.0.1:6379 127.0.0.1:6379 127.0.0.1:6379 --cluster-replicas 1
exit
```

Заполняем mongodb данными и получаем количество документов на шардах

```shell
docker exec -it configSrv mongosh --port 27020
rs.initiate(
  {
    _id : "config_server",
       configsvr: true,
    members: [
      { _id : 0, host : "configSrv:27020" }
    ]
  }
);
  
exit();
```

```shell
docker exec -it shard1 mongosh --port 27021
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27021" },
      ]
    }
);
  
exit();

rs.initiate({_id: "rs0", members: [
  {_id: 0, host: "mongodb2:27017"}
]});

exit();
```

```shell
docker exec -it shard1 mongosh --port 27021
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27021" },
      ]
    }
);
  
exit();

rs.initiate({_id: "rs0", members: [
  {_id: 0, host: "mongodb2:27017"}
]});

exit();

```

```shell
docker exec -it shard2 mongosh --port 27022
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 1, host : "shard2:27022" }
      ]
    }
  );
    
exit();

rs.initiate({_id: "rs0", members: [
  {_id: 1, host: "mongodb3:27018"},
  {_id: 2, host: "mongodb4:27019"}
]});

exit();

```

```shell
docker exec -it mongos_router mongosh --port 27023
sh.addShard( "shard1/shard1:27021");
sh.addShard( "shard2/shard2:27022");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments()
```

```shell
docker compose exec -T shard1 mongosh --port 27021 --quiet
use somedb
db.helloDoc.countDocuments()
```

```shell
docker compose exec -T shard2 mongosh --port 27022 --quiet
use somedb
db.helloDoc.countDocuments()
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
