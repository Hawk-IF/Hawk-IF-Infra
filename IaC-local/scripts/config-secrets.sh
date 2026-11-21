#!/usr/bin/env bash

set -euo pipefail

readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly SECRETS_DIR="${BASE_DIR}/secrets"

readonly PATH_ENV_EXAMPLE="${SECRETS_DIR}/.env.path.example"
readonly PATH_ENV_FILE="${SECRETS_DIR}/.env.path"

readonly INFRA_ENV_EXAMPLE="${SECRETS_DIR}/.env.infra.example"
readonly INFRA_ENV_FILE="${SECRETS_DIR}/.env.infra"

readonly BACKEND_ENV_EXAMPLE="${SECRETS_DIR}/.env.backend.example"
readonly BACKEND_ENV_FILE="${SECRETS_DIR}/.env.backend"

readonly POSTGRES_ENV_EXAMPLE="${SECRETS_DIR}/.env.postgres.example"
readonly POSTGRES_ENV_FILE="${SECRETS_DIR}/.env.postgres"

readonly POSTGRES_PASSWORD_EXAMPLE="${SECRETS_DIR}/postgres_password.example"
readonly POSTGRES_PASSWORD_FILE="${SECRETS_DIR}/postgres_password"

readonly REDIS_PASSWORD_EXAMPLE="${SECRETS_DIR}/redis_password.example"
readonly REDIS_PASSWORD_FILE="${SECRETS_DIR}/redis_password"

readonly ENVIRONMENT_KEY_REGEX='^[A-Za-z_][A-Za-z0-9_]*$'

ACTION="${1:-}"

usage() {
  echo "Usage:"
  echo
  echo "  $0 infra"
  echo "  $0 backend"
  echo
}

error() {
  echo
  echo "ERROR: $*" >&2
  exit 1
}

require_example_file() {
  local example_file="$1"

  if [[ ! -f "${example_file}" ]]; then
    error "Example file not found:

${example_file}"
  fi
}

ensure_secrets_directory() {
  if [[ ! -d "${SECRETS_DIR}" ]]; then
    mkdir -p "${SECRETS_DIR}"
  fi
}

get_env_keys() {
  local env_file="$1"

  awk '
    /^[[:space:]]*#/ {
      next
    }

    /^[[:space:]]*$/ {
      next
    }

    /=/ {
      key = $0
      sub(/[[:space:]]*=.*$/, "", key)

      if (key !~ /^[A-Za-z_][A-Za-z0-9_]*$/) {
        exit 1
      }

      print key
    }
  ' "${env_file}"
}

set_env_value() {
  local env_file="$1"
  local key="$2"
  local value="$3"

  local temporary_file

  temporary_file="$(mktemp)"

  awk \
    -v key="${key}" \
    -v value="${value}" '
      BEGIN {
        updated = 0
      }

      /^[[:space:]]*#/ {
        print
        next
      }

      /^[[:space:]]*$/ {
        print
        next
      }

      {
        current_key = $0
        sub(/[[:space:]]*=.*$/, "", current_key)

        if (current_key == key) {
          print key "=\"" value "\""
          updated = 1
          next
        }

        print
      }

      END {
        if (!updated) {
          print key "=\"" value "\""
        }
      }
    ' \
    "${env_file}" > "${temporary_file}"

  install \
    -m 0600 \
    "${temporary_file}" \
    "${env_file}"

  rm -f "${temporary_file}"
}

is_env_value_filled() {
  local value="$1"

  value="${value#"${value%%[![:space:]]*}"}"
  value="${value%"${value##*[![:space:]]}"}"

  [[ -n "${value}" ]]
}

validate_env_file() {
  local example_file="$1"
  local env_file="$2"

  if [[ ! -f "${env_file}" ]]; then
    return 1
  fi

  local key
  local value

  while IFS= read -r key; do
    [[ -z "${key}" ]] && continue

    value="$(get_env_value "${env_file}" "${key}")"

    if ! is_env_value_filled "${value}"; then
      return 1
    fi
  done < <(get_env_keys "${example_file}")

  return 0
}

copy_example_file() {
  local example_file="$1"
  local target_file="$2"
  local display_name="$3"

  require_example_file "${example_file}"

  if [[ -f "${target_file}" ]]; then
    if validate_env_file "${example_file}" "${target_file}"; then
      echo "✓ ${display_name} already configured. Skipping."
      return 0
    fi

    error "${display_name} exists but is incomplete:

${target_file}

Remove or fix the file before continuing."
  fi

  install \
    -m 0600 \
    "${example_file}" \
    "${target_file}"

  echo "✓ ${display_name} created."
}

get_project_path() {
  local key="$1"

  if [[ ! -f "${PATH_ENV_FILE}" ]]; then
    return 1
  fi

  get_env_value "${PATH_ENV_FILE}" "${key}"
}

get_env_value() {

  local env_file="$1"
  local requested_key="$2"

  awk -v requested_key="${requested_key}" '

    /^[[:space:]]*#/ {
      next
    }

    /^[[:space:]]*$/ {
      next
    }

    /=/ {

      key = $0
      sub(/[[:space:]]*=.*$/, "", key)

      if (key == requested_key) {

        value = $0
        sub(/^[^=]*=/, "", value)

        gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)

        if (value ~ /^".*"$/) {
          sub(/^"/, "", value)
          sub(/"$/, "", value)
        }

        if (value ~ /^'\''.*'\''$/) {
          sub(/^'\''/, "", value)
          sub(/'\''$/, "", value)
        }

        print value
        exit
      }
    }

  ' "${env_file}"
}

prompt_project_path() {
  local key="$1"
  local description="$2"

  local current_value

  current_value="$(get_project_path "${key}" || true)"

  if is_env_value_filled "${current_value}" && [[ "${current_value}" != "@prompt" ]]; then
    echo "✓ ${key} already configured."
    return 0
  fi

  echo
  read -r -p "Do you want to configure ${description} (${key})? [y/N]: " want_path

  case "${want_path}" in
    y|Y)
      ;;
    *)
      echo "✓ Skipping ${key} configuration."
      set_env_value "${PATH_ENV_FILE}" "${key}" ""
      return 0
      ;;
  esac

  echo
  echo "${description}"
  echo

  while true; do
    read -r -p "${key}: " current_value

    if [[ -z "${current_value}" ]]; then
      echo "Value cannot be empty."
      continue
    fi

    if [[ ! -d "${current_value}" ]]; then
      echo
      echo "Directory does not exist:"
      echo "${current_value}"
      echo
      read -r -p "Use this path anyway? [y/N]: " confirm

      case "${confirm}" in
        y|Y)
          ;;
        *)
          continue
          ;;
      esac
    fi

    break
  done

  set_env_value \
    "${PATH_ENV_FILE}" \
    "${key}" \
    "${current_value}"

  echo "✓ ${key} configured."
}

ensure_path_environment() {
  require_example_file "${PATH_ENV_EXAMPLE}"

  if [[ ! -f "${PATH_ENV_FILE}" ]]; then
    install \
      -m 0600 \
      "${PATH_ENV_EXAMPLE}" \
      "${PATH_ENV_FILE}"

    echo "✓ .env.path created from example."
  fi
}

ensure_infra_environment() {
  echo
  echo "=== Preparing infra local environment ==="

  copy_example_file \
    "${INFRA_ENV_EXAMPLE}" \
    "${INFRA_ENV_FILE}" \
    ".env.infra"

  echo
  echo "Infra local environment is ready."
}

run_infra() {

  echo
  echo "========================================"
  echo "Configure Infra Environment"
  echo "========================================"

  ensure_infra_environment

}

ensure_backend_environment() {
  echo
  echo "=== Preparing backend local environment ==="

  copy_example_file \
    "${BACKEND_ENV_EXAMPLE}" \
    "${BACKEND_ENV_FILE}" \
    ".env.backend"

  copy_example_file \
    "${POSTGRES_ENV_EXAMPLE}" \
    "${POSTGRES_ENV_FILE}" \
    ".env.postgres"

  copy_example_file \
    "${POSTGRES_PASSWORD_EXAMPLE}" \
    "${POSTGRES_PASSWORD_FILE}" \
    "postgres_password"

  copy_example_file \
    "${REDIS_PASSWORD_EXAMPLE}" \
    "${REDIS_PASSWORD_FILE}" \
    "redis_password"

  echo
  echo "Backend local environment is ready."
}

run_backend() {

  echo
  echo "========================================"
  echo "Configure Backend Environment"
  echo "========================================"

  ensure_path_environment

  prompt_project_path \
    "BACKEND_PROJECT_DIR" \
    "Backend project directory"

  ensure_backend_environment

}

main() {
  case "${ACTION}" in
    infra)
      run_infra
      ;;

    backend)
      run_backend
      ;;

    *)
      usage
      exit 1
      ;;
  esac
}

ensure_secrets_directory
main