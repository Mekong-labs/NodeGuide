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
## Configure Go
```
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
```

# Install Ignite
```
rm -rf /usr/local/bin/ignite ~/.ignite
curl https://get.ignite.com/cli@v28.8.1! | bash
ignite version
```

# If you've got this error, try to install buf
`✘ Exec: "/root/go/bin/buf": stat /root/go/bin/buf: no such file or directory`
# Install buf
```
curl -sSL https://github.com/bufbuild/buf/releases/latest/download/buf-Linux-x86_64 -o /usr/local/bin/buf
chmod +x /usr/local/bin/buf
export PATH=$PATH:/usr/local/bin
buf --version
```

### Install Node
```
cd $HOME
git clone https://github.com/playstructs/structsd.git 
cd structsd
ignite chain build
```

### Configure Node

## Initialize Node
Please replace YOUR_MONIKER with your own moniker.
```
structsd init <YOUR_MONIKER> --chain-id structstestnet-101
```

## Create key
```
structsd keys add <KEY>
```

### Submit the form

[Link](https://slowninja.notion.site/12feba2cfcc1803a8d72f4f09750fbc6)