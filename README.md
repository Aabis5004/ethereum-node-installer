# 🚀 Ethereum Node One-Click Installer

**Run your own Ethereum node in 5 minutes!**

No technical knowledge required. One command does everything.

---

## ⚡ Quick Install

```bash
wget -O install.sh https://raw.githubusercontent.com/Aabis5004/ethereum-node-installer/main/install.sh
chmod +x install.sh
sudo ./install.sh
```

**That's it!** The script will:
- ✅ Check your system
- ✅ Install everything needed  
- ✅ Configure security
- ✅ Start your Ethereum node
- ✅ Give you a management menu

---

## 💻 What You Need

| Requirement | Minimum |
|------------|---------|
| **OS** | Ubuntu 20.04+ |
| **RAM** | 8 GB |
| **Storage** | 550 GB free space |
| **Internet** | Stable connection |

---

## 🎯 What This Gives You

- **Your own Ethereum node** (Sepolia testnet)
- **RPC endpoints** you control
- **Easy management** with menu options
- **Built-in security** and firewall setup
- **Monitoring tools** and diagnostics

---

## 📱 How To Use

After installation, run the script again to get a menu:

```bash
sudo ./install.sh
```

You'll see options like:
- 📊 Check node status
- 🔍 View logs  
- 🔧 Start/stop node
- 🌐 Show RPC endpoints
- 🛠️ Troubleshoot issues

---

## 🌐 Your RPC Endpoints

Once running, your node will be available at:

- **Local:** `http://localhost:8545` (Execution)
- **Local:** `http://localhost:3500` (Consensus)  
- **External:** `http://YOUR_IP:8545` (if configured)

Test it:
```bash
curl -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545
```

---

## ❓ Need Help?

- **Run the installer** → Choose option `0` for help
- **Check status** → Choose option `2`  
- **View logs** → Choose option `3`
- **Having issues?** → [Create an issue](https://github.com/Aabis5004/ethereum-node-installer/issues)

---

## 🚨 Important Notes

- ⏳ **Initial sync takes 4-24 hours** (downloads ~400GB)
- 💾 **Monitor disk space** - blockchain grows continuously
- 🔒 **This runs Sepolia testnet** (not mainnet)
- 🛡️ **Script configures firewall** for security

---

## 🗑️ Uninstall

To completely remove everything:

```bash
sudo ./install.sh
# Choose option 9
```

---

## ⭐ Like This Project?

Give it a star! It helps others find this tool.

**Made with ❤️ by [Aabis5004](https://github.com/Aabis5004)**

*Making Ethereum accessible to everyone!*
