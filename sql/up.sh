#!/bin/sh

set -e

if [ -z "$INIT_DB_TYPE" ] || [ -z "$INIT_DB_HOST" ] || [ -z "$INIT_DB_PORT" ] || [ -z "$INIT_DB_USER" ] || [ -z "$INIT_DB_PASSWORD" ]; then
    echo "Error: One or more required environment variables are not set."
    exit 1
fi

DIR=$( cd "$( dirname "$0" )" && pwd )
MYSQL_CMD="mysql -h ${INIT_DB_HOST} -P ${INIT_DB_PORT} --user=${INIT_DB_USER} --password=${INIT_DB_PASSWORD}"
TIMEOUT=60

if ! command -v mysql &> /dev/null; then
    echo "Error: mysql command not found."
    exit 1
fi

wait_for_db() {
    local start_time=$(date +%s)
    local end_time=$((start_time + TIMEOUT))

    until $MYSQL_CMD \
    --execute="SELECT 1;" \
    &>/dev/null; do
        echo "Waiting for the DB to be ready ..."
        sleep 3
        local current_time=$(date +%s)
        if [ "$current_time" -ge "$end_time" ]; then
            echo "Timeout: unable to connect to the database with in ${TIMEOUT} seconds."
            exit 1
        fi
    done
}

wait_for_db

grep -v '^#' "$DIR/DB_LIST" | while IFS= read -r DB_NAME
do
    export DB_NAME="${DB_NAME}"
    echo "Creating ${DB_NAME} config"
    envsubst < "${DIR}/db_template.yaml" > "${DIR}/$DB_NAME.yaml"

    # create database
    $MYSQL_CMD \
    --execute="CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

    # db migration
    MIGRATION_ARG="--config=${DIR}/${DB_NAME}.yaml --env env"

    echo "Before migration status:"
    sql-migrate status ${MIGRATION_ARG}
    
    MIGRATE_CMD="sql-migrate up ${MIGRATION_ARG}"
    echo "$MIGRATE_CMD"
    $MIGRATE_CMD

    echo "After migration status:"
    sql-migrate status ${MIGRATION_ARG}
done