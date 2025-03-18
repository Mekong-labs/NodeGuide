### Recommended Hardware Requirements
```
Operating System: Linux (AMD64)
CPU	8 Physical Cores or More
Memory (RAM) 16GB
Storage	1TB Cloud Storage (AWS), SSD or NVMe
Network	500Mbps
```

## Install Go
We will use Go v1.23.4 as example here
```
sudo rm -rvf /usr/local/go/
wget https://golang.org/dl/go1.23.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.23.4.linux-amd64.tar.gz
rm go1.23.4.linux-amd64.tar.gz
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bashrc
source $HOME/.bashrc
go version
```

## Install Ignite
```
rm -rf /usr/local/bin/ignite ~/.ignite
curl https://get.ignite.com/cli@v28.8.1! | bash
ignite version
```

### If you've got this error, try to install buf
`✘ Exec: "/root/go/bin/buf": stat /root/go/bin/buf: no such file or directory`

## Install buf
```
curl -sSL https://github.com/bufbuild/buf/releases/latest/download/buf-Linux-x86_64 -o /usr/local/bin/buf
chmod +x /usr/local/bin/buf
export PATH=$PATH:/usr/local/bin
buf --version
```

## Install structsd CLI
```
cd $HOME
git clone https://github.com/playstructs/structsd.git 
cd structsd
ignite chain build
```

## Initialize Node
Please replace YOUR_MONIKER with your own moniker.
```
structsd init <YOUR_MONIKER> --chain-id structstestnet-101
```

## Create key
```
structsd keys add <KEY>
```
## Install Cosmovisor

Using Cosmovisor v1.0.0
```
go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@v1.0.0

echo "export COSMOVISOR_HOME=$HOME/.structs" >> /root/.bashrc
echo "export COSMOVISOR_NAME=structsd" >> /root/.bashrc
echo "export DAEMON_HOME=$HOME/.structs" >> /root/.bashrc
echo "export DAEMON_NAME=structsd" >> /root/.bashrc
echo "export DAEMON_ALLOW_DOWNLOAD_BINARIES=false" >> /root/.bashrc
echo "export DAEMON_RESTART_AFTER_UPGRADE=true" >> /root/.bashrc
echo "export DAEMON_BACKUP=false" >> /root/.bashrc
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin:$HOME/.structs/cosmovisor/current/bin" >> /root/.bashrc
source /root/.bashrc

cosmovisor version
```

## Install WASMVM
```
export WASMVM_VERSION=v2.1.2
export LD_LIBRARY_PATH=$HOME/.structs/lib
mkdir -p $LD_LIBRARY_PATH
wget "https://github.com/CosmWasm/wasmvm/releases/download/$WASMVM_VERSION/libwasmvm.$(uname -m).so" -O "$LD_LIBRARY_PATH/libwasmvm.$(uname -m).so"
echo "export LD_LIBRARY_PATH=$HOME/.structs/lib:$LD_LIBRARY_PATH" >> ~/.bashrc
source ~/.bashrc
```

## Config Keyring
```
structsd config set client chain-id structstestnet-101
structsd config set client keyring-backend os
```

## Config port, pruning, minimum gas price, enable prometheus and enable indexing
```
echo "export STRUCTS_PORT="10"" >> $HOME/.bashrc
source $HOME/.bashrc

# set custom ports in app.toml
sed -i.bak -e "s%:1317%:${STRUCTS_PORT}317%g;
s%:8080%:${STRUCTS_PORT}080%g;
s%:9090%:${STRUCTS_PORT}090%g;
s%:9091%:${STRUCTS_PORT}091%g;
s%:8545%:${STRUCTS_PORT}545%g;
s%:8546%:${STRUCTS_PORT}546%g;
s%:6065%:${STRUCTS_PORT}065%g" $HOME/.structs/config/app.toml

# set custom ports in config.toml file
sed -i.bak -e "s%:26658%:${STRUCTS_PORT}658%g;
s%:26657%:${STRUCTS_PORT}657%g;
s%:6060%:${STRUCTS_PORT}060%g;
s%:26656%:${STRUCTS_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${STRUCTS_PORT}656\"%;
s%:26660%:${STRUCTS_PORT}660%g" $HOME/.structs/config/config.toml

# config pruning
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.structs/config/app.toml 
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.structs/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"19\"/" $HOME/.structs/config/app.toml

# set minimum gas price, enable prometheus and disable indexing
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0ualpha"|g' $HOME/.structs/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.structs/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"kv\"/" $HOME/.structs/config/config.toml
```

## Configure Seed
```
PEERS=f9ff152e331904924c26a4f8b1f46e859d574342@155.138.142.145:26656
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/.structs/config/config.toml
```

## Download Genesis
```
wget -O genesis.json https://github.com/playstructs/structs-networks/blob/main/genesis.json --inet4-only
mv genesis.json ~/.structs/config
```

## Configure addrbook 
```
wget -O addrbook.json https://github.com/playstructs/structs-networks/blob/main/addrbook.json --inet4-only
mv addrbook.json ~/.structs/config
```

### Launch Node

## Configure Cosmovisor Folder
Create Cosmovisor folders and load the node binary.
```
# Create Cosmovisor Folders
mkdir -p ~/.structs/cosmovisor/genesis/bin
mkdir -p ~/.structs/cosmovisor/upgrades
# Load Node Binary into Cosmovisor Folder
cp ~/go/bin/structsd ~/.structs/cosmovisor/genesis/bin
```

## Create Service File
```
sudo tee /etc/systemd/system/structsd.service > /dev/null <<EOF
[Unit]
Description=Cosmovisor for Structs Node
After=network-online.target

[Service]
User=root
ExecStart=/root/go/bin/cosmovisor run start --home /root/.structs
Restart=always
RestartSec=3
LimitNOFILE=65535
Environment="DAEMON_HOME=/root/.structs"
Environment="DAEMON_NAME=structsd"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="LD_LIBRARY_PATH=/root/.structs/lib"
Environment="DAEMON_BACKUP=false"

[Install]
WantedBy=multi-user.target
EOF
```

## Download snapshot
```
sudo apt install lz4

wget -O snapshot_latest.tar.lz4 http://structs-testnet-snapshots.mekonglabs.tech/snapshot_latest.tar.lz4 --inet4-only

# Back up priv_validator_state.json if needed
cp ~/.structs/data/priv_validator_state.json  ~/.structs/priv_validator_state.json

# Reset node state
structsd tendermint unsafe-reset-all --home $HOME/.structs --keep-addr-book

lz4 -c -d snapshot_latest.tar.lz4  | tar -x -C $HOME/.structs

# Replace with the backed-up priv_validator_state.json
cp ~/.structs/priv_validator_state.json  ~/.structs/data/priv_validator_state.json
```

## Start Node Service
```
sudo systemctl daemon-reload
sudo systemctl enable structsd
sudo systemctl start structsd && sudo journalctl -u structsd -fo cat
```

If you find a bug in this installation guide, please reach out to our https://t.me/jeremy_mekong and let us know.

