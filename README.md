# Compose evm testnet
This project uses docker compose project to spin up an evmapp node on Gobi testnet.

## Requirements
- docker
- docker compose v2
- jq
- pwgen

## Setup
1. Set up environment variables in the .env 
    ```shell
    SCNODE_REST_PASSWORD= # Uncomment and set this variable only if you are willing to set up authentication on the rest api endpoints
    ```
2. Run the following command to initialize and run the stack for the first time:
    ```shell
    ./scripts/init.sh
    ```
3. Run the following command to stop the stack:
    ```shell
    ./scripts/shutdown.sh
    ```
4. Run the following command to start the stack after it was stopped:
    ```shell
    ./scripts/startup.sh
    ```
5. Run the following command to destroy the stack, **this action will delete your wallet and all the data**:
    ```shell
    ./scripts/clean.sh
    ```

## Usage
The evmapp node RPC interfaces will be available over HTTP at:
- http://localhost:9545/

   For example:
   ```
   curl -sX POST -H 'accept: application/json' -H 'Content-Type: application/json' "http://127.0.0.1:9545/block/best"
   ```

The Ethereum RPC interface is available at /ethv1:
- http://localhost:9545/ethv1

   For example:
   ```
   curl -sX POST -H 'accept: application/json' -H 'Content-Type: application/json' -d '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' "http://127.0.0.1:9545/ethv1"
   ```

