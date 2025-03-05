### Recommended Hardware Requirements
```
Operating System: Linux (AMD64)
CPU	8 Physical Cores or More
Memory (RAM) 32GB
Storage	1TB Cloud Storage (AWS), SSD or NVMe
Network	100Mbps
```

### Install Go and Cosmovisor

## Install Go
We will use Go v1.23.4 as example here
```
sudo rm -rvf /usr/local/go/
wget https://golang.org/dl/go1.23.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
rm go1.23.4.linux-amd64.tar.gz
```
## Configure Go
```
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
```
## Install Cosmovisor
Using Cosmovisor v1.0.0
```
go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0
```

### Install Node
```
git clone https://github.com/xrplevm/node xrp
cd xrp
git checkout v6.0.0
make install
```

### Configure Node

## Initialize Node
Please replace YOUR_MONIKER with your own moniker.
```
exrpd init MekongLabs --chain-id xrplevm_1449000-1
```

## Install WASMVM
```
export WASMVM_VERSION=v2.1.2
export LD_LIBRARY_PATH=$HOME/.exrpd/lib
mkdir -p $LD_LIBRARY_PATH
wget "https://github.com/CosmWasm/wasmvm/releases/download/$WASMVM_VERSION/libwasmvm.$(uname -m).so" -O "$LD_LIBRARY_PATH/libwasmvm.$(uname -m).so"
echo "export LD_LIBRARY_PATH=$HOME/.exrpd/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc
```

## Config port, pruning, minimum gas price, enable prometheus and disable indexing
```
echo "export XRPL_PORT="47"" >> $HOME/.bashrc
source $HOME/.bashrc

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${XRPL_PORT}317%g;
s%:8080%:${XRPL_PORT}080%g;
s%:9090%:${XRPL_PORT}090%g;
s%:9091%:${XRPL_PORT}091%g;
s%:8545%:${XRPL_PORT}545%g;
s%:8546%:${XRPL_PORT}546%g;
s%:6065%:${XRPL_PORT}065%g" $HOME/.exrpd/config/app.toml

# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${XRPL_PORT}658%g;
s%:26657%:${XRPL_PORT}657%g;
s%:6060%:${XRPL_PORT}060%g;
s%:26656%:${XRPL_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${XRPL_PORT}656\"%;
s%:26660%:${XRPL_PORT}660%g" $HOME/.exrpd/config/config.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.exrpd/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.exrpd/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.exrpd/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0axrp"|g' $HOME/.exrpd/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.exrpd/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"kv\"/" $HOME/.exrpd/config/config.toml
```

## Configure Seed
```
PEERS=972f58b459debdbaa92fd8479d89128b653d7eb8@65.21.29.250:3640,f8452f28064e9cf9ef1df0c055ac0280576143b6@65.108.69.56:26696,b96d3e221688108e40706d51cca59d80a60f67e9@65.21.200.7:3640,1881f3f71603b7eba91b8b84148834c7322122be@45.77.195.1:26656,6c5b34685a0c1956bde097914e42bc537f5ca5c7@79.137.70.143:26646
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.exrpd/config/config.toml
```

## Download Genesis
```
wget -O genesis.json https://snapshots.polkachu.com/testnet-genesis/xrp/genesis.json --inet4-only
mv genesis.json ~/.exrpd/config
```

## Configure addrbook 
```
wget -O addrbook.json https://snapshots.polkachu.com/testnet-addrbook/xrp/addrbook.json --inet4-only
mv addrbook.json ~/.exrpd/config
```

### Launch Node

## Configure Cosmovisor Folder
Create Cosmovisor folders and load the node binary.
```
# Create Cosmovisor Folders
mkdir -p ~/.exrpd/cosmovisor/genesis/bin
mkdir -p ~/.exrpd/cosmovisor/upgrades

# Load Node Binary into Cosmovisor Folder
cp ~/go/bin/exrpd ~/.exrpd/cosmovisor/genesis/bin
```

## Create Service File
```
[Unit]
Description="xrp node"
After=network-online.target

[Service]
User=USER
ExecStart=/home/USER/go/bin/cosmovisor start
Restart=always
RestartSec=3
LimitNOFILE=4096
Environment="DAEMON_NAME=exrpd"
Environment="DAEMON_HOME=/home/USER/.exrpd"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="UNSAFE_SKIP_BACKUP=true"

[Install]
WantedBy=multi-user.target
```

## Download snapshot
```
sudo apt install lz4

wget -O xrp_243913.tar.lz4 https://snapshots.polkachu.com/testnet-snapshots/xrp/xrp_243913.tar.lz4 --inet4-only

# Back up priv_validator_state.json if needed
cp ~/.exrpd/data/priv_validator_state.json  ~/.exrpd/priv_validator_state.json

# Reset node state
exrpd tendermint unsafe-reset-all --home $HOME/.exrpd --keep-addr-book

lz4 -c -d xrp_243913.tar.lz4  | tar -x -C $HOME/.exrpd

# Replace with the backed-up priv_validator_state.json
cp ~/.exrpd/priv_validator_state.json  ~/.exrpd/data/priv_validator_state.json
```

## Start Node Service
```
sudo systemctl daemon-reload
sudo systemctl enable exrpd
sudo systemctl start exrpd && sudo journalctl -u exrpd -fo cat
```

If you find a bug in this installation guide, please reach out to our https://t.me/jeremy_diamond and let us know.
