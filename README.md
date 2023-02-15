# Compose evm testnet
This project uses docker compose to spin up an evmapp node on Dune testnet.

## Requirements
- docker
- docker compose v2
- jq
- bc
- pwgen

## Setup
1. Populate the .env file starting from the .env.template:
    ```shell
    cp .env.template .env
    ```
2. Require the following environment variables form Horizen Labs support team: 
    ```shell
    SCNODE_NET_KNOWNPEERS=
    SCNODE_NET_MAGICBYTES=
    ```
3. Set up environment variables in the .env 
    ```shell
    SCNODE_NET_NODENAME=
    SCNODE_WALLET_GENESIS_SECRETS= # These can be left empty
    SCNODE_WALLET_SEED= # These can be left empty or use a random string
    ```
4. Run the following command to create the stack for the first time:
    ```shell
    ./scripts/init.sh
    ```
5. Run the following command to stop the stack:
    ```shell
    ./scripts/shutdown.sh
    ```
6. Run the following command to destroy the stack, **this action will delete your wallet and all the data**:
    ```shell
    ./scripts/clean.sh
    ```
   
## Usage
The evmapp node RPC interfaces will be available over HTTP at:
- http://localhost:9545/

The Ethereum RPC interface is available at /ethv1:
- http://localhost:9545/ethv1.

