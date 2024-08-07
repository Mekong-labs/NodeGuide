### Key management 🔑

### Add new key

junctiond keys add wallet

### Recover existing key

junctiond keys add wallet --recover

### List all keys

junctiond keys list

### Delete key

junctiond keys delete wallet

### Export key to the file

junctiond keys export wallet

### Import key from the file

junctiond keys import wallet wallet.backup

### Query wallet balance

junctiond q bank balances $(junctiond keys show wallet -a)

### Validator management 👷
- Please make sure you have adjusted moniker, identity, details and website to match your values.

### Create new validator

junctiond tx staking create-validator --amount 1000000amf --pubkey $(junctiond tendermint show-validator) --moniker "YOUR_MONIKER_NAME" --identity "YOUR_KEYBASE_ID" --details "YOUR_DETAILS" --website "YOUR_WEBSITE_URL" --chain-id junction --commission-rate 0.05 --commission-max-rate 0.20 --commission-max-change-rate 0.01 --min-self-delegation 1 --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Edit existing validator

junctiond tx staking edit-validator --new-moniker "YOUR_MONIKER_NAME" --identity "YOUR_KEYBASE_ID" --details "YOUR_DETAILS" --website "YOUR_WEBSITE_URL" --chain-id junction --commission-rate 0.05 --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Unjail validator

junctiond tx slashing unjail --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Jail reason

junctiond query slashing signing-info $(junctiond tendermint show-validator)

### List all active validators

junctiond q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_BONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " 	 " + .description.moniker' | sort -gr | nl

### List all inactive validators

junctiond q staking validators -oj --limit=3000 | jq '.validators[] | select(.status=="BOND_STATUS_UNBONDED")' | jq -r '(.tokens|tonumber/pow(10; 6)|floor|tostring) + " 	 " + .description.moniker' | sort -gr | nl

### View validator details

junctiond q staking validator $(junctiond keys show wallet --bech val -a)

### Token management 💲
### Withdraw rewards from all validators

junctiond tx distribution withdraw-all-rewards --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Withdraw commission and rewards from your validator

junctiond tx distribution withdraw-rewards $(junctiond keys show wallet --bech val -a) --commission --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Delegate tokens to yourself

junctiond tx staking delegate $(junctiond keys show wallet --bech val -a) 1000000amf --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Delegate tokens to validator

junctiond tx staking delegate TO_VALOPER_ADDRESS 1000000amf --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Redelegate tokens to another validator

junctiond tx staking redelegate $(junctiond keys show wallet --bech val -a) TO_VALOPER_ADDRESS 1000000amf --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Unbond tokens from your validator

junctiond tx staking unbond $(junctiond keys show wallet --bech val -a) 1000000amf --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Send tokens to the wallet

junctiond tx bank send wallet TO_WALLET_ADDRESS 1000000amf --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Governance 🗳
List all proposals

junctiond query gov proposals

### View proposal by id

junctiond query gov proposal 1

### Vote 'Yes'

junctiond tx gov vote 1 yes --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Vote 'No'

junctiond tx gov vote 1 no --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Vote 'Abstain'

junctiond tx gov vote 1 abstain --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Vote 'NoWithVeto'

junctiond tx gov vote 1 NoWithVeto --from wallet --chain-id junction --gas-adjustment 1.4 --gas auto --gas-prices 0.025amf -y

### Utility ⚡️
Update Indexer

sed -i -e 's|^indexer *=.*|indexer = "null"|' $HOME/.junction/config/config.toml

### Update pruning

sed -i   -e 's|^pruning *=.*|pruning = "custom"|'   -e 's|^pruning-keep-recent *=.*|pruning-keep-recent = "100"|'   -e 's|^pruning-keep-every *=.*|pruning-keep-every = "0"|'   -e 's|^pruning-interval *=.*|pruning-interval = "19"|'   $HOME/.junction/config/app.toml

### Maintenance 🚨
### Get validator info

junctiond status 2>&1 | jq .ValidatorInfo

### Get sync info

junctiond status 2>&1 | jq .SyncInfo

### Get node peer

echo $(junctiond tendermint show-node-id)'@'$(curl -s ifconfig.me)':'$(cat $HOME/.junction/config/config.toml | sed -n '/Address to listen for incoming connection/{n;p;}' | sed 's/.*://; s/".*//')

### Get live peers

curl -sS http://localhost:27657/net_info | jq -r '.result.peers[] | "(.node_info.id)@(.remote_ip):(.node_info.listen_addr)"' | awk -F ':' '{print $1":"$(NF)}'

### Set minimum gas price

sed -i -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = "0.025amf"/" $HOME/.junction/config/app.toml

### Enable prometheus

sed -i -e "s/prometheus = false/prometheus = true/" $HOME/.junction/config/config.toml

### Reset chain data

junctiond tendermint unsafe-reset-all --home $HOME/.junction --keep-addr-book

### Remove node
- Please, before proceeding with the next step! All chain data will be lost! Make sure you have backed up your priv_validator_key.json!

cd $HOME
sudo systemctl stop junctiond
sudo systemctl disable junctiond
sudo rm /etc/systemd/system/junctiond.service
sudo systemctl daemon-reload
rm -f $(which junctiond)
rm -rf $HOME/.junction
rm -rf $HOME/airchains

### Service Management ⚙️
Reload service configuration

sudo systemctl daemon-reload

### Enable service

sudo systemctl enable junctiond

### Disable service

sudo systemctl disable junctiond

### Start service

sudo systemctl start junctiond

### Stop service

sudo systemctl stop junctiond

### Restart service

sudo systemctl restart junctiond

### Check service status

sudo systemctl status junctiond

### Check service logs

sudo journalctl -u junctiond -f --no-hostname -o cat


