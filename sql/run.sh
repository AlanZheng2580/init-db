#!/bin/bash

set -e

if [ -z "$INIT_DB_TYPE" ] || [ -z "$INIT_DB_HOST" ] || [ -z "$INIT_DB_PORT" ] || [ -z "$INIT_DB_USER" ] || [ -z "$INIT_DB_PASSWORD" ]; then
    echo "Error: One or more required environment variables are not set."
    exit 1
fi

DIR=$( cd "$( dirname "$0" )" && pwd )
MYSQL_CMD="mysql -h ${INIT_DB_HOST} -P ${INIT_DB_PORT} --user=${INIT_DB_USER} --password=${INIT_DB_PASSWORD}"
TIMEOUT=60

pushd "$DIR"

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

# usage: show_db_status $DIR $DB_NAME
show_db_status() {
    local dir_path=$1
    local db_name=$2
    sql-migrate status --config="${dir_path}/${db_name}.yaml" --env env
}

# usage: generate_db_config $DIR $DB_NAME
generate_db_config() {
    local dir_path=$1
    local db_name=$2
    export DB_NAME="${db_name}"
    envsubst < "${dir_path}/db_template.yaml" > "${dir_path}/$db_name.yaml"
}

up() {
    grep -v '^#' "$DIR/DB_LIST" | while IFS= read -r DB_NAME
    do
        echo "Creating ${DB_NAME} config"
        generate_db_config "$DIR" "$DB_NAME"

        # create database
        $MYSQL_CMD \
        --execute="CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

        # db migration
        MIGRATION_ARG="--config=${DIR}/${DB_NAME}.yaml --env env"

        echo "Before ${DB_NAME} migration status:"
        show_db_status "$DIR" "$DB_NAME"
        
        MIGRATE_CMD="sql-migrate up ${MIGRATION_ARG}"
        echo "$MIGRATE_CMD"
        $MIGRATE_CMD

        echo "After ${DB_NAME} migration status:"
        show_db_status "$DIR" "$DB_NAME"
    done
}

# usage: down $DB_NAME $VERSION
down() {
    local db_name=$1
    local db_version=$2

    echo "Creating ${db_name} config"
    generate_db_config "$DIR" "$db_name"

    # db migration
    MIGRATION_ARG="--version $db_version --config=${DIR}/${db_name}.yaml --env env"

    echo "Before ${db_name} migration status:"
    show_db_status "$DIR" "$db_name"
    
    MIGRATE_CMD="sql-migrate down ${MIGRATION_ARG}"
    echo "$MIGRATE_CMD"
    $MIGRATE_CMD

    echo "After ${db_name} migration status:"
    show_db_status "$DIR" "$db_name"
}

wait_for_db

CMD_ERROR_MSG="Invalid command: $@. Please provide 'up' or 'down DB VERSION'."
if [ "$1" == "up" ]; then
    if [ $# -ne 1 ]; then
        echo "$CMD_ERROR_MSG"
        exit 1
    fi
    up
elif [ "$1" == "down" ]; then
    if [ $# -ne 3 ]; then
        echo "$CMD_ERROR_MSG"
        exit 1
    fi
    down "$2" "$3"
else
    echo "$CMD_ERROR_MSG"
    exit 1
fi

popd