# init-db

## Environment Variables

 | Env Variable | Example Value | Description | 
 | --- | --- | --- | 
 | INIT_DB_TYPE | mysql | Type of the DB, (Currently only support MySQL)
 | INIT_DB_HOST | 172.17.0.1 | Host address of the DB |
 | INIT_DB_PORT | 3306 | Port for the DB connection |
 | INIT_DB_USER | root | Username for the DB |
 | INIT_DB_PASSWORD | my-secret-pw | Password form the DB|


## Build Docker Image

```
$ docker build -t init-db .
```

## Execute DB Migarion Manually

```
$ cd sql && ./up.sh
```

## Rollback DB to a Specific Version

```
$ cd sql

# Replace 'myfirstdb' with actual name of the database
$ export DB_NAME=myfirstdb 

$ envsubst < ./db_template.yaml > "$DB_NAME.yaml"

# Replace 20240517001 with the actual version
$ ROLLBACK_VERSION="20240517001"

$ sql-migrate down --version "$ROLLBACK_VERSION" --config="$DB_NAME.yaml" --env env
```