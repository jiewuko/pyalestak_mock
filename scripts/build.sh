#!/usr/bin/env bash

SCRIPT_PATH=$(cd `dirname "${BASH_SOURCE[0]}"` && pwd)
ROOT_PATH=$(cd ${SCRIPT_PATH} && cd .. && pwd)
: ${AWS_REGION:=us-east-1}
: ${PROJECT_NAME:=statistics}
: ${DOCKER_FILE:=Dockerfile}


function build_show_help() {
    echo "-n => set repository name"
    echo "-t => set tags, comma delimited"
    echo "-p => push images"
    echo "-c => clear local dangling images and containers"
}


function clear() {
    containers=$(docker ps -aq)
    if [[ ! -z "${containers}" ]]; then
        docker stop ${containers}
        docker rm -f ${containers}
    fi
    images=$(docker images -f "dangling=true" --format '{{.ID}}')
    if [[ ! -z "${images}" ]]; then
        docker rmi -f ${images}
    fi
    docker volume prune -f
    docker network prune -f
    docker system prune -f
}

function build_cmd_params() {

    TAG=""
    PUSH=""
    CLEAR=""

    while getopts ":h?pct:" opt; do
        case "$opt" in
            h|\?)
                build_show_help
                exit 0
                ;;
            t)  TAG=$OPTARG
                ;;
            p)  PUSH="true"
                ;;
            c)  CLEAR="true"
                ;;
        esac
    done

}

function get_repository_url() {
  local repository=$(aws --region=${AWS_REGION} ecr describe-repositories --output text --query 'repositories[?repositoryName==`'${PROJECT_NAME}'`].repositoryUri')
  echo ${repository}
}

function get_ecr_login() {
    eval $(aws ecr get-login --no-include-email)
}

function build() {
    local repo_name=$1
    shift
    echo "Building docker image: name => ${repo_name}, Dockerfile => ${DOCKER_FILE}"
    docker build -t ${repo_name} -f ${DOCKER_FILE} "${@}" .
    if [[ -n ${TAG} ]]; then
        tags=$(echo ${TAG} | sed -e 's/,\s*/\n/g' )
        for tag in ${tags}; do
            new_name="${repo_name}:${tag}"
            echo "Tagging docker image: ${repo_name} => ${new_name}"
            docker tag ${repo_name} ${new_name}
        done
    fi
}

function push() {
    local repo_name=$1
    echo "Pushing docker image: name => ${repo_name}"
    docker push ${repo_name}
    if [[ -n ${TAG} ]]; then
        tags=$(echo ${TAG} | sed -e 's/,\s*/\n/g' )
        for tag in ${tags}; do
            new_name="${repo_name}:${tag}"
            echo "Pushing docker image: name => ${new_name}"
            docker push ${new_name}
        done
    fi
}

function main() {
    local repository=$(get_repository_url)
    build ${repository} "${@}"
    if [[ ! -z ${PUSH} ]]; then
        get_ecr_login
        push ${repository}
    fi
    if [[ ! -z ${CLEAR} ]]; then
        echo "Clearing dangling images..."
        clear
    fi
}

build_cmd_params "${@}"
shift $((OPTIND-1))
main "${@}"
