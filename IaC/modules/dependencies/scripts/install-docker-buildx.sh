#!/usr/bin/env bash

set -euo pipefail

echo "[INFO] Verificando instalação do Docker Buildx..."

# Verifica se o Docker está instalado
if ! command -v docker &> /dev/null; then
  echo "[ERROR] Docker não está instalado."
  echo "[INFO] Execute primeiro o install-docker.sh."
  exit 1
fi

# Verifica se o Buildx já está instalado
if docker buildx version &> /dev/null; then
  echo "[OK] Docker Buildx já instalado: $(docker buildx version)"
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
    echo "[INFO] Instalando Docker Buildx via APT..."

    sudo apt-get update
    sudo apt-get install -y docker-buildx-plugin
    ;;

  fedora)
    echo "[INFO] Instalando Docker Buildx via DNF..."

    sudo dnf install -y docker-buildx-plugin
    ;;

  centos|rhel|rocky|almalinux)
    echo "[INFO] Instalando Docker Buildx via DNF/YUM..."

    if command -v dnf &> /dev/null; then
      sudo dnf install -y docker-buildx-plugin
    else
      sudo yum install -y docker-buildx-plugin
    fi
    ;;

  arch)
    echo "[INFO] Instalando Docker Buildx via Pacman..."

    sudo pacman -Syu --needed --noconfirm docker-buildx
    ;;

  *)
    echo "[ERROR] Distribuição não suportada: ${ID}"
    exit 1
    ;;
esac

# Validação final
if ! docker buildx version; then
  echo "[ERROR] Falha ao validar Docker Buildx."
  exit 1
fi

echo "[OK] Docker Buildx instalado com sucesso!"
