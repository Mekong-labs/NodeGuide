<h1 align="center"> Airchain </h1>


![image](https://github.com/molla202/Airchain/assets/91562185/64b9e7f3-4739-4774-b421-635e224dcd4f)


 * [Airchain Website](https://www.airchains.io)<br>
 * [Blockchain Explorer](https://testnet.airchains.io)<br>
 * [Discord](https://discord.gg/jsy8ZqrD)<br>
 * [Twitter](https://twitter.com/airchains_io)<br>

## Recommended Hardware Requirements
| ------------ | ------------ |
| CPU |	4|
| RAM	| 8+ GB |
| Storage	| 400 GB SSD |




### Install required packages
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```

### Install Go
```
cd $HOME
VER="1.21.3"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
```
### Build binary
```
wget https://github.com/airchains-network/junction/releases/download/v0.1.0/junctiond
chmod +x junctiond
sudo mv junctiond /usr/local/bin
```


### Initialize the Node with the Moniker
Replace with your own moniker

```
junctiond init <moniker>
```
### Download Genesis

wget https://github.com/airchains-network/junction/releases/download/v0.1.0/genesis.json
cp genesis.json $HOME/.junction/config/genesis.json

### Configure
```
SEEDS="de2e7251667dee5de5eed98e54a58749fadd23d8@34.22.237.85:26656"
PEERS="de2e7251667dee5de5eed98e54a58749fadd23d8@34.22.237.85:26656"
sed -i -e "s/^seeds *=.*/seeds = \"$SEEDS\"/; s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.junction/config/config.toml
```
### Set Pruning, Enable Prometheus, Gas Price, and Indexer
```
PRUNING="custom"
PRUNING_KEEP_RECENT="100"
PRUNING_INTERVAL="19"
sed -i -e "s/^pruning *=.*/pruning = \"$PRUNING\"/" $HOME/.junction/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \
\"$PRUNING_KEEP_RECENT\"/" $HOME/.junction/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \
\"$PRUNING_INTERVAL\"/" $HOME/.junction/config/app.toml
sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.junction/config/config.toml
sed -i 's|^prometheus *=.*|prometheus = true|' $HOME/.junction/config/config.toml
sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.00025amf\"/" $HOME/.junction/config/app.toml
```

### Create service
```
sudo tee /etc/systemd/system/junctiond.service > /dev/null << EOF
[Unit]
Description=junction node service
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.junction"
Environment="DAEMON_NAME=junctiond"
Environment="UNSAFE_SKIP_BACKUP=true"
Environment="PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin:$HOME/.junction/cosmovisor/current/bin"

[Install]
WantedBy=multi-user.target
EOF
```
### Start Services
```
sudo systemctl daemon-reload
sudo systemctl enable junctiond
```
### İnit
```
junctiond init node-adi-yaz --chain-id junction
```
### Start Node
```
junctiond start
```
### Check logs
```
sudo journalctl -fu junctiond
```
### Check Node status
```
junctiond status

```
### Create new wallet
```
junctiond keys add <new-wallet>

This command will generate your wallet's mnemonic and address. It's crucial to write these down and store them securely.
```
### Create new validator
```
junctiond comet show-validator
```
### The output will be something like this:
```
{"@type":"/cosmos.crypto.ed25519.PubKey","key":"ZXONS7NNjLWH4HePBOoHKDAYeLXQO5iUwpCRQSi1poI="}
```
### Create validator file
```
Vi $HOME/.junction/config/validator.json
```
### Input data to validator.json file. Replace at "pubkey": {....} from show-validator output
```
{
	"pubkey": {"@type":"/cosmos.crypto.ed25519.PubKey","key":"ZXONS7NNjLWH4HePBOoHKDAYeLXQO5iUwpCRQSi1poI="},
	"amount": "1000000amf",
	"moniker": "<validator-name>",
	"identity": "optional identity signature (ex. UPort or Keybase)",
	"website": "validator's (optional) website",
	"security": "validator's (optional) security contact email",
	"details": "validator's (optional) details",
	"commission-rate": "0.05",
	"commission-max-rate": "0.2",
	"commission-max-change-rate": "0.01",
	"min-self-delegation": "1"
}
```
save file & exit

### Check wallet balances:
```
junctiond q bank balances <yourwallet>
```
### Create VALIDATOR:
```
junctiond tx staking create-validator $HOME/.junction/config/validator.json --from wallet --chain-id junction --gas-prices 0.00025amf --gas-adjustment 1.5 --gas auto -y
```
### COMMAND
```
Check validator status:

junctiond status 2>&1 | jq .ValidatorInfo

junctiond status info

Delegate to Yourself

junctiond tx staking delegate $(junctiond keys show wallet --bech val -a) 0.1amf  --from wallet --chain-id junction --gas-prices=0.00025amf  --gas-adjustment 1.5 --gas "auto" -y 
```
