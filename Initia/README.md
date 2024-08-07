
# install dependencies
```
sudo apt update && sudo apt upgrade -y
sudo apt install curl git wget htop tmux build-essential jq make lz4 gcc unzip -y
```
# install go, if needed
```
cd $HOME
VER="1.22.2"
wget "https://golang.org/dl/go$VER.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$VER.linux-amd64.tar.gz"
rm "go$VER.linux-amd64.tar.gz"
[ ! -f ~/.bash_profile ] && touch ~/.bash_profile
echo "export PATH=$PATH:/usr/local/go/bin:~/go/bin" >> ~/.bash_profile
source $HOME/.bash_profile
[ ! -d ~/go/bin ] && mkdir -p ~/go/bin
```
# set vars
```
echo "export WALLET="wallet"" >> $HOME/.bash_profile
echo "export MONIKER="test"" >> $HOME/.bash_profile
echo "export INITIA_CHAIN_ID="initiation-1"" >> $HOME/.bash_profile
echo "export INITIA_PORT="51"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```
# download binary
```
cd $HOME
rm -rf initia
git clone https://github.com/initia-labs/initia.git
cd initia
git checkout v0.2.12
make install
```
# config and init app
```
initiad init $MONIKER
sed -i -e "s|^node *=.*|node = \"tcp://localhost:${INITIA_PORT}657\"|" $HOME/.initia/config/client.toml
```
# download genesis and addrbook
```
wget https://initia.s3.ap-southeast-1.amazonaws.com/initiation-1/genesis.json -O $HOME/.initia/config/genesis.json
wget -O $HOME/.initia/config/addrbook.json https://rpc-initia-testnet.trusted-point.com/addrbook.json
```

# set seeds and peers
```
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@initia-testnet.rpc.kjnodes.com:17959\"|" $HOME/.initia/config/config.toml
PEERS="aee7083ab11910ba3f1b8126d1b3728f13f54943@initia-testnet-peer.itrocket.net:11656,2bfad62fa5ba7cc91af4e19ee8d1356997a01079@84.247.166.24:51656,e6a35b95ec73e511ef352085cb300e257536e075@37.252.186.213:26656,07632ab562028c3394ee8e78823069bfc8de7b4c@37.27.52.25:19656,b4778656f255169b8b1d660b6af3a0df68d68e65@176.57.189.36:15656,54d2302155d1bd2a95354ea1d54e196db70a5361@84.46.251.215:656,767fdcfdb0998209834b929c59a2b57d474cc496@207.148.114.112:26656,093e1b89a498b6a8760ad2188fbda30a05e4f300@35.240.207.217:26656,5f934bd7a9d60919ee67968d72405573b7b14ed0@65.21.202.124:29656,e15f6e83d7e35c12f99476674137f3edd1865654@161.97.143.182:16656"
sed -i 's|^persistent_peers *=.*|persistent_peers = "'$PEERS'"|' $HOME/.initia/config/config.toml
```
# set custom ports in app.toml
```
sed -i.bak -e "s%:1317%:${INITIA_PORT}317%g;
s%:8080%:${INITIA_PORT}080%g;
s%:9090%:${INITIA_PORT}090%g;
s%:9091%:${INITIA_PORT}091%g;
s%:8545%:${INITIA_PORT}545%g;
s%:8546%:${INITIA_PORT}546%g;
s%:6065%:${INITIA_PORT}065%g" $HOME/.initia/config/app.toml
```
# set custom ports in config.toml file
```
sed -i.bak -e "s%:26658%:${INITIA_PORT}658%g;
s%:26657%:${INITIA_PORT}657%g;
s%:6060%:${INITIA_PORT}060%g;
s%:26656%:${INITIA_PORT}656%g;
s%^external_address = \"\"%external_address = \"$(wget -qO- eth0.me):${INITIA_PORT}656\"%;
s%:26660%:${INITIA_PORT}660%g" $HOME/.initia/config/config.toml
```
# config pruning
```
sed -i -e "s/^pruning *=.*/pruning = \"custom\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"100\"/" $HOME/.initia/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"50\"/" $HOME/.initia/config/app.toml
```
# set minimum gas price, enable prometheus and disable indexing
```
sed -i 's|minimum-gas-prices =.*|minimum-gas-prices = "0.15uinit,0.01uusdc"|g' $HOME/.initia/config/app.toml
sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.initia/config/config.toml
sed -i -e "s/^indexer *=.*/indexer = \"null\"/" $HOME/.initia/config/config.toml
```
# create service file
```
sudo tee /etc/systemd/system/initiad.service > /dev/null <<EOF
[Unit]
Description=Initia node
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.initia
ExecStart=$(which initiad) start --home $HOME/.initia
Restart=on-failure
RestartSec=5
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
```

# enable and start service
```
sudo systemctl daemon-reload
sudo systemctl enable initiad
sudo systemctl restart initiad && sudo journalctl -u initiad -f
```
