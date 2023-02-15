#!/bin/bash
set -eEuo pipefail

( docker compose version 2>&1 || docker-compose version 2>&1 ) | grep -q v2 || { echo "docker compose v2 is required to run this script"; exit 1; }
compose_cmd="$(docker compose version 2>&1 | grep -q v2 && echo 'docker compose' || echo 'docker-compose')"

read -p "This action will erase all the data and all the volumes. If you proceed you will also wipe your local wallet. Are you sure to proceed ? " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "exiting"
    # shellcheck disable=SC2128
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1
else
    echo "wiping data and volumes..."
    $compose_cmd down
    docker volume rm  evmapp_evmapp-1-data evmapp_evmapp-snark-keys || true
fi
