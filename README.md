# Ethereum Node One-Click Installer

**Run your own Ethereum node in 5 minutes - Zero technical knowledge required!**

Perfect for Aztec sequencers, DApp development, or anyone who needs their own RPC endpoints.

---

##  Quick Install

```bash
wget -O install.sh https://raw.githubusercontent.com/Aabis5004/ethereum-node-installer/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

**That's it!** Choose your options and wait for installation to complete.

---

##  System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| **OS** | Ubuntu 20.04+ | Ubuntu 22.04 LTS |
| **RAM** | 8 GB | 16 GB |
| **Storage** | 700 GB SSD | 1 TB NVMe SSD |
| **Internet** | Stable connection | 100+ Mbps |

---

## Installation Options

### **Option 1: Local Only** 
- RPC accessible only from same server
- Most secure
- Choose if running Aztec on **same server**

### **Option 2: Public Access**  
- RPC accessible from anywhere on internet
- Easy but less secure
- Choose for quick testing

### **Option 3: IP Whitelist** 
- RPC accessible only from specific IPs
- **Recommended for production**
- Choose if running Aztec on **different server**

---

##  Your RPC Endpoints

After installation, your node provides:

```bash
# Local access (always available)
http://localhost:8545        # Execution (Geth)
http://localhost:3500        # Consensus (Prysm)

# External access (depends on your choice)
http://YOUR_SERVER_IP:8545   # Execution (Geth)  
http://YOUR_SERVER_IP:3500   # Consensus (Prysm)
```

### **Test Your RPC:**
```bash
# Check if node is synced
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545

# Response: {"result":false} = fully synced ✅
# Response: {"result":{...}}  = still syncing 🔄
```

---

## 🔧 Node Management

### **Using the Script Menu:**
```bash
sudo ./install.sh
# Then choose:
# 2) Check status
# 3) View logs  
# 4) Start/Stop/Restart
# 5) Uninstall
```

### **Direct Commands:**
```bash
cd /root/ethereum

# View logs
docker compose logs -f

# Start node
docker compose up -d

# Stop node  
docker compose down

# Restart node
docker compose restart

# Check status
docker compose ps
```

---

##  Firewall Management

### **Check Current Rules:**
```bash
sudo ufw status numbered
```

### **Add New IP Address:**
```bash
# Allow new IP to access RPC
sudo ufw allow from NEW_IP_ADDRESS to any port 8545 proto tcp
sudo ufw allow from NEW_IP_ADDRESS to any port 3500 proto tcp
sudo ufw reload
```

### **Remove IP Access:**
```bash
# List rules with numbers
sudo ufw status numbered

# Delete specific rule (replace X with rule number)
sudo ufw delete X

# Reload firewall
sudo ufw reload
```

### **Common Firewall Tasks:**

#### **Secure Public Access (if you chose Option 2):**
```bash
# Get your Aztec VPS IP first, then:
sudo ufw allow from 127.0.0.1 to any port 8545 proto tcp
sudo ufw allow from 127.0.0.1 to any port 3500 proto tcp
sudo ufw allow from YOUR_AZTEC_VPS_IP to any port 8545 proto tcp
sudo ufw allow from YOUR_AZTEC_VPS_IP to any port 3500 proto tcp
sudo ufw deny 8545/tcp
sudo ufw deny 3500/tcp
sudo ufw reload
```

#### **Reset Firewall (start over):**
```bash
sudo ufw --force reset
# Then re-run the installer to reconfigure
```

---

##  Multi-Server Setup (RPC + Aztec)

### **Step 1: Install RPC Node**
```bash
# On your RPC server, run the installer
sudo ./install.sh
# Choose Option 2 or 3
```

### **Step 2: Configure Aztec**  
```bash
# On your Aztec server, use these endpoints:
EXECUTION_RPC_URL=http://RPC_SERVER_IP:8545
BEACON_NODE_URL=http://RPC_SERVER_IP:3500
```

### **Step 3: Secure Connection (Recommended)**
```bash
# On RPC server, allow only your Aztec server:
AZTEC_IP="1.2.3.4"  # Your Aztec server IP

sudo ufw allow from 127.0.0.1 to any port 8545 proto tcp
sudo ufw allow from 127.0.0.1 to any port 3500 proto tcp  
sudo ufw allow from $AZTEC_IP to any port 8545 proto tcp
sudo ufw allow from $AZTEC_IP to any port 3500 proto tcp
sudo ufw deny 8545/tcp
sudo ufw deny 3500/tcp
sudo ufw reload
```

---

## 📊 Monitoring & Troubleshooting

### **Check Sync Status:**
```bash
# Execution sync
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
  http://localhost:8545

# Consensus sync  
curl http://localhost:3500/eth/v1/node/syncing
```

### **Monitor Resources:**
```bash
# System resources
htop

# Disk usage
df -h

# Node data size
du -sh /root/ethereum
```

### **Common Issues:**

#### ** Node won't start:**
```bash
# Check disk space
df -h
# If full, use Option 5 (uninstall) to free space

# Check Docker
sudo systemctl status docker
sudo systemctl restart docker
```

#### ** Slow sync:**
- Initial sync takes **4-24 hours** - be patient!
- Check peers: `docker logs geth | grep peer`
- Ensure stable internet connection

#### ** Can't access RPC:**
```bash  
# Check firewall rules
sudo ufw status numbered

# Test locally first
curl http://localhost:8545

# Check if service is running
docker compose ps
```

---

##  Important Notes

- ** This runs Sepolia testnet** (not mainnet)
- ** Initial sync takes 4-24 hours** and downloads ~400GB
- ** Blockchain data grows continuously** - monitor disk space
- ** Choose security options carefully** for production use
- **🛡 Keep your system updated** regularly


### **Aztec Sequencer:**
```bash
# CLI mode
EXECUTION_RPC=http://RPC_SERVER_IP:8545
CONSENSUS_RPC=http://RPC_SERVER_IP:3500

# Docker mode  
EXECUTION_RPC=http://127.0.0.1:8545
CONSENSUS_RPC=http://127.0.0.1:3500
```

## 🗑️ Complete Uninstall

```bash
sudo ./install.sh
# Choose Option 5

# Or manually:  
cd /root/ethereum && docker compose down
docker rm -f geth prysm
docker system prune -f
sudo rm -rf /root/ethereum
```


##  Like This Project?

If this installer helped you, please:
- ** Star this repository**
- ** Share with others**
- ** Report any issues**

---

**Made with by [Aabis5004](https://github.com/Aabis5004)**

*Making Ethereum accessible to everyone!* 🌟
