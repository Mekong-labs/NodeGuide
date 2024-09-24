
### Install Dependencies

```
sudo apt update
sudo apt install curl git make jq build-essential gcc unzip wget lz4 aria2 pv -y
```
### Install Go Language
```
cd $HOME && \
ver="1.22.0" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile && \
source ~/.bash_profile && \
go version
```
### Install Story Geth
```
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
tar -xvf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
cp geth-linux-amd64-0.9.2-ea9f0d2.tar.gz/geth /usr/local/bin/
```
### Install Story
```
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.11-2a25df1.tar.gz
tar -xvf story-linux-amd64-0.9.11-2a25df1.tar.gz
cp story-linux-amd64-0.9.11-2a25df1.tar.gz/story /usr/local/bin/
```
### Install tmux
```
apt install tmux -t
```
### Init Node & Init Geth
```
tmux new -s story 
geth --iliad --syncmode full


Detach the session by Ctrl+B following by D

### Init Story
```
tmux new -s story_init

story init  --network iliad --moniker {NAME}
```

story run
Sync Node by snapshot
In this section, thanks to Joseph Tran, you can refer here

Download Snapshot Geth
Copy
cd $HOME
if curl -s --head https://vps5.josephtran.xyz/Story/Geth_snapshot.lz4 | head -n 1 | grep "200" > /dev/null; then
    echo "Snapshot found, downloading..."
    aria2c -x 16 -s 16 https://vps5.josephtran.xyz/Story/Geth_snapshot.lz4 -o Geth_snapshot.lz4
else
    echo "No snapshot found."
fi
Download Snapshot Story
Copy
cd $HOME
if curl -s --head https://vps5.josephtran.xyz/Story/Story_snapshot.lz4 | head -n 1 | grep "200" > /dev/null; then
    echo "Snapshot found, downloading..."
    aria2c -x 16 -s 16 https://vps5.josephtran.xyz/Story/Story_snapshot.lz4 -o Story_snapshot.lz4
else
    echo "No snapshot found."
fi
Stop Geth and Story Node
Copy
tmux ls
tmux a -t {id}
Ctrl+C
Remember must stop both nodes

Remove old data
Copy
rm -rf ~/.story/story/data
rm -rf ~/.story/geth/iliad/geth/chaindata
Add snapshot Geth

Copy
sudo mkdir -p /root/.story/geth/iliad/geth/chaindata
lz4 -d Geth_snapshot.lz4 | pv | sudo tar xv -C /root/.story/geth/iliad/geth/
Add snapshot Story
Copy
sudo mkdir -p /root/.story/story/data
lz4 -d Story_snapshot.lz4 | pv | sudo tar xv -C /root/.story/story/
Rerun the nodes
Copy
tmux ls
tmux a -t {id}