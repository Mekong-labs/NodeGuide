# Elixir-Validator

![image](https://github.com/user-attachments/assets/0c016a6b-8395-42d5-9fdc-09bbb20e25df)




## System Requirements (Minimum-Recommended)
| Ram | cpu     | disk                      |
| :-------- | :------- | :-------------------------------- |
| `4 GB`      | `8 Core` | `30 GB SSD` |

## 1- Install Dependecies
```console
sudo apt update && sudo apt upgrade -y 
sudo apt install curl iptables build-essential git wget lz4 jq make gcc nano automake autoconf tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev  -y
```

## 2- Install docker
```console
sudo apt update -y && sudo apt upgrade -y
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y && sudo apt upgrade -y

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker version check
docker --version
```

## 3- Validator Private Key Generation
Create an EVM metamask wallet and write its private and public keys
> In Metamask, this can be done by clicking the "My Accounts" icon in the top right, and clicking "+ Create Account." You can obtain the private key by clicking Account Details from the ellipsis menu, and then clicking "Export private key".

## 4- Delegate MOCK Tokens To Your Validator
1. **Enter the [dashboard](https://testnet-3.elixir.xyz/)**
2. **Connect the wallet you created in step 3**
3. **Mint MOCK tokens**
4. **Stake them**
5. **Click `CUSTOM VALIDATOR` and enter your wallet public address and sign the tx**

## 5- Running Your Validator

1- **Download `validator.env`**:
```console
wget https://raw.githubusercontent.com/Mekong-labs/NodeGuide/main/Elixir-validator/validator.env -0
```

2- **Config `validator.env`**:
```console
vim validator.env
```
* `STRATEGY_EXECUTOR_DISPLAY_NAME`: Your Validator Name
* `STRATEGY_EXECUTOR_BENEFICIARY`: Your Wallet Public Key
* `SIGNER_PRIVATE_KEY`: Your Wallet Private Key
> `Ctrl+X+Y+ENTER` to save and exit

3. **Pull the docker images**
```console
docker pull elixirprotocol/validator:v3
```

4. **Run Validator**
```console
docker run -d \
  --env-file ./validator.env \
  --name elixir \
  --restart unless-stopped \
  -p 17690:17690 \
  elixirprotocol/validator:v3
```

## 6- Check Validator Status
1. **Validator Logs**:
```
docker logs -f elixir
```
> Verify connectivity in the logs.  It may take a minute or so for the first authorization to complete and for messages to start coming in.

2. **Validator Health Status**:
```
curl 127.0.0.1:17690/health | jq
```
Response: "OK"



## Upgrading your validator
Team updates the validators frequently (always check discord), so you need to upgrade it using following commands
```console
docker kill elixir
docker rm elixir
docker pull elixirprotocol/validator:v3 --platform linux/amd64
```
```console
docker run -d \
  --env-file ./validator.env \
  --name elixir \
  --restart unless-stopped \
  -p 17690:17690 \
  elixirprotocol/validator:v3
```

