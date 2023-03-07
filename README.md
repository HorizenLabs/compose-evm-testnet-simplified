# Compose evm testnet
This project uses docker compose to spin up an evmapp node on Dune testnet.

## Requirements
- docker
- docker compose v2
- jq
- bc
- pwgen

## Setup
1. Set up environment variables in the .env 
    ```shell
    SCNODE_NET_NODENAME= # This must be populated with a proper value
    SCNODE_WALLET_SEED= # These can be left empty or use a random string
    SCNODE_REST_PASSWORD= # Uncomment and set this variable only if you are willing to set up authentication on the rest api endpoints
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

