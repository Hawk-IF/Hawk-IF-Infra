#!/usr/bin/env bash

set -euo pipefail

DOCKER_INSTALL_URL="https://get.docker.com"
DOCKER_INSTALL_FILE="/tmp/get-docker.sh"

# Identifica o usuário original, mesmo quando o script é executado com sudo
TARGET_USER="${SUDO_USER:-${USER}}"

echo "[INFO] Verificando instalação do Docker..."

if [ ! -f /etc/os-release ]; then
  echo "[ERROR] Não foi possível identificar a distribuição."
  exit 1
fi

source /etc/os-release

echo "[INFO] Distribuição identificada: ${ID}"

# Verifica privilégios administrativos
if ! command -v sudo &> /dev/null; then
  echo "[ERROR] sudo não está instalado."
  exit 1
fi

sudo -v

# Instala o Docker caso necessário
if command -v docker &> /dev/null; then
  echo "[OK] Docker já instalado: $(docker --version)"
else
  echo "[INFO] Iniciando instalação do Docker..."

  case "$ID" in
    arch)
      echo "[INFO] Instalando Docker via Pacman..."

      sudo pacman -Syu --needed --noconfirm docker
      ;;

    ubuntu|debian|fedora|centos|rhel|rocky|almalinux)
      if ! command -v curl &> /dev/null; then
        echo "[ERROR] curl não está instalado."
        exit 1
      fi

      echo "[INFO] Baixando instalador oficial..."

      trap 'rm -f "$DOCKER_INSTALL_FILE"' EXIT

      curl -fsSL "$DOCKER_INSTALL_URL" \
        -o "$DOCKER_INSTALL_FILE"

      echo "[INFO] Executando instalador..."

      sudo sh "$DOCKER_INSTALL_FILE"

      rm -f "$DOCKER_INSTALL_FILE"
      trap - EXIT
      ;;

    *)
      echo "[ERROR] Distribuição não suportada: ${ID}"
      exit 1
      ;;
  esac
fi

# Verifica disponibilidade do systemd
if ! command -v systemctl &> /dev/null; then
  echo "[ERROR] systemctl não está disponível."
  exit 1
fi

# Garante que o grupo docker exista
if ! getent group docker > /dev/null; then
  echo "[INFO] Criando grupo docker..."
  sudo groupadd docker
fi

# Adiciona o usuário ao grupo docker
if ! id -nG "$TARGET_USER" | grep -qw docker; then
  echo "[INFO] Adicionando ${TARGET_USER} ao grupo docker..."
  sudo usermod -aG docker "$TARGET_USER"
else
  echo "[OK] Usuário ${TARGET_USER} já pertence ao grupo docker."
fi

# Habilita e inicia o Docker
echo "[INFO] Habilitando serviço Docker..."

sudo systemctl enable --now docker.service

# Validação final
echo
echo "[INFO] Validando instalação..."

docker --version

if ! sudo systemctl is-active --quiet docker.service; then
  echo "[ERROR] O serviço Docker não está ativo."
  exit 1
fi

echo "[OK] Docker instalado e serviço ativo!"
echo "[OK] Grupo docker configurado para ${TARGET_USER}."

echo "[WARN] Pode ser necessário iniciar uma nova sessão para aplicar a associação ao grupo."
