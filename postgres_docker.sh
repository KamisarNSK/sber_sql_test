docker run --name postgres_sber \
           --rm \
           --detach \
           --publish 5432:5432 \
           --env POSTGRES_DB=sber \
           --env POSTGRES_USER=sber \
           --env POSTGRES_PASSWORD=sber \
           postgres:latest
