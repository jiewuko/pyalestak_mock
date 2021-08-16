#!/usr/bin/env bash

set -ue

: "${KAFKA_CONNECTION_STRING:=kafka:9092,kafka:9093}"
: "${ZOOKEEPER_CONNECTION_STRING:=zoo:2181}"
: "${SCHEMA_REGISTRY_URL:=http://schema-registry:8081}"
: "${REDIS_HOST:=redis}"
: "${REDIS_PORT:=6379}"
: "${DB_HOST:=postgres}"
: "${DB_PORT:=5432}"
: "${WAIT_KAFKA:=true}"
: "${WAIT_ZOOKEEPER:=true}"
: "${WAIT_POSTGRES:=true}"
: "${WAIT_REDIS:=true}"
: "${WAIT_SCHEMA_REGISTRY:=true}"

if [[ "${WAIT_KAFKA}" == "true" ]]; then

  if [[ -z ${KAFKA_CONNECTION_STRING} ]]; then
    echo "Check the variable is set: KAFKA_CONNECTION_STRING"
    env | grep KAFKA_
    exit 1
  fi

  KAFKA_CONNECTION="$(cut -d ',' -f 1 <<<"${KAFKA_CONNECTION_STRING}")"
  KAFKA_CONNECTION_HOST_PORT=(${KAFKA_CONNECTION//:/ })
  KAFKA_HOST=${KAFKA_CONNECTION_HOST_PORT[0]}
  KAFKA_PORT=${KAFKA_CONNECTION_HOST_PORT[1]}

  echo "Waiting for Kafka server. Host ${KAFKA_HOST}. Port ${KAFKA_PORT}"
  timeout=15
  while ! nc -z "${KAFKA_HOST}" "${KAFKA_PORT}"; do
    timeout=$((timeout - 1))
    if [[ ${timeout} -eq 0 ]]; then
      echo 'Timeout! Exiting...'
      exit 1
    fi
    echo -n '.'
    sleep 1
  done
  echo "Kafka server ${KAFKA_HOST}:${KAFKA_PORT} is alive"

fi

if [[ "${WAIT_ZOOKEEPER}" == "true" ]]; then

  if [[ -z ${ZOOKEEPER_CONNECTION_STRING} ]]; then
    echo "Check the variable is set: ZOOKEEPER_CONNECTION_STRING"
    env | grep ZOOKEEPER
    exit 1
  fi

  ZOOKEEPER_CONNECTION="$(cut -d ',' -f 1 <<<"${ZOOKEEPER_CONNECTION_STRING}")"
  ZOOKEEPER_CONNECTION_HOST_PORT=(${ZOOKEEPER_CONNECTION//:/ })
  ZOOKEEPER_HOST=${ZOOKEEPER_CONNECTION_HOST_PORT[0]}
  ZOOKEEPER_PORT=${ZOOKEEPER_CONNECTION_HOST_PORT[1]}

  echo "Waiting for Zookeeper server. Host ${ZOOKEEPER_HOST}. Port ${ZOOKEEPER_PORT}"
  timeout=15
  while ! nc -z "${ZOOKEEPER_HOST}" "${ZOOKEEPER_PORT}"; do
    timeout=$((timeout - 1))
    if [[ ${timeout} -eq 0 ]]; then
      echo 'Timeout! Exiting...'
      exit 1
    fi
    echo -n '.'
    sleep 1
  done
  echo "Zookeeper server ${ZOOKEEPER_HOST}:${ZOOKEEPER_PORT} is alive"

fi

if [[ "${WAIT_REDIS}" == "true" ]]; then

  if [[ -z ${REDIS_HOST} ]]; then
    echo "Check the variable is set: REDIS_HOST"
    env | grep REDIS
    exit 1
  fi

  if [[ -z ${REDIS_PORT} ]]; then
    echo "Check the variable is set: REDIS_PORT"
    env | grep REDIS
    exit 1
  fi

  echo "Waiting for Redis server. Host ${REDIS_HOST}. Port ${REDIS_PORT}"
  timeout=15
  while ! nc -z ${REDIS_HOST} ${REDIS_PORT}; do
    timeout=$((timeout - 1))
    if [[ ${timeout} -eq 0 ]]; then
      echo 'Timeout! Exiting...'
      exit 1
    fi
    echo -n '.'
    sleep 1
  done
  echo "Redis server ${REDIS_HOST}:${REDIS_PORT} is alive"

fi

if [[ "${WAIT_POSTGRES}" == "true" ]]; then

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

  echo "Waiting for PostgreSQL server. Host ${DB_HOST}. Port ${DB_PORT}"
  timeout=15
  while ! nc -z ${DB_HOST} ${DB_PORT}; do
    timeout=$((timeout - 1))
    if [[ ${timeout} -eq 0 ]]; then
      echo 'Timeout! Exiting...'
      exit 1
    fi
    echo -n '.'
    sleep 1
  done
  echo "PostgreSQL server ${DB_HOST}:${DB_PORT} is alive"

fi

if [[ "${WAIT_SCHEMA_REGISTRY}" == "true" ]]; then

  if [[ -z ${SCHEMA_REGISTRY_URL} ]]; then
    echo "Check the variable is set: SCHEMA_REGISTRY_URL"
    env | grep SCHEMA_REGISTRY
    exit 1
  fi

  SCHEMA_REGISTRY_CONNECTION=${SCHEMA_REGISTRY_URL#*//}
  SCHEMA_REGISTRY_HOST_PORT=(${SCHEMA_REGISTRY_CONNECTION//:/ })
  SCHEMA_REGISTRY_HOST=${SCHEMA_REGISTRY_HOST_PORT[0]}
  SCHEMA_REGISTRY_PORT=${SCHEMA_REGISTRY_HOST_PORT[1]}

  echo "Waiting for Schema Registry server. Host ${SCHEMA_REGISTRY_HOST}. Port ${SCHEMA_REGISTRY_PORT}"
  timeout=15
  while ! nc -z "${SCHEMA_REGISTRY_HOST}" "${SCHEMA_REGISTRY_PORT}"; do
    timeout=$((timeout - 1))
    if [[ ${timeout} -eq 0 ]]; then
      echo 'Timeout! Exiting...'
      exit 1
    fi
    echo -n '.'
    sleep 1
  done
  echo "Schema Registry server ${SCHEMA_REGISTRY_HOST}:${SCHEMA_REGISTRY_PORT} is alive"

  echo "Waiting for HTTP Schema Registry server. URL ${SCHEMA_REGISTRY_URL}"
  timeout=15
  while ! curl -s -o /dev/null ${SCHEMA_REGISTRY_URL}; do
    timeout=$((timeout - 1))
    if [[ ${timeout} -eq 0 ]]; then
      echo 'Timeout! Exiting...'
      exit 1
    fi
    echo -n '.'
    sleep 1
  done
  echo "Schema Registry HTTP server ${SCHEMA_REGISTRY_URL} is alive"

fi
