#!/bin/bash

# Step 1: Update and Upgrade VPS
echo "Updating and upgrading VPS..."
sudo apt update && sudo apt upgrade -y

# Step 2: Install Go
echo "Installing Go..."
cd $HOME
ver="1.22.0"
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
rm "go$ver.linux-amd64.tar.gz"
echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> ~/.bash_profile
source ~/.bash_profile
go version

# Step 3: Download and Install Story-Geth Binary
echo "Downloading and installing Story-Geth binary..."
wget -q https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.3-b224fdf.tar.gz -O /tmp/geth-linux-amd64-0.9.3-b224fdf.tar.gz
tar -xzf /tmp/geth-linux-amd64-0.9.3-b224fdf.tar.gz -C /tmp
[ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin
cp /tmp/geth-linux-amd64-0.9.3-b224fdf/geth $HOME/go/bin/story-geth

# Step 4: Download and Install Story Binary
echo "Downloading and installing Story binary..."
wget -q https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.10.1-57567e5.tar.gz -O /tmp/story-linux-amd64-0.10.1-57567e5.tar.gz
tar -xzf /tmp/story-linux-amd64-0.10.1-57567e5.tar.gz -C /tmp
cp /tmp/story-linux-amd64-0.10.1-57567e5/story $HOME/go/bin/story

# Step 5: Initialize the Iliad Network Node
echo "Initializing Iliad network node..."
$HOME/go/bin/story init --network iliad

# Step 6: Create and Configure systemd Service for Story-Geth
echo "Creating systemd service for Story-Geth..."
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story-geth --iliad --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Step 7: Create and Configure systemd Service for Story
echo "Creating systemd service for Story..."
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=root
ExecStart=/root/go/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Step 8: Reload systemd, Enable, and Start Services
echo "Reloading systemd, enabling, and starting Story-Geth and Story services..."
sudo systemctl daemon-reload
sudo systemctl enable story-geth story
sudo systemctl start story-geth story

# Step 9: Check Service Status
echo "Checking Story-Geth service status..."
sudo systemctl status story-geth --no-pager -l
echo "Checking Story service status..."
sudo systemctl status story --no-pager -l

# Step 10: Check Logs for Story-Geth and Story
echo "Checking logs for Story-Geth..."
sudo journalctl -u story-geth -f -o cat &
echo "Checking logs for Story..."
sudo journalctl -u story -f -o cat

# Step 11: Check Sync Status
echo "Checking sync status..."
curl -s localhost:26657/status | jq

echo "Installation and setup complete!"
