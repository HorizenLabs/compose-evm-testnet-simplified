# Compose evm testnet
This project uses docker compose project to spin up an evmapp node on Gobi testnet.

## Requirements
- docker
- docker compose v2
- jq
- pwgen

## Setup - Windows
1. Install WSL by running this command in the terminal:
    ```shell
    wsl --install
    ```
2. Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
3. In Docker Desktop ensure WSL backend and Ubuntu are enabled
    1. Open Settings > WSL Integration
    2. Enable integration with my default WSL distro
    3. Enable Ubuntu toggle
4. Open WSL in the terminal
    ```shell
    wsl
    ```
5. Install `pwgen`
    ```shell
    sudo apt-get install pwgen
    ```
6. Install `dos2unix`
    ```shell
    sudo apt-get install dos2unix
    ```
7. Within each directory: `compose-evm-testnet-simplified`, `configs`, `script` change line endings to Unix:
    ```shell
    dos2unix -v *
    ```
8. Continue with Setup.

## Setup
1. Set up environment variables in the .env 
    ```shell
    SCNODE_REST_PASSWORD= # Uncomment and set this variable only if you are willing to set up authentication on the rest api endpoints
    ```
2. Run the following command to initialize and run the stack for the first time:
    ```shell
    ./script/init.sh
    ```
3. Run the following command to stop the stack:
    ```shell
    ./script/shutdown.sh
    ```
4. Run the following command to start the stack after it was stopped:
    ```shell
    ./script/startup.sh
    ```
5. Run the following command to destroy the stack, **this action will delete your wallet and all the data**:
    ```shell
    ./script/clean.sh
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

