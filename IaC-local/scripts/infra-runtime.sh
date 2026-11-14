#!/usr/bin/env bash

set -euo pipefail

readonly ACTION="${1:-up}"

readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

readonly COMPOSE_FILE="${BASE_DIR}/compose/docker-compose.infra.yaml"

readonly INFRA_ENV_FILE="${BASE_DIR}/secrets/.env.infra"

"${BASE_DIR}/scripts/config-secrets.sh" infra

set -a
source "${INFRA_ENV_FILE}"
set +a

readonly NGINX_PORT="${NGINX_PORT:-8080}"

case "${ACTION}" in

  up)

    echo "========================================"
    echo "Hawk IF - Infrastructure UP"
    echo "========================================"

    echo
    echo "=== Validating Compose ==="

    docker compose \
      -f "${COMPOSE_FILE}" \
      config > /dev/null

    echo "Compose configuration is valid."

    echo
    echo "=== Starting infrastructure ==="

    docker compose \
      -f "${COMPOSE_FILE}" \
      up \
      -d \
      --remove-orphans

    echo
    echo "=== Waiting for Nginx health ==="

    ATTEMPTS=30

    for ((i=1; i<=ATTEMPTS; i++)); do

      STATUS="$(
        docker compose \
          -f "${COMPOSE_FILE}" \
          ps -q nginx \
          | xargs -r docker inspect \
            --format='{{.State.Health.Status}}' \
          2>/dev/null || true
      )"

      if [[ "${STATUS}" == "healthy" ]]; then
        echo "Infrastructure is healthy."
        exit 0
      fi

      echo "Infrastructure is not healthy yet (${i}/${ATTEMPTS})."

      sleep 2

    done

    echo
    echo "Infrastructure failed health check."

    echo
    echo "=== Infrastructure services ==="

    docker compose \
      -f "${COMPOSE_FILE}" \
      ps

    echo
    echo "=== Nginx logs ==="

    docker compose \
      -f "${COMPOSE_FILE}" \
      logs \
      --tail=100 \
      nginx

    exit 1
    ;;

  down)

    echo "========================================"
    echo "Hawk IF - Infrastructure DOWN"
    echo "========================================"

    echo
    echo "=== Stopping infrastructure ==="

    docker compose \
      -f "${COMPOSE_FILE}" \
      down \
      --remove-orphans

    echo
    echo "Infrastructure stopped."
    ;;

  *)

    echo "Usage:"
    echo
    echo "  $0 up"
    echo "  $0 down"
    echo
    exit 1
    ;;

esac