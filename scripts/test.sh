#!/usr/bin/env bash

set -eo pipefail

function build_show_help() {
    echo "-l => check code with linters"
    echo "-s => skip tests"
}

function build_cmd_params() {

    while getopts ":h?ls" opt; do
        case "$opt" in
            h|\?)
                build_show_help
                exit 0
                ;;
            l)  LINT="true"
                ;;
            s)  TESTS="false"
                ;;
        esac
    done

}

LINT=false
TESTS=true
COVERAGE_REPORT_FILE="$(mktemp -u -t tmp.XXXXXXXXXX)"
: "${COVERAGE_LIMIT:=80}"
RED='\033[0;31m'
NC='\033[0m'

build_cmd_params "${@}"
shift $((OPTIND-1))

trap '{ rm -f "${COVERAGE_REPORT_FILE}"; }' EXIT

function lint() {
    flake8 && mypy .
}

function testing() {
    pytest --color=yes --cov-report term --cov "${@}" | tee "${COVERAGE_REPORT_FILE}"
    total=$(awk '/TOTAL/ { gsub("%", ""); print $4 }' < "${COVERAGE_REPORT_FILE}")
    total=$((total+0))
    if [[ ${total} -lt ${COVERAGE_LIMIT} ]];then
        echo -e "${RED}Current test coverage: ${total}%. Required test coverage: ${COVERAGE_LIMIT}%${NC}";
        exit 1;
    fi
}

if [[ "${LINT}" = "true" ]]; then
    lint
    exit_code=$?
    [[ ${exit_code} -ne 0 ]] && exit ${exit_code}
fi

if [[ "${TESTS}" = "true" ]]; then
    testing "${@}"
    exit_code=$?
    [[ ${exit_code} -ne 0 ]] && exit ${exit_code}
fi

exit 0
