#!/bin/bash

# 🚀 ETHEREUM NODE MEGA INSTALLER
# One script to rule them all!
# Created by: Aabis5004
# 
# What this script does:
# ✅ Installs Ethereum node (Geth + Prysm)
# ✅ Configures security automatically
# ✅ Provides management tools
# ✅ Creates troubleshooting commands
# ✅ Sets up monitoring
# ✅ Handles everything for you!

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Emojis for better UX
ROCKET="🚀"
CHECK="✅"
WARNING="⚠️"
ERROR="❌"
INFO="ℹ️"
FIRE="🔥"
STAR="⭐"

print_logo() {
    clear
    echo -e "${CYAN}"
    echo "  ███████╗████████╗██╗  ██╗███████╗██████╗ ███████╗██╗   ██╗███╗   ███╗"
    echo "  ██╔════╝╚══██╔══╝██║  ██║██╔════╝██╔══██╗██╔════╝██║   ██║████╗ ████║"
    echo "  █████╗     ██║   ███████║█████╗  ██████╔╝█████╗  ██║   ██║██╔████╔██║"
    echo "  ██╔══╝     ██║   ██╔══██║██╔══╝  ██╔══██╗██╔══╝  ██║   ██║██║╚██╔╝██║"
    echo "  ███████╗   ██║   ██║  ██║███████╗██║  ██║███████╗╚██████╔╝██║ ╚═╝ ██║"
    echo "  ╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝     ╚═╝"
    echo -e "${NC}"
    echo -e "                    ${PURPLE}NODE MEGA INSTALLER${NC}"
    echo -e "                  ${YELLOW}One Script Does Everything!${NC}"
    echo ""
    echo -e "  ${STAR} Created by: ${CYAN}Aabis5004${NC}"
    echo -e "  ${STAR} GitHub: ${CYAN}https://github.com/Aabis5004/ethereum-node-installer${NC}"
    echo ""
}

print_success() { echo -e "${GREEN}${CHECK} $1${NC}"; }
print_warning() { echo -e "${YELLOW}${WARNING} $1${NC}"; }
print_error() { echo -e "${RED}${ERROR} $1${NC}"; }
print_info() { echo -e "${BLUE}${INFO} $1${NC}"; }

# Show main menu
show_menu() {
    print_logo
    echo -e "${CYAN}=== WHAT DO YOU WANT TO DO? ===${NC}"
    echo ""
    echo -e "  ${FIRE} ${GREEN}1)${NC} Install Ethereum Node (Fresh Install)"
    echo -e "  ${CHECK} ${GREEN}2)${NC} Check Node Status"
    echo -e "  ${INFO} ${GREEN}3)${NC} View Node Logs"
    echo -e "  ${WARNING} ${GREEN}4)${NC} Troubleshoot Issues"
    echo -e "  🔧 ${GREEN}5)${NC} Manage Node (Start/Stop/Restart)"
    echo -e "  🌐 ${GREEN}6)${NC} Show RPC Endpoints"
    echo -e "  📊 ${GREEN}7)${NC} System Monitor"
    echo -e "  🔒 ${GREEN}8)${NC} Security Settings"
    echo -e "  🗑️  ${GREEN}9)${NC} Uninstall Everything"
    echo -e "  ❓ ${GREEN}0)${NC} Help & Documentation"
    echo ""
    echo -e "${YELLOW}===============================================${NC}"
    echo -n "Enter your choice (0-9): "
}

# Main installation function
install_node() {
    print_logo
    echo -e "${ROCKET} ${CYAN}STARTING ETHEREUM NODE INSTALLATION${NC}"
    echo ""
    
    # Check if already installed
    if [ -d "/root/ethereum" ]; then
        print_warning "Ethereum node already exists!"
        echo ""
        echo "Choose an option:"
        echo "1) Reinstall (deletes existing data)"
        echo "2) Update/Repair existing installation"
        echo "3) Cancel"
        echo ""
        read -p "Enter choice (1-3): " choice
        
        case $choice in
            1)
                print_info "Removing existing installation..."
                cd /root/ethereum 2>/dev/null && docker compose down || true
                rm -rf /root/ethereum
                print_success "Old installation removed"
                ;;
            2)
                print_info "Updating existing installation..."
                cd /root/ethereum && docker compose pull && docker compose up -d
                print_success "Node updated and restarted"
                return
                ;;
            3)
                return
                ;;
        esac
    fi
    
    # System checks
    echo -e "${BLUE}Checking your system...${NC}"
    
    # Root check
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root!"
        echo "Please run: sudo $0"
        exit 1
    fi
    
    # Ubuntu check
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script requires Ubuntu!"
        exit 1
    fi
    
    # Resource checks
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    DISK_GB=$(df / | awk 'NR==2{printf "%.0f", $4/1024/1024}')
    
    print_info "System: $(lsb_release -d | cut -f2)"
    print_info "RAM: ${RAM_GB}GB (need 8GB+)"
    print_info "Free Space: ${DISK_GB}GB (need 550GB+)"
    
    if [ "$RAM_GB" -lt 8 ] || [ "$DISK_GB" -lt 500 ]; then
        print_warning "Your system may not meet minimum requirements!"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi
    
    # Get public IP
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "unknown")
    if [ "$PUBLIC_IP" != "unknown" ]; then
        print_success "Your public IP: $PUBLIC_IP"
    fi
    
    echo ""
    echo -e "${YELLOW}Ready to install! This will:${NC}"
    echo "• Install Docker and dependencies"
    echo "• Download and configure Geth + Prysm"
    echo "• Set up security (firewall)"
    echo "• Create management tools"
    echo ""
    read -p "Continue with installation? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        return
    fi
    
    # Start installation
    echo ""
    echo -e "${CYAN}${FIRE} INSTALLATION STARTING...${NC}"
    
    # Install dependencies
    print_info "Installing system packages..."
    apt-get update >/dev/null 2>&1
    apt-get install -y curl git wget docker.io docker-compose-plugin ufw jq bc net-tools htop >/dev/null 2>&1
    
    # Start Docker
    systemctl enable docker >/dev/null 2>&1
    systemctl start docker >/dev/null 2>&1
    
    print_success "Dependencies installed"
    
    # Create directories
    print_info "Creating directories..."
    mkdir -p /root/ethereum/{execution,consensus}
    
    # Generate JWT
    print_info "Generating security keys..."
    openssl rand -hex 32 > /root/ethereum/jwt.hex
    
    # Create docker-compose.yml
    print_info "Creating node configuration..."
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
    
    # Security setup
    print_info "Configuring security..."
    ufw --force reset >/dev/null 2>&1
    ufw default deny incoming >/dev/null 2>&1
    ufw default allow outgoing >/dev/null 2>&1
    ufw allow 22 >/dev/null 2>&1
    ufw allow 30303/tcp >/dev/null 2>&1
    ufw allow 30303/udp >/dev/null 2>&1
    
    # Ask about RPC access
    echo ""
    echo -e "${YELLOW}🔒 SECURITY SETUP${NC}"
    echo "How should your RPC be accessible?"
    echo ""
    echo "1) Local only (safest) - Only this server can access"
    echo "2) Specific IPs - You choose which IPs can access"  
    echo "3) Public access - Anyone can access (risky!)"
    echo ""
    while true; do
        read -p "Choose security level (1-3): " security
        case $security in
            1)
                ufw allow from 127.0.0.1 to any port 8545 >/dev/null 2>&1
                ufw allow from 127.0.0.1 to any port 3500 >/dev/null 2>&1
                ufw deny 8545 >/dev/null 2>&1
                ufw deny 3500 >/dev/null 2>&1
                print_success "Configured for local access only"
                break
                ;;
            2)
                echo "Enter IPs to allow (empty line to finish):"
                while true; do
                    read -p "IP address: " ip
                    if [ -z "$ip" ]; then break; fi
                    if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                        ufw allow from $ip to any port 8545 >/dev/null 2>&1
                        ufw allow from $ip to any port 3500 >/dev/null 2>&1
                        print_success "Added $ip"
                    else
                        print_warning "Invalid IP: $ip"
                    fi
                done
                ufw deny 8545 >/dev/null 2>&1
                ufw deny 3500 >/dev/null 2>&1
                break
                ;;
            3)
                print_warning "Enabling public access - be careful!"
                ufw allow 8545 >/dev/null 2>&1
                ufw allow 3500 >/dev/null 2>&1
                break
                ;;
        esac
    done
    
    ufw --force enable >/dev/null 2>&1
    
    # Start the node
    print_info "Starting Ethereum node..."
    cd /root/ethereum
    docker compose pull >/dev/null 2>&1
    docker compose up -d >/dev/null 2>&1
    
    # Create helper scripts
    create_helper_scripts
    
    sleep 3
    
    # Success message
    print_logo
    echo -e "${GREEN}${STAR}${STAR}${STAR} INSTALLATION COMPLETE! ${STAR}${STAR}${STAR}${NC}"
    echo ""
    echo -e "${CYAN}🎉 Your Ethereum node is now running!${NC}"
    echo ""
    echo -e "${YELLOW}📍 RPC Endpoints:${NC}"
    echo "   • Execution: http://localhost:8545"
    if [ "$PUBLIC_IP" != "unknown" ] && [ "$security" != "1" ]; then
        echo "   • External:  http://$PUBLIC_IP:8545"
    fi
    echo "   • Consensus: http://localhost:3500"
    if [ "$PUBLIC_IP" != "unknown" ] && [ "$security" != "1" ]; then
        echo "   • External:  http://$PUBLIC_IP:3500"
    fi
    echo ""
    echo -e "${YELLOW}🔧 Quick Commands:${NC}"
    echo "   • Check status: $0 (select option 2)"
    echo "   • View logs:    $0 (select option 3)"
    echo "   • Get help:     $0 (select option 0)"
    echo ""
    echo -e "${YELLOW}${WARNING} Initial sync will take 4-24 hours!${NC}"
    echo ""
    read -p "Press Enter to return to main menu..."
}

# Create helper scripts
create_helper_scripts() {
    # Create management script
    cat > /usr/local/bin/eth-node << 'EOF'
#!/bin/bash
cd /root/ethereum 2>/dev/null || { echo "Node not installed"; exit 1; }
case "$1" in
    start) docker compose up -d ;;
    stop) docker compose down ;;
    restart) docker compose restart ;;
    logs) docker compose logs -f ;;
    status) docker compose ps ;;
    *) echo "Usage: eth-node {start|stop|restart|logs|status}" ;;
esac
EOF
    chmod +x /usr/local/bin/eth-node
}

# Check node status
check_status() {
    print_logo
    echo -e "${INFO} ${CYAN}ETHEREUM NODE STATUS${NC}"
    echo ""
    
    if [ ! -d "/root/ethereum" ]; then
        print_error "Node not installed! Run option 1 first."
        echo ""
    # Help and documentation
show_help() {
    print_logo
    echo -e "❓ ${CYAN}HELP & DOCUMENTATION${NC}"
    echo ""
    
    echo -e "${YELLOW}🚀 Quick Start:${NC}"
    echo "   1. Run this script as root: sudo $0"
    echo "   2. Choose option 1 to install"
    echo "   3. Wait for sync to complete (4-24 hours)"
    echo "   4. Use option 2 to check status"
    echo ""
    
    echo -e "${YELLOW}📋 Common Commands:${NC}"
    echo "   • Check if synced: curl http://localhost:8545"
    echo "   • View logs: docker logs geth -f"
    echo "   • Check space: df -h"
    echo "   • Restart node: cd /root/ethereum && docker compose restart"
    echo ""
    
    echo -e "${YELLOW}🔧 Troubleshooting:${NC}"
    echo "   • Node won't start: Check disk space with 'df -h'"
    echo "   • Slow sync: Wait longer, initial sync takes time"
    echo "   • Can't connect: Check firewall with 'sudo ufw status'"
    echo "   • Out of space: Use option 9 to uninstall"
    echo ""
    
    echo -e "${YELLOW}🌐 Network Info:${NC}"
    echo "   • This installs Sepolia testnet (not mainnet)"
    echo "   • Sepolia ETH has no real value"
    echo "   • Perfect for testing and development"
    echo ""
    
    echo -e "${YELLOW}📊 System Requirements:${NC}"
    echo "   • OS: Ubuntu 20.04+"
    echo "   • RAM: 8GB+ (16GB recommended)"
    echo "   • Storage: 550GB+ SSD"
    echo "   • Network: Stable internet connection"
    echo ""
    
    echo -e "${YELLOW}🔒 Security Levels:${NC}"
    echo "   • Local only: Safest, only accessible from this server"
    echo "   • IP whitelist: Moderate, specific IPs allowed"
    echo "   • Public: Risky, anyone can access (not for mainnet!)"
    echo ""
    
    echo -e "${YELLOW}💡 Pro Tips:${NC}"
    echo "   • Monitor disk space regularly"
    echo "   • Initial sync downloads ~400GB of data"
    echo "   • Use 'htop' to monitor system resources"
    echo "   • Keep your system updated"
    echo ""
    
    echo -e "${YELLOW}🆘 Get Support:${NC}"
    echo "   • GitHub: https://github.com/Aabis5004/ethereum-node-installer"
    echo "   • Issues: Create a GitHub issue with your problem"
    echo "   • Include: OS version, error messages, logs"
    echo ""
    
    echo -e "${YELLOW}📚 Learn More:${NC}"
    echo "   • Ethereum.org: https://ethereum.org"
    echo "   • Geth docs: https://geth.ethereum.org"
    echo "   • Prysm docs: https://docs.prylabs.network"
    echo ""
    
    read -p "Press Enter to continue..."
}

# Main script logic
main() {
    # Check if running as root
    if [[ $EUID -ne 0 ]] && [[ "$1" != "help" ]]; then
        echo -e "${RED}This script must be run as root!${NC}"
        echo "Please run: sudo $0"
        exit 1
    fi
    
    # Handle command line arguments
    case "$1" in
        "install") install_node; exit 0 ;;
        "status") check_status; exit 0 ;;
        "help") show_help; exit 0 ;;
        "uninstall") uninstall_node; exit 0 ;;
    esac
    
    # Main menu loop
    while true; do
        show_menu
        read choice
        
        case $choice in
            1) install_node ;;
            2) check_status ;;
            3) view_logs ;;
            4) troubleshoot ;;
            5) manage_node ;;
            6) show_endpoints ;;
            7) system_monitor ;;
            8) security_settings ;;
            9) uninstall_node ;;
            0) show_help ;;
            q|Q) 
                print_info "Thanks for using Ethereum Node Installer!"
                echo "Created with ❤️  by Aabis5004"
                exit 0 
                ;;
            *)
                print_error "Invalid choice. Please enter 0-9 or 'q' to quit."
                sleep 2
                ;;
        esac
    done
}

# Run the main function
main "$@"
        return
    fi
    
    cd /root/ethereum
    
    # Container status
    echo -e "${YELLOW}📦 Container Status:${NC}"
    if docker compose ps | grep -q "Up"; then
        print_success "Containers are running"
        docker compose ps
    else
        print_error "Containers are not running"
        echo "Run option 5 to start them"
    fi
    
    echo ""
    echo -e "${YELLOW}🔄 Sync Status:${NC}"
    
    # Check Geth
    echo -n "   Execution (Geth): "
    if timeout 5 curl -s -X POST -H "Content-Type: application/json" \
       --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
       http://localhost:8545 | grep -q '"result":false'; then
        echo -e "${GREEN}✅ Synced${NC}"
    else
        echo -e "${YELLOW}🔄 Syncing...${NC}"
    fi
    
    # Check Prysm
    echo -n "   Consensus (Prysm): "
    if timeout 5 curl -s http://localhost:3500/eth/v1/node/syncing 2>/dev/null | grep -q '"is_syncing":false'; then
        echo -e "${GREEN}✅ Synced${NC}"
    else
        echo -e "${YELLOW}🔄 Syncing...${NC}"
    fi
    
    echo ""
    echo -e "${YELLOW}💾 System Resources:${NC}"
    
    # Disk usage
    echo -n "   Free Space: "
    df -h / | tail -1 | awk '{print $4 " (" $5 " used)"}'
    
    # Data sizes
    if [ -d "/root/ethereum/execution" ]; then
        echo -n "   Geth Data: "
        du -sh /root/ethereum/execution 2>/dev/null | cut -f1 || echo "Unknown"
    fi
    
    if [ -d "/root/ethereum/consensus" ]; then
        echo -n "   Prysm Data: "
        du -sh /root/ethereum/consensus 2>/dev/null | cut -f1 || echo "Unknown"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

# View logs
view_logs() {
    print_logo
    echo -e "${INFO} ${CYAN}NODE LOGS${NC}"
    echo ""
    
    if [ ! -d "/root/ethereum" ]; then
        print_error "Node not installed!"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo "Choose logs to view:"
    echo "1) Both (Geth + Prysm)"
    echo "2) Geth only"
    echo "3) Prysm only"
    echo "4) Last 50 lines"
    echo ""
    read -p "Enter choice (1-4): " choice
    
    cd /root/ethereum
    case $choice in
        1) docker compose logs -f ;;
        2) docker logs geth -f ;;
        3) docker logs prysm -f ;;
        4) docker compose logs --tail=50 ;;
        *) docker compose logs -f ;;
    esac
}

# Troubleshoot
troubleshoot() {
    print_logo
    echo -e "${WARNING} ${CYAN}TROUBLESHOOTING${NC}"
    echo ""
    
    print_info "Running diagnostics..."
    echo ""
    
    # Basic checks
    if [ -d "/root/ethereum" ]; then
        print_success "Node directory exists"
    else
        print_error "Node not installed"
        read -p "Press Enter to continue..."
        return
    fi
    
    cd /root/ethereum
    
    # Container check
    if docker compose ps | grep -q "Up"; then
        print_success "Containers running"
    else
        print_error "Containers not running"
        echo "Try: docker compose up -d"
    fi
    
    # Port check
    if netstat -tuln | grep -q ":8545"; then
        print_success "Geth RPC port open"
    else
        print_warning "Geth RPC port not responding"
    fi
    
    # Connectivity check
    if curl -s http://localhost:8545 >/dev/null; then
        print_success "Geth responding"
    else
        print_error "Geth not responding"
    fi
    
    if curl -s http://localhost:3500 >/dev/null; then
        print_success "Prysm responding"
    else
        print_error "Prysm not responding"
    fi
    
    # Recent errors
    echo ""
    echo -e "${YELLOW}Recent errors (if any):${NC}"
    docker compose logs --tail=20 | grep -i error || echo "No recent errors found"
    
    echo ""
    echo -e "${YELLOW}Quick fixes:${NC}"
    echo "• Restart: docker compose restart"
    echo "• Rebuild: docker compose down && docker compose up -d"
    echo "• Check space: df -h"
    echo "• View full logs: docker compose logs -f"
    
    echo ""
    read -p "Press Enter to continue..."
}

# Manage node
manage_node() {
    print_logo
    echo -e "🔧 ${CYAN}NODE MANAGEMENT${NC}"
    echo ""
    
    if [ ! -d "/root/ethereum" ]; then
        print_error "Node not installed!"
        read -p "Press Enter to continue..."
        return
    fi
    
    cd /root/ethereum
    
    echo "What would you like to do?"
    echo ""
    echo "1) Start node"
    echo "2) Stop node"
    echo "3) Restart node"
    echo "4) Update node"
    echo "5) Reset node (keeps data)"
    echo "6) Back to main menu"
    echo ""
    read -p "Enter choice (1-6): " choice
    
    case $choice in
        1)
            print_info "Starting node..."
            docker compose up -d
            print_success "Node started"
            ;;
        2)
            print_info "Stopping node..."
            docker compose down
            print_success "Node stopped"
            ;;
        3)
            print_info "Restarting node..."
            docker compose restart
            print_success "Node restarted"
            ;;
        4)
            print_info "Updating node..."
            docker compose pull
            docker compose up -d
            print_success "Node updated"
            ;;
        5)
            print_warning "This will restart with fresh containers but keep your data"
            read -p "Continue? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                docker compose down
                docker compose up -d
                print_success "Node reset complete"
            fi
            ;;
        6)
            return
            ;;
    esac
    
    if [ "$choice" != "6" ]; then
        echo ""
        read -p "Press Enter to continue..."
    fi
}

# Show endpoints
show_endpoints() {
    print_logo
    echo -e "🌐 ${CYAN}RPC ENDPOINTS${NC}"
    echo ""
    
    PUBLIC_IP=$(curl -s ifconfig.me 2>/dev/null || echo "unknown")
    
    echo -e "${YELLOW}Local Access:${NC}"
    echo "   Execution (Geth):  http://localhost:8545"
    echo "   Consensus (Prysm): http://localhost:3500"
    echo ""
    
    if [ "$PUBLIC_IP" != "unknown" ]; then
        echo -e "${YELLOW}External Access:${NC}"
        echo "   Execution (Geth):  http://$PUBLIC_IP:8545"
        echo "   Consensus (Prysm): http://$PUBLIC_IP:3500"
        echo ""
        print_warning "External access depends on firewall settings"
    fi
    
    echo -e "${YELLOW}Test Commands:${NC}"
    echo '   curl -X POST -H "Content-Type: application/json" \'
    echo '     --data '\''{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'\'' \'
    echo '     http://localhost:8545'
    echo ""
    echo "   curl http://localhost:3500/eth/v1/node/version"
    
    echo ""
    read -p "Press Enter to continue..."
}

# System monitor
system_monitor() {
    print_logo
    echo -e "📊 ${CYAN}SYSTEM MONITOR${NC}"
    echo ""
    
    echo -e "${YELLOW}System Resources:${NC}"
    
    # CPU and Memory
    echo -n "   CPU Usage: "
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 || echo "Unknown"
    
    echo -n "   Memory: "
    free -h | awk 'NR==2{printf "%s/%s (%.1f%%)\n", $3, $2, $3*100/$2}'
    
    echo -n "   Disk Usage: "
    df -h / | awk 'NR==2{printf "%s/%s (%s)\n", $3, $2, $5}'
    
    if [ -d "/root/ethereum" ]; then
        echo ""
        echo -e "${YELLOW}Node Data Sizes:${NC}"
        
        echo -n "   Geth Data: "
        du -sh /root/ethereum/execution 2>/dev/null | cut -f1 || echo "Unknown"
        
        echo -n "   Prysm Data: "
        du -sh /root/ethereum/consensus 2>/dev/null | cut -f1 || echo "Unknown"
        
        echo -n "   Total Node Data: "
        du -sh /root/ethereum 2>/dev/null | cut -f1 || echo "Unknown"
    fi
    
    echo ""
    echo -e "${YELLOW}Network Status:${NC}"
    
    if command -v ufw >/dev/null; then
        echo -n "   Firewall: "
        if ufw status | grep -q "Status: active"; then
            echo -e "${GREEN}Active${NC}"
        else
            echo -e "${YELLOW}Inactive${NC}"
        fi
    fi
    
    echo ""
    echo "Press Ctrl+C to exit, or wait for auto-refresh..."
    
    # Live monitoring option
    read -t 10 -p "Start live monitoring? (y/N): " -n 1 -r || true
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        htop
    fi
}

# Security settings
security_settings() {
    print_logo
    echo -e "🔒 ${CYAN}SECURITY SETTINGS${NC}"
    echo ""
    
    if ! command -v ufw >/dev/null; then
        print_error "Firewall not installed"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${YELLOW}Current Firewall Status:${NC}"
    ufw status numbered
    
    echo ""
    echo "Security Actions:"
    echo "1) View current rules"
    echo "2) Add allowed IP"
    echo "3) Remove IP access" 
    echo "4) Reset to local-only"
    echo "5) Enable public access"
    echo "6) Back to main menu"
    echo ""
    read -p "Enter choice (1-6): " choice
    
    case $choice in
        1)
            echo ""
            ufw status verbose
            ;;
        2)
            read -p "Enter IP to allow: " ip
            if [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                ufw allow from $ip to any port 8545
                ufw allow from $ip to any port 3500
                print_success "Added $ip to allowed list"
            else
                print_error "Invalid IP format"
            fi
            ;;
        3)
            echo "Current rules:"
            ufw status numbered
            read -p "Enter rule number to delete: " num
            ufw delete $num
            ;;
        4)
            print_warning "This will block all external access"
            read -p "Continue? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ufw --force reset
                ufw default deny incoming
                ufw default allow outgoing
                ufw allow 22
                ufw allow 30303
                ufw allow from 127.0.0.1 to any port 8545
                ufw allow from 127.0.0.1 to any port 3500
                ufw deny 8545
                ufw deny 3500
                ufw --force enable
                print_success "Reset to local-only access"
            fi
            ;;
        5)
            print_warning "This allows anyone to access your node!"
            read -p "Are you sure? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                ufw allow 8545
                ufw allow 3500
                print_success "Enabled public access"
            fi
            ;;
        6)
            return
            ;;
    esac
    
    if [ "$choice" != "6" ]; then
        echo ""
        read -p "Press Enter to continue..."
    fi
}

# Uninstall everything
uninstall_node() {
    print_logo
    echo -e "🗑️  ${RED}UNINSTALL ETHEREUM NODE${NC}"
    echo ""
    
    print_warning "This will completely remove:"
    echo "• All containers and images"
    echo "• All blockchain data"
    echo "• Configuration files"
    echo "• Helper scripts"
    echo ""
    print_warning "This action cannot be undone!"
    echo ""
    
    read -p "Type 'DELETE' to confirm: " confirm
    if [ "$confirm" != "DELETE" ]; then
        print_info "Uninstallation cancelled"
        read -p "Press Enter to continue..."
        return
    fi
    
    print_info "Uninstalling..."
    
    # Stop and remove containers
    cd /root/ethereum 2>/dev/null && docker compose down || true
    docker rm -f geth prysm 2>/dev/null || true
    
    # Remove images
    docker rmi ethereum/client-go:stable 2>/dev/null || true
    docker rmi gcr.io/prysmaticlabs/prysm/beacon-chain 2>/dev/null || true
    
    # Remove data directory
    rm -rf /root/ethereum
    
    # Remove helper scripts
    rm -f /usr/local/bin/eth-node
    
    # Clean firewall rules
    ufw delete allow 30303/tcp 2>/dev/null || true
    ufw delete allow 30303/udp 2>/dev/null || true
    ufw delete deny 8545/tcp 2>/dev/null || true  
    ufw delete deny 3500/tcp 2>/dev/null || true
    
    # Clean Docker
    docker system prune -f >/dev/null 2>&1
    
    print_success "Ethereum node completely removed!"
    echo ""
    echo "Docker and system packages remain installed"
    echo "Your system is clean and ready for fresh installation"
    echo ""
    read -p "Press Enter to continue..."
