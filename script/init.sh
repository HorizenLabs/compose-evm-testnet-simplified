#!/bin/bash

set -eEuo pipefail
echo "Checking requirements..."
command -v jq &> /dev/null || { echo "jq is required to run this script"; exit 1; }
command -v bc &> /dev/null || { echo "bc is required to run this script"; exit 1; }
( docker compose version 2>&1 || docker-compose version 2>&1 ) | grep -q v2 || { echo "docker compose v2 is required to run this script"; exit 1; }
compose_cmd="$(docker compose version 2>&1 | grep -q v2 && echo 'docker compose' || echo 'docker-compose')"


echo "Checking .env variables..."
if [ -f ".env" ]; then
  source .env
else
  echo "The .env file is missing or is not in the right path. Please add a valid .env file in the root folder of the project"
  exit 1
fi


to_check=(
  "SCNODE_WALLET_MAXTX_FEE"
  "SCNODE_GENESIS_SCID"
  "SCNODE_GENESIS_POWDATA"
  "SCNODE_GENESIS_MCBLOCKHEIGHT"
  "SCNODE_GENESIS_COMMTREEHASH"
  "SCNODE_GENESIS_WITHDRAWALEPOCHLENGTH"
  "SCNODE_GENESIS_MCNETWORK"
  "SCNODE_NET_KNOWNPEERS"
  "SCNODE_NET_MAGICBYTES"
  "SCNODE_NET_NODENAME"
  "SCNODE_NET_P2P_PORT"
  "SCNODE_REST_PORT"
  "SCNODE_USER_ID"
  "SCNODE_GRP_ID"
  "SCNODE_WALLET_GENESIS_SECRETS"
  "SCNODE_WALLET_MAXTX_FEE"
  "SCNODE_WALLET_SEED"
  "SDK_VERSION_EVMAPP"
  "SDK_COMMITTISH_EVMAPP"
)

for var in "${to_check[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "Error: Environment variable ${var} required."
    echo "Thanks for your interest in EON, your configuration is not complete. Please contact us to get the DUNE TESTNET secret parameters."
    for i in "${to_check[@]}"; do
      unset $i
    done
    sleep 5
    exit 1
  fi
done

for var in "${to_check[@]}"; do
  unset $var
done

echo "Starting evm node..."
$compose_cmd up -d
