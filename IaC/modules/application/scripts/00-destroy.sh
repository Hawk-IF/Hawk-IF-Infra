#!/usr/bin/env bash

set -euo pipefail

echo "[INFO] Removendo aplicação..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(realpath "$SCRIPT_DIR/../docker")"

: "${ENV_FILE_DOCKER_RESOURCES_PATH:?Arquivo de recursos Docker não definido}"

destroy_service() {
  local service="$1"

  docker compose \
    --env-file "$ENV_FILE_DOCKER_RESOURCES_PATH" \
    -f "$DOCKER_DIR/$service/docker-compose.yaml" \
    down
}

destroy_service redis
destroy_service database
destroy_service nginx

echo "[INFO] Aplicação removida!"