#!/usr/bin/env bash

set -ue

export SERVICE_IMAGE="${1:-${SERVICE_IMAGE:=statistics}}"
set +e
docker-compose -f docker-compose-tests.yml up --build --abort-on-container-exit --exit-code-from app
exit_code=$?
set -e
docker-compose -f docker-compose-tests.yml down -v --remove-orphans
exit ${exit_code}
