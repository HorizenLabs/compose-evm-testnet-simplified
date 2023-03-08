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
    SCNODE_NET_NODENAME= # This variable requires a name. Enter a name using characters, special characters, or numbers.
    SCNODE_WALLET_SEED= # This variable can be empty or filled with a random string.
    SCNODE_REST_PASSWORD= # Use this variable only to set up authentication on the rest api endpoints, where you have to uncomment.
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

