#!/bin/bash

set -eEuo pipefail
( docker compose version 2>&1 || docker-compose version 2>&1 ) | grep -q v2 || { echo "docker compose v2 is required to run this script"; exit 1; }
compose_cmd="$(docker compose version 2>&1 | grep -q v2 && echo 'docker compose' || echo 'docker-compose')"

#curl -X POST "http://localhost:9085/node/stop" -H "accept: application/json"

echo "Stopping evm node..."
sleep 2

$compose_cmd down
