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
git clone https://github.com/TacBuild/tacchain tacchain
cd tacchain
git checkout v0.0.10
make install
```

### Configure Node

## Initialize Node
Please replace YOUR_MONIKER with your own moniker.
```
tacchaind init MekongLabs --chain-id tacchain_2391-1
```

## Install WASMVM
```
export WASMVM_VERSION=v2.1.2
export LD_LIBRARY_PATH=$HOME/.tacchaind/lib
mkdir -p $LD_LIBRARY_PATH
wget "https://github.com/CosmWasm/wasmvm/releases/download/$WASMVM_VERSION/libwasmvm.$(uname -m).so" -O "$LD_LIBRARY_PATH/libwasmvm.$(uname -m).so"
echo "export LD_LIBRARY_PATH=$HOME/.tacchaind/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc
```

## Config port, pruning, minimum gas price, enable prometheus and disable indexing
```
echo "export TACCHAIN_PORT="13"" >> $HOME/.bashrc
source $HOME/.bashrc

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${TACCHAIN_PORT}317%g;
s%:8080%:${TACCHAIN_PORT}080%g;
s%:9090%:${TACCHAIN_PORT}090%g;
s%:9091%:${TACCHAIN_PORT}091%g;
s%:8545%:${TACCHAIN_PORT}545%g;
s%:8546%:${TACCHAIN_PORT}546%g;
s%:6065%:${TACCHAIN_PORT}065%g" $HOME/.tacchaind/config/app.toml

# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${TACCHAIN_PORT}658%g;
s%:26657%:${TACCHAIN_PORT}657%g;
s%:6060%:${TACCHAIN_PORT}060%g;
s%:26656%:${TACCHAIN_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${TACCHAIN_PORT}656\"%;
s%:26660%:${TACCHAIN_PORT}660%g" $HOME/.tacchaind/config/config.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.tacchaind/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.tacchaind/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"0\"/" $HOME/.tacchaind/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"10\"/" $HOME/.tacchaind/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
# sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.025ulume"|g' $HOME/.tacchaind/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.tacchaind/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"kv\"/" $HOME/.tacchaind/config/config.toml

#API
sed -i "/^\[api\]/,/^\[/ { 
    s/^enable *=.*/enable = true/ 
    s/^swagger *=.*/swagger = true/ 
    s%^address *=.*%address = \"tcp://0.0.0.0:${TACCHAIN_PORT}317\"% 
}" $HOME/.tacchaind/config/app.toml
```

## Configure Seed
```
sed -i 's/seeds = ""/seeds = "ade4d8bc8cbe014af6ebdf3cb7b1e9ad36f412c0@testnet-seeds.polkachu.com:32156"/' ~/.tacchaind/config/config.toml
```

## Download Genesis
```
wget -O genesis.json https://snapshots.polkachu.com/testnet-genesis/tacchain/genesis.json --inet4-only
mv genesis.json ~/.tacchaind/config
```

### Launch Node

## Configure Cosmovisor Folder
Create Cosmovisor folders and load the node binary.
```
# Create Cosmovisor Folders
mkdir -p ~/.tacchaind/cosmovisor/genesis/bin
mkdir -p ~/.tacchaind/cosmovisor/upgrades

# Load Node Binary into Cosmovisor Folder
cp ~/go/bin/tacchaind ~/.tacchaind/cosmovisor/genesis/bin
```

## Create Service File
```
[Unit]
Description=Tacchain node
After=network-online.target

[Service]
User=root
ExecStart=/root/go/bin/cosmovisor run start --home /root/.tacchaind
Restart=always
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=/root/.tacchaind"
Environment="DAEMON_NAME=tacchaind"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="LD_LIBRARY_PATH=/root/.tacchaind/lib"
Environment="DAEMON_BACKUP=false"

[Install]
WantedBy=multi-user.target
```

## Download snapshot
```
sudo apt install lz4

wget -O tacchain_949571.tar.lz4 https://tacchain-testnet-snapshots.mekonglabs.tech/tacchain_949571.tar.lz4 --inet4-only

# Back up priv_validator_state.json if needed
cp ~/.tacchaind/data/priv_validator_state.json  ~/.tacchaind/priv_validator_state.json

# Reset node state
exrpd tendermint unsafe-reset-all --home $HOME/.tacchaind --keep-addr-book

lz4 -c -d tacchain_949571.tar.lz4  | tar -x -C $HOME/.tacchaind

# Replace with the backed-up priv_validator_state.json
cp ~/.tacchaind/priv_validator_state.json  ~/.tacchaind/data/priv_validator_state.json
```

## Start Node Service
```
sudo systemctl daemon-reload
sudo systemctl enable .tacchaind
sudo systemctl start .tacchaind && sudo journalctl -u .tacchaind -fo cat
```

If you find a bug in this installation guide, please reach out to our https://t.me/jeremy_mekong and let us know.
