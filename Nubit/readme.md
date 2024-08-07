### Recommended Hardware Requirements
```
CPU	1 Cores
RAM	500 Mb Ram
Storage	40 GB SSD
```

### Choose Tmux or Systemd.
Run with Tmux
```
sudo apt install tmux
tmux
curl -sL1 https://nubit.sh | bash
```
#### Run with Systemd
Create the systemd service file:
```
sudo tee /etc/systemd/system/nubitlight.service > /dev/null <<EOF
[Unit]
Description=Nubit Light Service
After=network.target

[Service]
Type=simple
Environment="HOME=/root"
ExecStart=/bin/bash -c 'curl -sL1 https://nubit.sh | bash'
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
```
### Service
```
sudo systemctl daemon-reload
sudo systemctl enable nubitlight.service
Start service & check logs
sudo systemctl start nubitlight.service && journalctl -u nubitlight.service -f
```
### Please save MNEMONIC, PUBKEY and AUTHKEY

### Export Keys
```
cat $HOME/nubit-node/mnemonic.txt
```
### List all keys: 
```
$HOME/nubit-node/bin/nkey list --p2p.network nubit-alphatestnet-1 --node.type light
```
