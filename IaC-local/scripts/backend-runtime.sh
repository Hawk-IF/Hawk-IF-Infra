#!/usr/bin/env bash

set -euo pipefail

readonly ACTION="${1:-up}"

readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

readonly COMPOSE_FILE="${BASE_DIR}/compose/docker-compose.backend.yaml"

readonly PATH_ENV_FILE="${BASE_DIR}/secrets/.env.path"

"${BASE_DIR}/scripts/config-secrets.sh" backend

set -a
source "${PATH_ENV_FILE}"
set +a

readonly BACKEND_PROJECT_DIR="${BACKEND_PROJECT_DIR:-}"

export BACKEND_PROJECT_DIR

case "${ACTION}" in

  up)

    echo "========================================"
    echo "Hawk IF - Backend"
    echo "========================================"

    echo
    echo "=== Validating Compose ==="

    docker compose \
      -f "${COMPOSE_FILE}" \
      config > /dev/null

    echo "Compose configuration is valid."

    echo
    echo "=== Starting backend ==="

    docker compose \
     -f "${COMPOSE_FILE}" \
      up \
      -d \
      --no-build \
      --remove-orphans

    # if [[ -n "${BACKEND_PROJECT_DIR}" && -d "${BACKEND_PROJECT_DIR}" ]]; then
    #     docker compose \
    #      -f "${COMPOSE_FILE}" \
    #      run \
    #      -d \
    #      --rm -v ${BACKEND_PROJECT_DIR}api:/app/api
    #      api
    # fi

    echo
    echo "Backend started."

    ;;

  down)

    echo "========================================"
    echo "Hawk IF - Backend DOWN"
    echo "========================================"

    echo

    echo "=== Stopping backend ==="

    docker compose \
      -f "${COMPOSE_FILE}" \
      down \
      --remove-orphans

    echo
    echo "Backend stopped."

    ;;

  *)

    echo "Usage:"
    echo
    echo "  $0 up"
    echo "  $0 down"

    exit 1

    ;;

esac