#Create networks
docker network create --driver overlay frontend
docker network create --driver overlay backend

#Vote
docker service create --name vote --network frontend --replicas 2 -p 80:80 bretfisher/examplevotingapp_vote
#Redis
docker service create --name redis --network frontend --replicas 1 redis:3.2
#Worker
docker service create \
    --name worker \
    --network frontend  \
    --network backend  \
    --replicas 1 \
    bretfisher/examplevotingapp_worker:java
#db
docker service create \
    --name db \
    --network backend \
    --replicas 1  \
    -e POSTGRES_HOST_AUTH_METHOD=trust \
    --mount type=volume,source=worker-volume,destination=/var/lib/postgresql/data \
    postgres:9.4
#Result
docker service create \
    --name result \
    --network backend \
    -p 5001:80 \
    --replicas 1 \
    bretfisher/examplevotingapp_result
