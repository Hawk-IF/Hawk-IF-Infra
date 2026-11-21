#!/usr/bin/env bash

set -euo pipefail

echo "[INFO] Verificando instalação do Docker Compose..."

# Verifica se o Docker está instalado
if ! command -v docker &> /dev/null; then
  echo "[ERROR] Docker não está instalado."
  echo "[INFO] Execute primeiro o install-docker.sh."
  exit 1
fi

# Verifica se o Compose já está instalado
if docker compose version &> /dev/null; then
  echo "[OK] Docker Compose já instalado: $(docker compose version)"
  exit 0
fi

# Verifica privilégios administrativos
if ! command -v sudo &> /dev/null; then
  echo "[ERROR] sudo não está instalado."
  exit 1
fi

sudo -v

# Identifica a distribuição
if [ ! -f /etc/os-release ]; then
  echo "[ERROR] Não foi possível identificar a distribuição."
  exit 1
fi

source /etc/os-release

echo "[INFO] Distribuição identificada: ${ID}"

case "$ID" in
  ubuntu|debian)
    sudo apt-get update
    sudo apt-get install -y docker-compose-plugin
    ;;

  fedora)
    sudo dnf install -y docker-compose-plugin
    ;;

  centos|rhel|rocky|almalinux)
    if command -v dnf &> /dev/null; then
      sudo dnf install -y docker-compose-plugin
    else
      sudo yum install -y docker-compose-plugin
    fi
    ;;

  arch)
    sudo pacman -Syu --needed --noconfirm docker-compose
    ;;

  *)
    echo "[ERROR] Distribuição não suportada: ${ID}"
    exit 1
    ;;
esac

# Validação final
if ! docker compose version; then
  echo "[ERROR] Falha ao validar Docker Compose."
  exit 1
fi

echo "[OK] Docker Compose instalado com sucesso!"
