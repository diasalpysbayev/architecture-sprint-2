#!/bin/bash

#docker exec -it redis_1 redis_1<<EOF
#echo "yes" | redis-cli --cluster create   173.17.0.2:6379   173.17.0.3:6379   173.17.0.4:6379   173.17.0.5:6379   173.17.0.6:6379   173.17.0.7:6379   --cluster-replicas 1
#EOF

docker exec -it mongodb2 mongosh <<EOF
rs.initiate({_id: "rs0", members: [
{_id: 0, host: "mongodb2:27017"},
{_id: 1, host: "mongodb3:27018"},
{_id: 2, host: "mongodb4:27019"}
]});
exit();
EOF

docker exec -it configSrv mongosh --port 27020 <<EOF
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
EOF

docker exec -it shard1 mongosh --port 27021 <<EOF
rs.initiate(
    {
      _id : "shard1",
      members: [
        { _id : 0, host : "shard1:27021" },
      ]
    }
);
exit();
EOF

docker exec -it shard2 mongosh --port 27022 <<EOF
rs.initiate(
    {
      _id : "shard2",
      members: [
        { _id : 1, host : "shard2:27022" }
      ]
    }
  );
exit();
EOF

docker exec -it mongos_router mongosh --port 27023 <<EOF
sh.addShard( "shard1/shard1:27021");
sh.addShard( "shard2/shard2:27022");
sh.enableSharding("somedb");
sh.shardCollection("somedb.helloDoc", { "name" : "hashed" } )
use somedb
for(var i = 0; i < 1000; i++) db.helloDoc.insert({age:i, name:"ly"+i})
db.helloDoc.countDocuments()
EOF

docker compose exec -T shard1 mongosh --port 27021 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF

docker compose exec -T shard2 mongosh --port 27022 --quiet <<EOF
use somedb
db.helloDoc.countDocuments()
EOF
