#!/bin/bash

# 🚀 ETHEREUM NODE COMPLETE INSTALLER
# One script does everything - NO missing parts!
# Created by: Aabis5004

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error() { echo -e "${RED}❌ $1${NC}"; }
print_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }

print_logo() {
    clear
    echo -e "${CYAN}"
    echo "  ███████╗████████╗██╗  ██╗███████╗██████╗ ███████╗██╗   ██╗███╗   ███╗"
    echo "  ██╔════╝╚══██╔══╝██║  ██║██╔════╝██╔══██╗██╔════╝██║   ██║████╗ ████║"
    echo "  █████╗     ██║   ███████║█████╗  ██████╔╝█████╗  ██║   ██║██╔████╔██║"
    echo "  ██╔══╝     ██║   ██╔══██║██╔══╝  ██╔══██╗██╔══╝  ██║   ██║██║╚██╔╝██║"
    echo "  ███████╗   ██║   ██║  ██║███████╗██║  ██║███████╗╚██████╔╝██║ ╚═╝ ██║"
    echo -e "${NC}"
    echo -e "                    ${CYAN}NODE INSTALLER${NC}"
    echo -e "                  ${YELLOW}Complete Solution${NC}"
    echo ""
}

show_menu() {
    print_logo
    echo -e "${CYAN}=== ETHEREUM NODE MANAGER ===${NC}"
    echo ""
    echo -e "  🚀 ${GREEN}1)${NC} Install Ethereum Node"
    echo -e "  📊 ${GREEN}2)${NC} Check Node Status"
    echo -e "  📝 ${GREEN}3)${NC} View Logs"
    echo -e "  🔧 ${GREEN}4)${NC} Manage Node (Start/Stop/Restart)"
    echo -e "  🗑️  ${GREEN}5)${NC} Uninstall Everything"
    echo -e "  ❓ ${GREEN}0)${NC} Help"
    echo ""
    echo -n "Enter choice (0-5): "
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "Run as root: sudo $0"
        exit 1
    fi
}

install_all_dependencies() {
    print_info "Installing ALL dependencies..."
    
    # Update system
    apt-get update && apt-get upgrade -y
    
    # Install ALL packages from original guide
    apt install -y \
        curl iptables build-essential git wget lz4 jq make gcc nano \
        automake autoconf tmux htop nvme-cli libgbm1 pkg-config \
        libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip \
        bc net-tools ufw ca-certificates gnupg
    
    print_success "System packages installed"
}

install_docker_complete() {
    print_info "Installing Docker (complete process)..."
    
    # Remove old Docker (from original guide)
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
        apt-get remove -y $pkg 2>/dev/null || true
    done
    
    # Install Docker (exact steps from original guide)
    apt-get update
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Test and enable Docker
    docker run hello-world >/dev/null 2>&1 || { print_error "Docker install failed"; exit 1; }
    systemctl enable docker
    systemctl restart docker
    
    print_success "Docker installed and working"
}

setup_ethereum_complete() {
    print_info "Setting up Ethereum node..."
    
    # Create directories (exact from original guide)
    mkdir -p /root/ethereum/execution
    mkdir -p /root/ethereum/consensus
    
    # Generate JWT secret (exact from original guide)
    openssl rand -hex 32 > /root/ethereum/jwt.hex
    
    # Create docker-compose.yml (EXACT copy from original guide)
    cat > /root/ethereum/docker-compose.yml << 'EOF'
services:
  geth:
    image: ethereum/client-go:stable
    container_name: geth
    network_mode: host
    restart: unless-stopped
    ports:
      - 30303:30303
      - 30303:30303/udp
      - 8545:8545
      - 8546:8546
      - 8551:8551
    volumes:
      - /root/ethereum/execution:/data
      - /root/ethereum/jwt.hex:/data/jwt.hex
    command:
      - --sepolia
      - --http
      - --http.api=eth,net,web3
      - --http.addr=0.0.0.0
      - --authrpc.addr=0.0.0.0
      - --authrpc.vhosts=*
      - --authrpc.jwtsecret=/data/jwt.hex
      - --authrpc.port=8551
      - --syncmode=snap
      - --datadir=/data
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"

  prysm:
    image: gcr.io/prysmaticlabs/prysm/beacon-chain
    container_name: prysm
    network_mode: host
    restart: unless-stopped
    volumes:
      - /root/ethereum/consensus:/data
      - /root/ethereum/jwt.hex:/data/jwt.hex
    depends_on:
      - geth
    ports:
      - 4000:4000
      - 3500:3500
    command:
      - --sepolia
      - --accept-terms-of-use
      - --datadir=/data
      - --disable-monitoring
      - --rpc-host=0.0.0.0
      - --execution-endpoint=http://127.0.0.1:8551
      - --jwt-secret=/data/jwt.hex
      - --rpc-port=4000
      - --grpc-gateway-corsdomain=*
      - --grpc-gateway-host=0.0.0.0
      - --grpc-gateway-port=3500
      - --min-sync-peers=3
      - --checkpoint-sync-url=https://checkpoint-sync.sepolia.ethpandaops.io
      - --genesis-beacon-api-url=https://checkpoint-sync.sepolia.ethpandaops.io
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
EOF
    
    print_success "Configuration created"
}

configure_firewall_complete() {
    print_info "Setting up firewall (following original guide)..."
    
    # Step 1: Enable Firewall (from your guide)
    print_info "Step 1: Enabling basic firewall rules..."
    ufw --force reset >/dev/null 2>&1
    ufw default deny incoming >/dev/null 2>&1
    ufw default allow outgoing >/dev/null 2>&1
    
    # Enable Firewall (from your guide)
    ufw allow 22 >/dev/null 2>&1
    ufw allow ssh >/dev/null 2>&1
    ufw --force enable >/dev/null 2>&1
    
    # Step 2: Allow Geth P2P ports (from your guide)
    print_info "Step 2: Allowing Geth P2P ports..."
    ufw allow 30303/tcp >/dev/null 2>&1   # Geth P2P
    ufw allow 30303/udp >/dev/null 2>&1   # Geth P2P
    
    # Step 3: Allow ports for local use (from your guide)
    print_info "Step 3: Allowing localhost access..."
    ufw allow from 127.0.0.1 to any port 8545 proto tcp >/dev/null 2>&1
    ufw allow from 127.0.0.1 to any port 3500 proto tcp >/dev/null 2>&1
    
    echo ""
    print_warning "🔒 RPC ACCESS CONFIGURATION"
    echo ""
    echo "How will you access your RPC endpoints?"
    echo ""
    echo "1) 🏠 Local only - Only this server can access RPC"
    echo "   → Choose if Aztec runs on SAME server"
    echo "   → Most secure"
    echo ""
    echo "2) 🌍 Anyone can access - No IP restrictions"
    echo "   → Choose for easy testing"
    echo "   → Less secure but simple"
    echo ""
    echo "3) 📝 Specific IPs only - Whitelist approach (RECOMMENDED)"
    echo "   → Choose if Aztec runs on DIFFERENT server"
    echo "   → Follow your original guide exactly"
    echo "   → Most secure for multi-server setup"
    echo ""
    read -p "Choose (1-3): " choice
    
    case $choice in
        1)
            print_info "Configuring localhost-only access..."
            # Deny everyone else (from your guide)
            ufw deny 8545/tcp >/dev/null 2>&1
            ufw deny 3500/tcp >/dev/null 2>&1
            
            print_success "✅ Local-only access configured"
            echo ""
            print_info "📋 To allow other servers later:"
            echo "sudo ufw allow from OTHER_SERVER_IP to any port 8545 proto tcp"
            echo "sudo ufw allow from OTHER_SERVER_IP to any port 3500 proto tcp"
            ;;
            
        2)
            print_info "Configuring public access..."
            # Don't add any deny rules - leave ports open
            print_warning "✅ Public access configured - no restrictions"
            
            PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "YOUR_IP")
            echo ""
            print_warning "⚠️  Your RPC endpoints are publicly accessible:"
            echo "   Execution: http://$PUBLIC_IP:8545"
            echo "   Consensus: http://$PUBLIC_IP:3500"
            ;;
            
        3)
            print_info "🔐 IP Whitelist Configuration (following your guide exactly)..."
            echo ""
            
            # Step 4: Allow ports on favorite IPs (from your guide)
            print_info "Step 4: Adding favorite IPs..."
            echo "Enter IP addresses to whitelist (one per line, empty line to finish):"
            print_info "Example: If your Aztec VPS IP is 134.12.44.177, enter: 134.12.44.177"
            echo ""
            
            ALLOWED_IPS=()
            while true; do
                read -p "IP address: " ip
                if [ -z "$ip" ]; then break; fi
                
                # Validate IP format
                if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                    # Allow ports on favorite IPs (from your guide)
                    ufw allow from $ip to any port 8545 proto tcp >/dev/null 2>&1
                    ufw allow from $ip to any port 3500 proto tcp >/dev/null 2>&1
                    ALLOWED_IPS+=($ip)
                    print_success "✅ Added $ip to whitelist"
                else
                    print_error "❌ Invalid IP format: $ip (use format: 1.2.3.4)"
                fi
            done
            
            if [ ${#ALLOWED_IPS[@]} -gt 0 ]; then
                # Step 5: Deny ports on all other IPs (from your guide)
                print_info "Step 5: Denying all other IPs..."
                ufw deny 8545/tcp >/dev/null 2>&1
                ufw deny 3500/tcp >/dev/null 2>&1
                
                print_success "✅ IP whitelist configured following your original guide"
                echo ""
                print_info "📋 Final configuration:"
                echo "   ✅ Localhost (127.0.0.1): ALLOWED"
                echo "   ✅ Whitelisted IPs: ${ALLOWED_IPS[*]}"
                echo "   🚫 All other IPs: DENIED"
                echo ""
                print_info "💡 Rule processing order (as per your guide):"
                echo "   1. Allow SSH (22)"
                echo "   2. Allow P2P (30303)"
                echo "   3. Allow localhost → ports 8545,3500"
                echo "   4. Allow specific IPs → ports 8545,3500"
                echo "   5. Deny everyone else → ports 8545,3500"
            else
                print_warning "No IPs added, using localhost-only"
                ufw deny 8545/tcp >/dev/null 2>&1
                ufw deny 3500/tcp >/dev/null 2>&1
            fi
            ;;
            
        *)
            print_error "Invalid choice, defaulting to localhost-only (safest)"
            ufw deny 8545/tcp >/dev/null 2>&1
            ufw deny 3500/tcp >/dev/null 2>&1
            ;;
    esac
    
    # Step 6: Reload Firewall (from your guide)
    print_info "Step 6: Reloading firewall..."
    ufw reload >/dev/null 2>&1
    
    print_success "🛡️  Firewall configured following your original guide"
    echo ""
    print_info "📋 Useful commands (from your guide):"
    echo "   View rules: sudo ufw status numbered"
    echo "   Delete rule: sudo ufw delete <number>"
    echo "   Add IP later: sudo ufw allow from NEW_IP to any port 8545 proto tcp"
    echo "   Reload: sudo ufw reload"
}

install_node() {
    print_logo
    echo -e "${CYAN}🚀 INSTALLING ETHEREUM NODE${NC}"
    echo ""
    
    # Check if already exists
    if [ -d "/root/ethereum" ]; then
        print_warning "Node already exists!"
        read -p "Reinstall? This deletes existing data (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            cd /root/ethereum && docker compose down 2>/dev/null || true
            rm -rf /root/ethereum
        else
            return
        fi
    fi
    
    # Check system
    print_info "Checking system..."
    
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "Ubuntu required"
        exit 1
    fi
    
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    DISK_GB=$(df / | awk 'NR==2{printf "%.0f", $4/1024/1024}')
    
    print_info "RAM: ${RAM_GB}GB, Disk: ${DISK_GB}GB free"
    
    if [ "$RAM_GB" -lt 6 ] || [ "$DISK_GB" -lt 400 ]; then
        print_warning "Low resources detected"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo ""
    read -p "Start installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi
    
    # Install everything
    install_all_dependencies
    install_docker_complete
    setup_ethereum_complete
    configure_firewall_complete
    
    # Start node
    print_info "Starting Ethereum node..."
    cd /root/ethereum
    docker compose pull >/dev/null 2>&1
    docker compose up -d >/dev/null 2>&1
    
    # Show results
    PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "unknown")
    
    echo ""
    print_success "🎉 INSTALLATION COMPLETE!"
    echo ""
    echo -e "${YELLOW}📍 Your RPC Endpoints:${NC}"
    echo "   Local:  http://localhost:8545 (Execution)"
    echo "   Local:  http://localhost:3500 (Consensus)"
    if [ "$PUBLIC_IP" != "unknown" ]; then
        echo "   Remote: http://$PUBLIC_IP:8545 (if public access)"
    fi
    echo ""
    echo -e "${YELLOW}🔍 Check Sync Status:${NC}"
    echo '   curl -X POST -H "Content-Type: application/json" --data '"'"'{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'"'"' http://localhost:8545'
    echo ""
    echo -e "${YELLOW}📝 View Logs:${NC}"
    echo "   docker compose logs -f"
    echo ""
    print_warning "Initial sync takes 4-24 hours!"
    echo ""
    read -p "Press Enter to continue..."
}

check_status() {
    print_logo
    echo -e "${BLUE}📊 NODE STATUS${NC}"
    echo ""
    
    if [ ! -d "/root/ethereum" ]; then
        print_error "Node not installed"
        read -p "Press Enter to continue..."
        return
    fi
    
    cd /root/ethereum
    
    # Container status
    echo -e "${YELLOW}Containers:${NC}"
    if docker compose ps 2>/dev/null | grep -q "Up"; then
        print_success "Running"
        docker compose ps
    else
        print_error "Not running"
    fi
    
    echo ""
    echo -e "${YELLOW}Sync Status:${NC}"
    
    # Check Geth
    echo -n "Execution: "
    if timeout 5 curl -s -X POST -H "Content-Type: application/json" \
       --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
       http://localhost:8545 2>/dev/null | grep -q '"result":false'; then
        echo -e "${GREEN}✅ Synced${NC}"
    else
        echo -e "${YELLOW}🔄 Syncing...${NC}"
    fi
    
    # Check Prysm
    echo -n "Consensus: "
    if timeout 5 curl -s http://localhost:3500/eth/v1/node/syncing 2>/dev/null | grep -q '"is_syncing":false'; then
        echo -e "${GREEN}✅ Synced${NC}"
    else
        echo -e "${YELLOW}🔄 Syncing...${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}Resources:${NC}"
    echo -n "Free space: "
    df -h / | tail -1 | awk '{print $4}'
    
    if [ -d "/root/ethereum/execution" ]; then
        echo -n "Node data: "
        du -sh /root/ethereum 2>/dev/null | cut -f1 || echo "Unknown"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

view_logs() {
    print_logo
    echo -e "${BLUE}📝 NODE LOGS${NC}"
    echo ""
    
    if [ ! -d "/root/ethereum" ]; then
        print_error "Node not installed"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "Choose:"
    echo "1) Live logs (both services)"
    echo "2) Last 50 lines"
    echo "3) Geth only"
    echo "4) Prysm only"
    echo ""
    read -p "Choice (1-4): " choice
    
    cd /root/ethereum
    case $choice in
        1) docker compose logs -f ;;
        2) docker compose logs --tail=50 ;;
        3) docker logs geth -f ;;
        4) docker logs prysm -f ;;
        *) docker compose logs -f ;;
    esac
}

manage_node() {
    print_logo
    echo -e "${BLUE}🔧 MANAGE NODE${NC}"
    echo ""
    
    if [ ! -d "/root/ethereum" ]; then
        print_error "Node not installed"
        read -p "Press Enter to continue..."
        return
    fi
    
    cd /root/ethereum
    
    echo "Actions:"
    echo "1) Start node"
    echo "2) Stop node"
    echo "3) Restart node"
    echo "4) Update node"
    echo ""
    read -p "Choice (1-4): " choice
    
    case $choice in
        1)
            docker compose up -d
            print_success "Node started"
            ;;
        2)
            docker compose down
            print_success "Node stopped"
            ;;
        3)
            docker compose restart
            print_success "Node restarted"
            ;;
        4)
            docker compose pull
            docker compose up -d
            print_success "Node updated"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

uninstall_node() {
    print_logo
    echo -e "${RED}🗑️  UNINSTALL NODE${NC}"
    echo ""
    
    print_warning "This will delete ALL blockchain data!"
    echo ""
    read -p "Type 'DELETE' to confirm: " confirm
    if [ "$confirm" != "DELETE" ]; then
        print_info "Cancelled"
        read -p "Press Enter to continue..."
        return
    fi
    
    print_info "Removing everything..."
    
    # Stop and remove
    cd /root/ethereum 2>/dev/null && docker compose down || true
    docker rm -f geth prysm 2>/dev/null || true
    docker rmi ethereum/client-go:stable gcr.io/prysmaticlabs/prysm/beacon-chain 2>/dev/null || true
    rm -rf /root/ethereum
    
    # Clean firewall
    ufw delete allow 30303/tcp 2>/dev/null || true
    ufw delete allow 30303/udp 2>/dev/null || true
    ufw delete deny 8545 2>/dev/null || true
    ufw delete deny 3500 2>/dev/null || true
    ufw delete allow 8545 2>/dev/null || true
    ufw delete allow 3500 2>/dev/null || true
    
    docker system prune -f >/dev/null 2>&1
    
    print_success "Node completely removed!"
    echo ""
    read -p "Press Enter to continue..."
}

show_help() {
    print_logo
    echo -e "${BLUE}❓ HELP${NC}"
    echo ""
    echo -e "${YELLOW}Quick Start:${NC}"
    echo "1. Run: sudo $0"
    echo "2. Choose option 1 to install"
    echo "3. Wait for sync (4-24 hours)"
    echo ""
    echo -e "${YELLOW}Check Sync:${NC}"
    echo 'curl -X POST -H "Content-Type: application/json" --data '"'"'{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'"'"' http://localhost:8545'
    echo ""
    echo "Result 'false' = synced"
    echo "Result with numbers = still syncing"
    echo ""
    echo -e "${YELLOW}Commands:${NC}"
    echo "View logs: cd /root/ethereum && docker compose logs -f"
    echo "Start: cd /root/ethereum && docker compose up -d"
    echo "Stop: cd /root/ethereum && docker compose down"
    echo ""
    echo -e "${YELLOW}Troubleshooting:${NC}"
    echo "• Not starting: Check 'df -h' for disk space"
    echo "• Slow sync: Be patient, takes many hours"
    echo "• Can't connect: Check 'sudo ufw status'"
    echo ""
    echo -e "${YELLOW}This installs:${NC}"
    echo "• Sepolia testnet (not mainnet)"
    echo "• Geth (execution) + Prysm (consensus)"
    echo "• RPC at localhost:8545 and localhost:3500"
    echo ""
    read -p "Press Enter to continue..."
}

main() {
    # Command line support
    case "$1" in
        "install") check_root; install_node; exit 0 ;;
        "status") check_status; exit 0 ;;
        "help") show_help; exit 0 ;;
    esac
    
    # Check root for interactive mode
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}Run as root: sudo $0${NC}"
        exit 1
    fi
    
    # Main menu
    while true; do
        show_menu
        read choice
        
        case $choice in
            1) install_node ;;
            2) check_status ;;
            3) view_logs ;;
            4) manage_node ;;
            5) uninstall_node ;;
            0) show_help ;;
            q|Q) 
                echo "Thanks for using Ethereum Node Installer!"
                exit 0 
                ;;
            *) 
                print_error "Invalid choice"
                sleep 1
                ;;
        esac
    done
}

main "$@"
