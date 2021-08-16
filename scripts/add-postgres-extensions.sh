#!/usr/bin/env bash

set -ue

: "${DB_HOST:=postgres}"
: "${DB_PORT:=5432}"
: "${DB_USERNAME:=postgres}"
: "${DB_PASSWORD:=postgres}"
: "${DB_NAME:=postgres}"

if [[ -z ${DB_HOST} ]]; then
  echo "Check the variable is set: DB_HOST"
  env | grep DB
  exit 1
fi

if [[ -z ${DB_PORT} ]]; then
  echo "Check the variable is set: DB_PORT"
  env | grep DB
  exit 1
fi

if [[ -z ${DB_PASSWORD} ]]; then
  echo "Check the variable is set: DB_PASSWORD"
  env | grep DB
  exit 1
fi

if [[ -z ${DB_USERNAME} ]]; then
  echo "Check the variable is set: DB_USERNAME"
  env | grep DB
  exit 1
fi

TABLES=( "template1" "${DB_NAME}" )
EXTENSIONS_COMMAND=$(
  cat <<EOF
    do
    \$\$
      declare ext text;
      begin foreach ext in array array['dblink', 'intarray', 'pg_stat_statements', 'pg_trgm']
        loop
          execute 'create extension if not exists ' || ext;
        end loop;
      end
    \$\$;
EOF
)

for table in "${TABLES[@]}"; do
  echo "Creating PostgreSQL extensions for table ${table}..."
  PGPASSWORD=${DB_PASSWORD} psql -h ${DB_HOST} \
    -p ${DB_PORT} \
    -U ${DB_USERNAME} \
    -d "${table}" \
    -c "${EXTENSIONS_COMMAND}"
done
