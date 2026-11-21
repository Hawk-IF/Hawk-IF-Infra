#!/usr/bin/env bash

set -euo pipefail

readonly BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly ACTION="${1:-up}"

readonly TARGET="${2:-all}"


case "${ACTION}" in
  up)
    case "${TARGET}" in
      infra)
        "${BASE_DIR}/infra-runtime.sh" up
        ;;

      backend)
        "${BASE_DIR}/infra-runtime.sh" up
        "${BASE_DIR}/backend-runtime.sh" up
        ;;

      all)
        "${BASE_DIR}/infra-runtime.sh" up

        "${BASE_DIR}/backend-runtime.sh" up
        ;;

      *)

        echo "Unknown target: ${TARGET}"
        exit 1
        ;;

    esac

    ;;

  down)
    case "${TARGET}" in

      infra)
        "${BASE_DIR}/infra-runtime.sh" down
        ;;

      backend)
        "${BASE_DIR}/backend-runtime.sh" down
        "${BASE_DIR}/infra-runtime.sh" down
        ;;

      all)
        "${BASE_DIR}/backend-runtime.sh" down
        "${BASE_DIR}/infra-runtime.sh" down
        ;;

      *)

        echo "Unknown target: ${TARGET}"
        exit 1
        ;;

    esac

    ;;

  *)
    echo "Usage:"
    echo
    echo "  $0 up [backend|infra|all]"
    echo "  $0 down [backend|infra|all]"
    echo
    echo "Examples:"
    echo
    echo "  $0 up"
    echo "  $0 up backend"
    echo "  $0 up infra"
    echo
    echo "  $0 down"
    echo "  $0 down backend"
    echo "  $0 down infra"
    exit 1
    ;;
esac