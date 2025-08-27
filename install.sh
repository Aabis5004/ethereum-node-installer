#!/bin/bash

# 🚀 ETHEREUM NODE MEGA INSTALLER
# One script to rule them all!
# Created by: Aabis5004
# 
# What this script does:
# ✅ Installs ALL dependencies (Docker, packages, etc.)
# ✅ Sets up Ethereum node (Geth + Prysm)
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

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root!"
        echo "Please run: sudo $0"
        exit 1
    fi
}

# Check Ubuntu version
check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        print_error "This script requires Ubuntu!"
        echo "Detected: $(lsb_release -d | cut -f2)"
        exit 1
    fi
    
    UBUNTU_VERSION=$(lsb_release -rs)
    if (( $(echo "$UBUNTU_VERSION < 20.04" | bc -l) )); then
        print_error "Ubuntu 20.04 or later required!"
        echo "Detected: $UBUNTU_VERSION"
        exit 1
    fi
    
    print_success "Ubuntu $UBUNTU_VERSION detected"
}

# Check system requirements
check_requirements() {
    print_info "Checking system requirements..."
    
    # System resources
    echo ""
    print_info "System resources:"
    echo -n "   RAM usage: "
    free -h | awk 'NR==2{printf "%s/%s (%.1f%%)\n", $3, $2, $3*100/$2}'
    
    echo -n "   Disk usage: "
    df -h / | awk 'NR==2{printf "%s/%s (%s)\n", $3, $2, $5}'
    
    # Recent errors
    echo ""
    print_info "Recent errors (last 20 lines):"
    docker compose logs --tail=20 2>/dev/null | grep -i error | head -10 || echo "No recent errors found"
    
    echo ""
    echo -e "${YELLOW}🔧 QUICK FIXES:${NC}"
    echo "   • Restart containers: docker compose restart"
    echo "   • Rebuild containers: docker compose down && docker compose up -d"
    echo "   • Check disk space: df -h"
    echo "   • View full logs: docker compose logs -f"
    echo "   • Update images: docker compose pull"
    
    echo ""
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
    echo "4) Update node images"
    echo "5) Reset node (keeps blockchain data)"
    echo "6) View container logs"
    echo "7) Back to main menu"
    echo ""
    read -p "Enter choice (1-7): " choice
    
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
            print_info "Updating node images..."
            docker compose pull
            docker compose up -d
            print_success "Node updated"
            ;;
        5)
            print_warning "This will restart with fresh containers but keep your blockchain data"
            read -p "Continue? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                docker compose down
                docker compose up -d
                print_success "Node reset complete"
            fi
            ;;
        6)
            print_info "Showing container logs..."
            docker compose logs --tail=50
            ;;
        7)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    
    if [ "$choice" != "7" ]; then
        echo ""
        read -p "Press Enter to continue..."
    fi
}

# Show endpoints
show_endpoints() {
    print_logo
    echo -e "🌐 ${CYAN}RPC ENDPOINTS${NC}"
    echo ""
    
    PUBLIC_IP=$(curl -s --connect-timeout 5 ifconfig.me 2>/dev/null || echo "unknown")
    
    echo -e "${YELLOW}📍 Your Ethereum Node Endpoints:${NC}"
    echo ""
    echo -e "${GREEN}Local Access (from this server):${NC}"
    echo "   Execution (Geth):  http://localhost:8545"
    echo "   Consensus (Prysm): http://localhost:3500"
    echo ""
    
    if [ "$PUBLIC_IP" != "unknown" ]; then
        echo -e "${GREEN}External Access (from internet):${NC}"
        echo "   Execution (Geth):  http://$PUBLIC_IP:8545"
        echo "   Consensus (Prysm): http://$PUBLIC_IP:3500"
        echo ""
        print_warning "External access depends on your firewall settings"
    fi
    
    echo -e "${YELLOW}🧪 TEST COMMANDS:${NC}"
    echo ""
    echo "Test Execution RPC (Geth):"
    echo '  curl -X POST -H "Content-Type: application/json" \'
    echo '    --data '"'"'{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'"'"' \'
    echo '    http://localhost:8545'
    echo ""
    echo "Test Consensus RPC (Prysm):"
    echo "  curl http://localhost:3500/eth/v1/node/version"
    echo ""
    echo "Check sync status:"
    echo '  curl -X POST -H "Content-Type: application/json" \'
    echo '    --data '"'"'{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'"'"' \'
    echo '    http://localhost:8545'
    echo ""
    
    echo -e "${YELLOW}📋 INTEGRATION EXAMPLES:${NC}"
    echo ""
    echo "Web3.js:"
    echo "  const web3 = new Web3('http://localhost:8545');"
    echo ""
    echo "Ethers.js:"
    echo "  const provider = new ethers.JsonRpcProvider('http://localhost:8545');"
    echo ""
    
    read -p "Press Enter to continue..."
}

# System monitor
system_monitor() {
    print_logo
    echo -e "📊 ${CYAN}SYSTEM MONITOR${NC}"
    echo ""
    
    echo -e "${YELLOW}💻 SYSTEM RESOURCES:${NC}"
    echo ""
    
    # CPU and Memory
    echo -n "   CPU Usage: "
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 2>/dev/null || echo "Unknown"
    
    echo -n "   Memory Usage: "
    free -h | awk 'NR==2{printf "%s/%s (%.1f%%)\n", $3, $2, $3*100/$2}' 2>/dev/null
    
    echo -n "   Disk Usage: "
    df -h / | awk 'NR==2{printf "%s/%s (%s)\n", $3, $2, $5}' 2>/dev/null
    
    echo -n "   Load Average: "
    uptime | awk -F'load average:' '{print $2}' 2>/dev/null || echo "Unknown"
    
    if [ -d "/root/ethereum" ]; then
        echo ""
        echo -e "${YELLOW}⛓️ NODE DATA SIZES:${NC}"
        echo ""
        
        echo -n "   Geth Data: "
        du -sh /root/ethereum/execution 2>/dev/null | cut -f1 || echo "Unknown"
        
        echo -n "   Prysm Data: "
        du -sh /root/ethereum/consensus 2>/dev/null | cut -f1 || echo "Unknown"
        
        echo -n "   Total Node Data: "
        du -sh /root/ethereum 2>/dev/null | cut -f1 || echo "Unknown"
        
        echo ""
        echo -e "${YELLOW}🐳 DOCKER STATUS:${NC}"
        echo ""
        cd /root/ethereum 2>/dev/null && docker compose ps || echo "Docker compose not available"
    fi
    
    echo ""
    echo -e "${YELLOW}🔥 NETWORK STATUS:${NC}"
    echo ""
    
    if command -v ufw >/dev/null; then
        echo -n "   Firewall: "
        if ufw status 2>/dev/null | grep -q "Status: active"; then
            echo -e "${GREEN}Active${NC}"
        else
            echo -e "${YELLOW}Inactive${NC}"
        fi
    fi
    
    echo ""
    echo "Press 1 for live monitoring (htop), or any other key to continue..."
    read -n 1 -r
    if [[ $REPLY == "1" ]]; then
        echo ""
        print_info "Starting live system monitor (press 'q' to exit)..."
        sleep 2
        htop
    fi
    echo ""
}

# Security settings
security_settings() {
    print_logo
    echo -e "🔒 ${CYAN}SECURITY SETTINGS${NC}"
    echo ""
    
    if ! command -v ufw >/dev/null; then
        print_error "UFW firewall not installed"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo -e "${YELLOW}🛡️ CURRENT FIREWALL STATUS:${NC}"
    echo ""
    ufw status numbered 2>/dev/null || echo "Unable to check firewall status"
    
    echo ""
    echo "Security Actions:"
    echo "1) View detailed firewall rules"
    echo "2) Add allowed IP address"
    echo "3) Remove IP access" 
    echo "4) Reset to localhost-only (most secure)"
    echo "5) Enable public access (risky)"
    echo "6) Show recommended security settings"
    echo "7) Back to main menu"
    echo ""
    read -p "Enter choice (1-7): " choice
    
    case $choice in
        1)
            echo ""
            echo -e "${YELLOW}📋 DETAILED FIREWALL RULES:${NC}"
            ufw status verbose 2>/dev/null || echo "Unable to show rules"
            ;;
        2)
            read -p "Enter IP address to allow access: " ip
            if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                ufw allow from $ip to any port 8545 comment "Geth RPC from $ip" 2>/dev/null
                ufw allow from $ip to any port 3500 comment "Prysm RPC from $ip" 2>/dev/null
                print_success "Added $ip to allowed list"
            else
                print_error "Invalid IP format"
            fi
            ;;
        3)
            echo ""
            echo "Current numbered rules:"
            ufw status numbered 2>/dev/null
            echo ""
            read -p "Enter rule number to delete: " num
            if [[ $num =~ ^[0-9]+$ ]]; then
                ufw delete $num 2>/dev/null && print_success "Rule deleted" || print_error "Failed to delete rule"
            else
                print_error "Invalid rule number"
            fi
            ;;
        4)
            print_warning "This will block ALL external access to RPC endpoints"
            print_info "Only localhost (127.0.0.1) will be able to access your node"
            read -p "Continue? (y/N): " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Reset firewall with secure defaults
                ufw --force reset >/dev/null 2>&1
                ufw default deny incoming >/dev/null 2>&1
                ufw default allow outgoing >/dev/null 2>&1
                ufw allow 22 comment 'SSH' >/dev/null 2>&1
                ufw allow 30303/tcp comment 'Geth P2P TCP' >/dev/null 2>&1
                ufw allow 30303/udp comment 'Geth P2P UDP' >/dev/null 2>&1
                ufw allow from 127.0.0.1 to any port 8545 proto tcp comment 'Geth RPC localhost' >/dev/null 2>&1
                ufw allow from 127.0.0.1 to any port 3500 proto tcp comment 'Prysm RPC localhost' >/dev/null 2>&1
                ufw deny 8545/tcp comment 'Deny Geth RPC external' >/dev/null 2>&1
                ufw deny 3500/tcp comment 'Deny Prysm RPC external' >/dev/null 2>&1
                ufw --force enable >/dev/null 2>&1
                print_success "Firewall reset to localhost-only access"
            fi
            ;;
        5)
            print_warning "⚠️  PUBLIC ACCESS WARNING ⚠️"
            echo ""
            echo "This will allow ANYONE on the internet to access your node!"
            echo "This is NOT recommended for production use."
            echo "Your node could be used for:"
            echo "• Unauthorized transactions"
            echo "• Resource abuse"
            echo "• Security attacks"
            echo ""
            read -p "Are you absolutely sure? Type 'ENABLE' to confirm: " confirm
            if [ "$confirm" = "ENABLE" ]; then
                ufw allow 8545/tcp comment 'Geth RPC public' 2>/dev/null
                ufw allow 3500/tcp comment 'Prysm RPC public' 2>/dev/null
                print_warning "Public access enabled - monitor your node closely!"
            else
                print_info "Public access NOT enabled"
            fi
            ;;
        6)
            echo ""
            echo -e "${YELLOW}🔐 RECOMMENDED SECURITY SETTINGS:${NC}"
            echo ""
            echo "1. 🏠 LOCALHOST ONLY (Most Secure)"
            echo "   • Only accessible from this server"
            echo "   • Perfect for SSH tunnels or local development"
            echo "   • Recommended for most users"
            echo ""
            echo "2. 📝 IP WHITELIST (Balanced)"
            echo "   • Allow specific trusted IP addresses"
            echo "   • Good for team environments"
            echo "   • Requires maintaining IP list"
            echo ""
            echo "3. 🌍 PUBLIC ACCESS (Risky)"
            echo "   • Anyone can access your node"
            echo "   • Only for public services or testing"
            echo "   • NOT recommended for mainnet"
            echo ""
            echo -e "${YELLOW}💡 ADDITIONAL SECURITY TIPS:${NC}"
            echo "• Use SSH key authentication"
            echo "• Keep your system updated"
            echo "• Monitor node logs regularly"
            echo "• Use strong passwords"
            echo "• Consider VPN access instead of public IPs"
            ;;
        7)
            return
            ;;
        *)
            print_error "Invalid choice"
            ;;
    esac
    
    if [ "$choice" != "7" ]; then
        echo ""
        read -p "Press Enter to continue..."
    fi
}

# Uninstall everything
uninstall_node() {
    print_logo
    echo -e "🗑️  ${RED}UNINSTALL ETHEREUM NODE${NC}"
    echo ""
    
    print_warning "⚠️  COMPLETE REMOVAL WARNING ⚠️"
    echo ""
    echo "This will permanently delete:"
    echo "• All Docker containers (Geth + Prysm)"
    echo "• All blockchain data (~400GB+ of downloaded blocks)"
    echo "• Configuration files"
    echo "• Helper scripts"
    echo "• Firewall rules for the node"
    echo ""
    print_error "THIS ACTION CANNOT BE UNDONE!"
    echo ""
    echo "Your blockchain data represents hours/days of syncing."
    echo "You will need to re-sync from scratch if you reinstall."
    echo ""
    
    read -p "Type 'DELETE EVERYTHING' to confirm complete removal: " confirm
    if [ "$confirm" != "DELETE EVERYTHING" ]; then
        print_info "Uninstallation cancelled - your node is safe"
        read -p "Press Enter to continue..."
        return
    fi
    
    print_info "Starting complete removal..."
    echo ""
    
    # Stop and remove containers
    print_info "Stopping containers..."
    cd /root/ethereum 2>/dev/null && docker compose down || true
    
    print_info "Removing containers..."
    docker rm -f geth prysm 2>/dev/null || true
    
    # Remove Docker images
    print_info "Removing Docker images..."
    docker rmi ethereum/client-go:stable 2>/dev/null || true
    docker rmi gcr.io/prysmaticlabs/prysm/beacon-chain 2>/dev/null || true
    
    # Remove all data
    print_info "Removing all blockchain data..."
    rm -rf /root/ethereum
    
    # Remove helper scripts
    print_info "Removing helper scripts..."
    rm -f /usr/local/bin/eth-node
    
    # Clean up firewall rules
    print_info "Cleaning up firewall rules..."
    ufw delete allow 30303/tcp 2>/dev/null || true
    ufw delete allow 30303/udp 2>/dev/null || true
    ufw delete deny 8545/tcp 2>/dev/null || true  
    ufw delete deny 3500/tcp 2>/dev/null || true
    ufw delete allow 8545/tcp 2>/dev/null || true
    ufw delete allow 3500/tcp 2>/dev/null || true
    
    # Clean up Docker system
    print_info "Cleaning up Docker system..."
    docker system prune -f >/dev/null 2>&1 || true
    
    echo ""
    print_success "✅ ETHEREUM NODE COMPLETELY REMOVED!"
    echo ""
    echo "What was removed:"
    echo "• All Ethereum containers and images"
    echo "• All blockchain data (execution + consensus)"
    echo "• Configuration files and scripts"
    echo "• Related firewall rules"
    echo ""
    echo "What remains:"
    echo "• Docker (can be used for other projects)"
    echo "• System packages (can be used for other projects)"
    echo "• Your system is clean and ready"
    echo ""
    print_info "To reinstall, simply run this script again and choose option 1"
    echo ""
    read -p "Press Enter to continue..."
}

# Help and documentation
show_help() {
    print_logo
    echo -e "❓ ${CYAN}HELP & DOCUMENTATION${NC}"
    echo ""
    
    echo -e "${YELLOW}🚀 QUICK START GUIDE:${NC}"
    echo "   1. Run this script as root: sudo $0"
    echo "   2. Choose option 1 to install"
    echo "   3. Select your security level"
    echo "   4. Wait for installation to complete"
    echo "   5. Monitor sync progress (takes 4-24 hours)"
    echo ""
    
    echo -e "${YELLOW}📋 COMMON COMMANDS:${NC}"
    echo "   Check sync status:"
    echo '     curl -X POST -H "Content-Type: application/json" --data '"'"'{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'"'"' http://localhost:8545'
    echo ""
    echo "   View live logs:"
    echo "     cd /root/ethereum && docker compose logs -f"
    echo ""
    echo "   Quick node control:"
    echo "     eth-node start    # Start the node"
    echo "     eth-node stop     # Stop the node"
    echo "     eth-node restart  # Restart the node"
    echo "     eth-node logs     # View logs"
    echo "     eth-node status   # Show status"
    echo ""
    
    echo -e "${YELLOW}🔧 TROUBLESHOOTING:${NC}"
    echo ""
    echo "   🐛 Node won't start:"
    echo "     • Check disk space: df -h"
    echo "     • Check Docker: docker ps"
    echo "     • Restart Docker: sudo systemctl restart docker"
    echo ""
    echo "   📶 Slow or stuck sync:"
    echo "     • Be patient - initial sync takes 4-24 hours"
    echo "     • Check peers: docker logs geth | grep peer"
    echo "     • Ensure good internet connection"
    echo ""
    echo "   🌐 Can't access RPC:"
    echo "     • Check firewall: sudo ufw status"
    echo "     • Test locally first: curl http://localhost:8545"
    echo "     • Verify container status: docker compose ps"
    echo ""
    echo "   💾 Running out of space:"
    echo "     • Blockchain data grows continuously"
    echo "     • Consider larger storage"
    echo "     • Use option 9 to uninstall if needed"
    echo ""
    
    echo -e "${YELLOW}🌐 NETWORK INFORMATION:${NC}"
    echo "   • This installs SEPOLIA TESTNET (not mainnet)"
    echo "   • Sepolia ETH has no real monetary value"
    echo "   • Perfect for testing and development"
    echo "   • Uses same technology as Ethereum mainnet"
    echo "   • Get test ETH from: https://sepoliafaucet.com"
    echo ""
    
    echo -e "${YELLOW}📊 SYSTEM REQUIREMENTS:${NC}"
    echo "   Minimum:"
    echo "   • OS: Ubuntu 20.04+"
    echo "   • RAM: 8GB"
    echo "   • Storage: 550GB+ SSD"
    echo "   • Network: Stable broadband"
    echo ""
    echo "   Recommended:"
    echo "   • OS: Ubuntu 22.04 LTS"
    echo "   • RAM: 16GB+"
    echo "   • Storage: 1TB+ NVMe SSD"
    echo "   • Network: 100+ Mbps"
    echo ""
    
    echo -e "${YELLOW}🔒 SECURITY LEVELS EXPLAINED:${NC}"
    echo ""
    echo "   🏠 Localhost Only (Recommended):"
    echo "     • RPC only accessible from this server"
    echo "     • Use SSH tunnels for remote access"
    echo "     • Most secure option"
    echo ""
    echo "   📝 IP Whitelist (Balanced):"
    echo "     • Specify exact IPs that can access"
    echo "     • Good for known team members"
    echo "     • Requires IP management"
    echo ""
    echo "   🌍 Public Access (Risky):"
    echo "     • Anyone on internet can access"
    echo "     • Only for public services or testing"
    echo "     • NOT for mainnet or sensitive data"
    echo ""
    
    echo -e "${YELLOW}💡 PRO TIPS:${NC}"
    echo "   • Monitor disk space regularly (blockchain grows ~1GB/day)"
    echo "   • Keep system updated: sudo apt update && sudo apt upgrade"
    echo "   • Use 'htop' to monitor system resources"
    echo "   • Backup your JWT secret: /root/ethereum/jwt.hex"
    echo "   • Consider using SSH key authentication"
    echo "   • Set up log rotation for long-term use"
    echo ""
    
    echo -e "${YELLOW}🆘 GET SUPPORT:${NC}"
    echo "   • GitHub Issues: https://github.com/Aabis5004/ethereum-node-installer/issues"
    echo "   • Include: OS version, error messages, logs"
    echo "   • Use option 4 (Troubleshoot) to gather diagnostic info"
    echo ""
    
    echo -e "${YELLOW}📚 LEARN MORE:${NC}"
    echo "   • Ethereum.org: https://ethereum.org/en/developers/docs/nodes-and-clients/"
    echo "   • Geth Documentation: https://geth.ethereum.org/docs/"
    echo "   • Prysm Documentation: https://docs.prylabs.network/"
    echo "   • Sepolia Testnet: https://sepolia.dev/"
    echo ""
    
    read -p "Press Enter to continue..."
}

# Main script logic
main() {
    # Handle command line arguments for advanced users
    case "$1" in
        "install") 
            check_root
            install_node
            exit 0 
            ;;
        "status") 
            check_status
            exit 0 
            ;;
        "help") 
            show_help
            exit 0 
            ;;
        "uninstall") 
            check_root
            uninstall_node
            exit 0 
            ;;
    esac
    
    # Check if running as root for interactive mode
    if [[ $EUID -ne 0 ]]; then
        echo -e "${RED}This script must be run as root!${NC}"
        echo "Please run: sudo $0"
        echo ""
        echo "Or for help: $0 help"
        exit 1
    fi
    
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
            q|Q|exit) 
                print_logo
                echo -e "${CYAN}Thank you for using Ethereum Node Installer!${NC}"
                echo ""
                echo -e "Created with ❤️  by ${PURPLE}Aabis5004${NC}"
                echo -e "GitHub: ${BLUE}https://github.com/Aabis5004/ethereum-node-installer${NC}"
                echo ""
                echo "🌟 If this helped you, please star the repository!"
                echo ""
                exit 0 
                ;;
            *)
                print_error "Invalid choice. Please enter 0-9, or 'q' to quit."
                sleep 2
                ;;
        esac
    done
}

# Run the main function with all arguments
main "$@" Check RAM
    RAM_GB=$(free -g | awk '/^Mem:/{print $2}')
    if [ "$RAM_GB" -lt 8 ]; then
        print_warning "Only ${RAM_GB}GB RAM detected. 8-16GB recommended."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "RAM: ${RAM_GB}GB"
    fi
    
    # Check available disk space
    DISK_GB=$(df / | awk 'NR==2{printf "%.0f", $4/1024/1024}')
    if [ "$DISK_GB" -lt 550 ]; then
        print_warning "Only ${DISK_GB}GB free space. 550GB+ recommended."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Free space: ${DISK_GB}GB"
    fi
}

# Get user's public IP
get_public_ip() {
    PUBLIC_IP=$(curl -s --connect-timeout 10 ifconfig.me 2>/dev/null || curl -s --connect-timeout 10 ipinfo.io/ip 2>/dev/null || echo "unknown")
    if [ "$PUBLIC_IP" != "unknown" ]; then
        print_success "Detected public IP: $PUBLIC_IP"
    else
        print_warning "Could not detect public IP automatically"
        PUBLIC_IP="your-server-ip"
    fi
}

# Check port availability
check_ports() {
    print_info "Checking required ports..."
    REQUIRED_PORTS=(30303 8545 8546 8551 4000 3500)
    PORTS_IN_USE=()
    
    for port in "${REQUIRED_PORTS[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            PORTS_IN_USE+=($port)
        fi
    done
    
    if [ ${#PORTS_IN_USE[@]} -gt 0 ]; then
        print_warning "Ports in use: ${PORTS_IN_USE[*]}"
        print_warning "These services will need to be stopped or ports changed."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "All required ports available"
    fi
}

# Install all dependencies from original guide
install_dependencies() {
    print_info "Installing system dependencies..."
    
    # Update system
    apt-get update && apt-get upgrade -y
    
    # Install all packages from original guide
    apt install -y \
        curl iptables build-essential git wget lz4 jq make gcc nano \
        automake autoconf tmux htop nvme-cli libgbm1 pkg-config \
        libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip \
        bc net-tools ufw ca-certificates gnupg
    
    print_success "System dependencies installed"
}

# Install Docker (exactly from original guide)
install_docker() {
    print_info "Installing Docker..."
    
    # Remove old Docker packages (from original guide)
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
        apt-get remove -y $pkg 2>/dev/null || true
    done
    
    # Install Docker (exact steps from original guide)
    apt-get update
    apt-get install -y ca-certificates curl gnupg
    install -m 0755 -d /etc/apt/keyrings
    
    # Add Docker GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Test Docker
    if docker run hello-world >/dev/null 2>&1; then
        print_success "Docker installed and tested"
    else
        print_error "Docker installation failed"
        exit 1
    fi
    
    # Enable and start Docker
    systemctl enable docker
    systemctl restart docker
    
    print_success "Docker setup complete"
}

# Setup Ethereum directories and JWT (from original guide)
setup_ethereum() {
    print_info "Setting up Ethereum directories and JWT secret..."
    
    # Create directories (exact paths from original guide)
    mkdir -p /root/ethereum/execution
    mkdir -p /root/ethereum/consensus
    
    # Generate JWT secret (exact command from original guide)
    openssl rand -hex 32 > /root/ethereum/jwt.hex
    
    # Verify JWT secret
    if [ -f /root/ethereum/jwt.hex ] && [ -s /root/ethereum/jwt.hex ]; then
        print_success "JWT secret created"
        print_info "JWT content: $(cat /root/ethereum/jwt.hex)"
    else
        print_error "Failed to create JWT secret"
        exit 1
    fi
}

# Create docker-compose.yml (EXACT copy from original guide)
create_docker_compose() {
    print_info "Creating Docker Compose configuration..."
    
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
    
    print_success "Docker Compose configuration created"
}

# Configure firewall (enhanced from original guide)
configure_firewall() {
    print_info "Configuring firewall..."
    
    # Reset UFW to defaults
    ufw --force reset >/dev/null 2>&1
    
    # Default policies
    ufw default deny incoming >/dev/null 2>&1
    ufw default allow outgoing >/dev/null 2>&1
    
    # Allow SSH (from original guide)
    ufw allow 22 >/dev/null 2>&1
    ufw allow ssh >/dev/null 2>&1
    
    # Allow Geth P2P ports (required for blockchain sync - from original guide)
    ufw allow 30303/tcp comment 'Geth P2P TCP' >/dev/null 2>&1
    ufw allow 30303/udp comment 'Geth P2P UDP' >/dev/null 2>&1
    
    # Ask user about RPC access (simplified from original guide)
    echo ""
    print_warning "SECURITY CONFIGURATION:"
    echo "Your RPC endpoints will be available at:"
    echo "  - Execution (Geth): http://$PUBLIC_IP:8545"
    echo "  - Consensus (Prysm): http://$PUBLIC_IP:3500"
    echo ""
    echo "Choose access level:"
    echo "1) Localhost only (most secure) - Only accessible from this server"
    echo "2) Specific IP whitelist - You specify which IPs can access"
    echo "3) Public access - Anyone can access (NOT RECOMMENDED)"
    echo ""
    
    while true; do
        read -p "Enter choice (1-3): " choice
        case $choice in
            1)
                print_info "Configuring localhost-only access..."
                # From original guide - allow localhost, deny external
                ufw allow from 127.0.0.1 to any port 8545 proto tcp comment 'Geth RPC localhost' >/dev/null 2>&1
                ufw allow from 127.0.0.1 to any port 3500 proto tcp comment 'Prysm RPC localhost' >/dev/null 2>&1
                ufw deny 8545/tcp comment 'Deny Geth RPC external' >/dev/null 2>&1
                ufw deny 3500/tcp comment 'Deny Prysm RPC external' >/dev/null 2>&1
                print_success "Configured for localhost access only"
                break
                ;;
            2)
                print_info "Configuring IP whitelist access..."
                echo "Enter IP addresses you want to allow (one per line, empty line to finish):"
                ALLOWED_IPS=()
                while true; do
                    read -p "IP address: " ip
                    if [ -z "$ip" ]; then
                        break
                    fi
                    # Basic IP validation
                    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
                        ALLOWED_IPS+=($ip)
                        # From original guide - allow specific IP
                        ufw allow from $ip to any port 8545 proto tcp comment "Geth RPC from $ip" >/dev/null 2>&1
                        ufw allow from $ip to any port 3500 proto tcp comment "Prysm RPC from $ip" >/dev/null 2>&1
                        print_success "Added $ip to whitelist"
                    else
                        print_warning "Invalid IP format: $ip"
                    fi
                done
                
                # Deny all other IPs (from original guide)
                ufw deny 8545/tcp comment 'Deny Geth RPC others' >/dev/null 2>&1
                ufw deny 3500/tcp comment 'Deny Prysm RPC others' >/dev/null 2>&1
                print_success "Configured IP whitelist access"
                break
                ;;
            3)
                print_warning "Configuring public access - USE WITH CAUTION!"
                read -p "Are you sure? This allows anyone to access your node (y/N): " -n 1 -r
                echo
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    ufw allow 8545/tcp comment 'Geth RPC public' >/dev/null 2>&1
                    ufw allow 3500/tcp comment 'Prysm RPC public' >/dev/null 2>&1
                    print_warning "Configured for public access"
                    break
                fi
                ;;
            *)
                print_error "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
    
    # Enable firewall
    ufw --force enable >/dev/null 2>&1
    print_success "Firewall configured and enabled"
}

# Start services
start_services() {
    print_info "Starting Ethereum node services..."
    
    cd /root/ethereum
    
    # Pull images first
    docker compose pull
    
    # Start services
    if docker compose up -d; then
        print_success "Services started successfully"
    else
        print_error "Failed to start services"
        exit 1
    fi
}

# Create helper scripts
create_helper_scripts() {
    print_info "Creating helper commands..."
    
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
    
    print_success "Helper commands created (you can use 'eth-node start/stop/logs' etc.)"
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
                show_final_info
                return
                ;;
            3)
                return
                ;;
        esac
    fi
    
    echo ""
    echo -e "${YELLOW}Ready to install! This will:${NC}"
    echo "• Check system requirements"
    echo "• Install Docker and all dependencies"
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
    
    # Run all installation steps (following original guide)
    check_root
    check_ubuntu
    check_requirements
    get_public_ip
    check_ports
    install_dependencies
    install_docker
    setup_ethereum
    create_docker_compose
    configure_firewall
    start_services
    create_helper_scripts
    
    sleep 3
    show_final_info
}

# Show final information
show_final_info() {
    print_logo
    echo -e "${GREEN}${STAR}${STAR}${STAR} INSTALLATION COMPLETE! ${STAR}${STAR}${STAR}${NC}"
    echo ""
    echo -e "${CYAN}🎉 Your Ethereum node is now running!${NC}"
    echo ""
    echo -e "${YELLOW}📍 RPC ENDPOINTS:${NC}"
    echo "   • Execution (Geth): http://localhost:8545"
    if [ "$PUBLIC_IP" != "unknown" ] && [ "$PUBLIC_IP" != "your-server-ip" ]; then
        echo "   • External Execution: http://$PUBLIC_IP:8545"
    fi
    echo "   • Consensus (Prysm): http://localhost:3500"
    if [ "$PUBLIC_IP" != "unknown" ] && [ "$PUBLIC_IP" != "your-server-ip" ]; then
        echo "   • External Consensus: http://$PUBLIC_IP:3500"
    fi
    echo ""
    echo -e "${YELLOW}🔧 QUICK COMMANDS:${NC}"
    echo "   • Check status: $0 (select option 2)"
    echo "   • View logs:    docker compose logs -f"
    echo "   • Stop node:    eth-node stop"
    echo "   • Start node:   eth-node start"
    echo ""
    echo -e "${YELLOW}🔍 CHECK SYNC STATUS:${NC}"
    echo '   Execution:  curl -X POST -H "Content-Type: application/json" --data '"'"'{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}'"'"' http://localhost:8545'
    echo "   Consensus:  curl http://localhost:3500/eth/v1/node/syncing"
    echo ""
    echo -e "${YELLOW}${WARNING} IMPORTANT NOTES:${NC}"
    echo "   • Initial sync will take 4-24 hours"
    echo "   • Monitor disk space - blockchain data grows continuously"
    echo "   • This is Sepolia testnet, not mainnet"
    echo "   • Keep your system updated and monitor logs regularly"
    echo ""
    read -p "Press Enter to return to main menu..."
}

# Check node status
check_status() {
    print_logo
    echo -e "${INFO} ${CYAN}ETHEREUM NODE STATUS${NC}"
    echo ""
    
    if [ ! -d "/root/ethereum" ]; then
        print_error "Node not installed! Run option 1 first."
        echo ""
        read -p "Press Enter to continue..."
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
    
    # Check Geth sync status (from original guide)
    echo -n "   Execution (Geth): "
    if timeout 10 curl -s -X POST -H "Content-Type: application/json" \
       --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
       http://localhost:8545 2>/dev/null | grep -q '"result":false'; then
        echo -e "${GREEN}✅ Synced${NC}"
    else
        if timeout 10 curl -s -X POST -H "Content-Type: application/json" \
           --data '{"jsonrpc":"2.0","method":"eth_syncing","params":[],"id":1}' \
           http://localhost:8545 2>/dev/null | grep -q '"result":{'; then
            echo -e "${YELLOW}🔄 Syncing...${NC}"
        else
            echo -e "${RED}❌ Not responding${NC}"
        fi
    fi
    
    # Check Prysm sync status (from original guide) 
    echo -n "   Consensus (Prysm): "
    if timeout 10 curl -s http://localhost:3500/eth/v1/node/syncing 2>/dev/null | grep -q '"is_syncing":false'; then
        echo -e "${GREEN}✅ Synced${NC}"
    else
        if timeout 10 curl -s http://localhost:3500/eth/v1/node/syncing 2>/dev/null | grep -q '"is_syncing":true'; then
            echo -e "${YELLOW}🔄 Syncing...${NC}"
        else
            echo -e "${RED}❌ Not responding${NC}"
        fi
    fi
    
    echo ""
    echo -e "${YELLOW}💾 System Resources:${NC}"
    
    # Disk usage
    echo -n "   Free Space: "
    df -h / | tail -1 | awk '{print $4 " (" $5 " used)"}'
    
    # Data sizes (from original guide)
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
    echo "1) Both (Geth + Prysm) - Live"
    echo "2) Geth only - Live"
    echo "3) Prysm only - Live" 
    echo "4) Last 100 lines - All"
    echo "5) Back to menu"
    echo ""
    read -p "Enter choice (1-5): " choice
    
    cd /root/ethereum
    case $choice in
        1) docker compose logs -f ;;
        2) docker logs geth -f ;;
        3) docker logs prysm -f ;;
        4) docker compose logs --tail=100 ;;
        5) return ;;
        *) docker compose logs -f ;;
    esac
}

# Troubleshoot
troubleshoot() {
    print_logo
    echo -e "${WARNING} ${CYAN}TROUBLESHOOTING${NC}"
    echo ""
    
    print_info "Running comprehensive diagnostics..."
    echo ""
    
    # Check if node exists
    if [ -d "/root/ethereum" ]; then
        print_success "Node directory exists"
    else
        print_error "Node not installed - run option 1 first"
        read -p "Press Enter to continue..."
        return
    fi
    
    cd /root/ethereum
    
    # Check files
    if [ -f "docker-compose.yml" ]; then
        print_success "Docker compose file exists"
    else
        print_error "Docker compose file missing"
    fi
    
    if [ -f "jwt.hex" ]; then
        print_success "JWT secret file exists"
    else
        print_error "JWT secret file missing"
    fi
    
    # Container check
    echo ""
    print_info "Container status:"
    if docker compose ps | grep -q "Up"; then
        print_success "Containers running"
        docker compose ps
    else
        print_error "Containers not running"
        echo ""
        print_info "Trying to start containers..."
        docker compose up -d
    fi
    
    # Port check
    echo ""
    print_info "Port status:"
    PORTS=(30303 8545 8551 4000 3500)
    for port in "${PORTS[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            print_success "Port $port is open"
        else
            print_warning "Port $port is not responding"
        fi
    done
    
    # Connectivity check
    echo ""
    print_info "RPC connectivity:"
    if timeout 5 curl -s http://localhost:8545 >/dev/null 2>&1; then
        print_success "Geth RPC responding"
    else
        print_error "Geth RPC not responding"
    fi
    
    if timeout 5 curl -s http://localhost:3500 >/dev/null 2>&1; then
        print_success "Prysm RPC responding"
    else
        print_error "Prysm RPC not responding"
    fi
    
    #
