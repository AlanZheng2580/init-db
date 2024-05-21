# init-db

## Environment Variables

 | Env Variable | Example Value | Description | 
 | --- | --- | --- | 
 | INIT_DB_TYPE | mysql | Type of the DB, (Currently only support MySQL)
 | INIT_DB_HOST | 172.17.0.1 | Host address of the DB |
 | INIT_DB_PORT | 3306 | Port for the DB connection |
 | INIT_DB_USER | root | Username for the DB |
 | INIT_DB_PASSWORD | my-secret-pw | Password form the DB|


## Build a Docker Image

```
$ DOCKER_BUILDKIT=0 docker build -t init-db .
```

## Run a Docker Container Locally

```
$ docker run -it -e INIT_DB_TYPE=mysql -e INIT_DB_HOST=172.17.0.1 -e INIT_DB_PORT=3306 -e INIT_DB_USER=root -e INIT_DB_PASSWORD=my-secret-pw init-db
```

## Execute DB Migarions Manually

```
$ cd sql && ./up.sh
```

## Rollback the DB to a Specific Version

```
$ cd sql

# Replace 'myfirstdb' with actual name of the database
$ export DB_NAME=myfirstdb 

$ envsubst < ./db_template.yaml > "$DB_NAME.yaml"

# Replace 20240517001 with the actual version
$ ROLLBACK_VERSION="20240517001"

$ sql-migrate down --version "$ROLLBACK_VERSION" --config="$DB_NAME.yaml" --env env
```