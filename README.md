# init-db

## Environment Variables

 | Env Variable | Example Value | Description | 
 | --- | --- | --- | 
 | INIT_DB_TYPE | mysql | Type of the DB, (Currently only support MySQL)
 | INIT_DB_HOST | 172.17.0.1 | Host address of the DB |
 | INIT_DB_PORT | 3306 | Port for the DB connection |
 | INIT_DB_USER | root | Username for the DB |
 | INIT_DB_PASSWORD | my-secret-pw | Password for the DB|

---

## Build a Docker Image

```
$ DOCKER_BUILDKIT=0 docker build -t init-db .
```

---

## Run a Docker Container

- Execute DB Migrations

```
$ docker run -it \
    -e INIT_DB_TYPE=mysql -e INIT_DB_HOST=172.17.0.1 \
    -e INIT_DB_PORT=3306 -e INIT_DB_USER=root \
    -e INIT_DB_PASSWORD=my-secret-pw \
    init-db
```

 - Rollback the DB to a Specific Version

```
# Replace 'myfirstdb' with the actual name of the database
$ export DB_NAME=myfirstdb 

# Replace 20240517001 with the actual version
$ ROLLBACK_VERSION="20240517001"

$ docker run -it \
    -e INIT_DB_TYPE=mysql -e INIT_DB_HOST=172.17.0.1 \
    -e INIT_DB_PORT=3306 -e INIT_DB_USER=root \
    -e INIT_DB_PASSWORD=my-secret-pw \
    init-db "cd /usr/bin/app/sql && ./run.sh down ${DB_NAME} ${ROLLBACK_VERSION}"
```

---
## Run It Locally
 
- Execute DB Migarions

```
$ cd sql && ./run.sh up
```

- Rollback the DB to a Specific Version

```
$ cd sql && ./run.sh down ${DB_NAME} ${ROLLBACK_VERSION}
```

---

## How to Create a New Database

1. Create a new dir.
2. Add the name of the new directory in DB_LIST.

---

## SQL File Naming Rule

- The file naming convention consists fo a timestamp followed by a unique identifier and ends with the file extension ".sql".
- The unique number must increment with each new file for each directory.