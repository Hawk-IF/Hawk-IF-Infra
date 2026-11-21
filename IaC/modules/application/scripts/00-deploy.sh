#!/usr/bin/env bash

set -euo pipefail

echo "[INFO] Iniciando implantação..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCKER_DIR="$(realpath "$SCRIPT_DIR/../docker")"

: "${PROJECT_NAME:?PROJECT_NAME não definida}"
: "${ENVIRONMENT:?ENVIRONMENT não definida}"
: "${ENV_FILE_DOCKER_RESOURCES_PATH:?Arquivo de recursos Docker não definido}"

: "${POSTGRES_DB:?POSTGRES_DB não definida}"
: "${POSTGRES_USER:?POSTGRES_USER não definida}"
: "${POSTGRES_PASSWORD:?POSTGRES_PASSWORD não definida}"
: "${REDIS_PASSWORD:?REDIS_PASSWORD não definida}"

deploy_service() {
  local service="$1"

  docker compose \
    --env-file "$ENV_FILE_DOCKER_RESOURCES_PATH" \
    -f "$DOCKER_DIR/$service/docker-compose.yaml" \
    up -d
}

deploy_service nginx
deploy_service database
deploy_service redis

echo "[INFO] Implantação concluída!"