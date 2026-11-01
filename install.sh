#!/bin/bash

######################################################################
# RootX Toolkit Installer
# -------------------------------------------------------------------
# Automated installation of security tools for:
#   - Reconnaissance
#   - Subdomain Enumeration
#   - Web Application Testing
#   - Vulnerability Scanning
#   - OSINT
#   - Exploitation
#   - Post Exploitation
# -------------------------------------------------------------------
# Supported: Debian/Ubuntu | Kali Linux | CentOS/RHEL/Fedora
# Requirements: go, git, python3, pip3
# GitHub: github.com/Depanshu-InfoSec/rootx-toolkit
######################################################################

SECONDS=0
LOG_FILE="$HOME/rootx_install.log"
FAILED_TOOLS=()

# ─── COLORS ──────────────────────────────────────────────────────────
red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
purple='\033[0;35m'
cyan='\033[0;36m'
white='\033[1;37m'
bold='\033[1m'
reset='\033[0m'

# ─── BANNER ──────────────────────────────────────────────────────────
function banner() {
    clear
    echo -e "${red}"
    echo -e "  ██████╗  ██████╗  ██████╗ ████████╗██╗  ██╗"
    echo -e "  ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝╚██╗██╔╝"
    echo -e "  ██████╔╝██║   ██║██║   ██║   ██║    ╚███╔╝ "
    echo -e "  ██╔══██╗██║   ██║██║   ██║   ██║    ██╔██╗ "
    echo -e "  ██║  ██║╚██████╔╝╚██████╔╝   ██║   ██╔╝ ██╗"
    echo -e "  ╚═╝  ╚═╝ ╚═════╝  ╚═════╝   ╚═╝   ╚═╝  ╚═╝"
    echo -e "${reset}"
    echo -e "${white}  ══════════════════════════════════════════════${reset}"
    echo -e "${cyan}       RootX Security Toolkit Installer v1.0     ${reset}"
    echo -e "${cyan}       AI-Powered Pentesting | github.com/Depanshu-InfoSec/rootx-toolkit ${reset}"
    echo -e "${white}  ══════════════════════════════════════════════${reset}"
    echo -e "${yellow}  [!] Use responsibly. Only test authorized targets.${reset}"
    echo -e ""
}

# ─── PRINT HELPERS ───────────────────────────────────────────────────
function INFO()    { echo -e "${blue}  [INFO]${reset}    $*" | tee -a "$LOG_FILE"; }
function SUCCESS() { echo -e "${green}  [OK]${reset}      $*" | tee -a "$LOG_FILE"; }
function WARNING() { echo -e "${yellow}  [WARN]${reset}    $*" | tee -a "$LOG_FILE"; }
function ERROR()   { echo -e "${red}  [ERROR]${reset}   $*" | tee -a "$LOG_FILE"; }
function SECTION() { echo -e "\n${purple}  ━━━ $* ━━━${reset}" | tee -a "$LOG_FILE"; }

# ─── DETECT OS ───────────────────────────────────────────────────────
function detect_os() {
    if [ -f /etc/os-release ]; then
        source /etc/os-release
        OS=$ID
        OS_LIKE=$ID_LIKE
    else
        OS=$(uname -s)
    fi

    case "$OS" in
        ubuntu|debian|kali|parrot|linuxmint)
            PKG_MANAGER="apt"
            PKG_INSTALL="sudo apt install -y"
            PKG_UPDATE="sudo apt update -y"
            INFO "Detected: $NAME (Debian-based)"
            ;;
        centos|rhel|fedora|rocky|almalinux)
            if command -v dnf &>/dev/null; then
                PKG_MANAGER="dnf"
                PKG_INSTALL="sudo dnf install -y"
                PKG_UPDATE="sudo dnf check-update"
            else
                PKG_MANAGER="yum"
                PKG_INSTALL="sudo yum install -y"
                PKG_UPDATE="sudo yum check-update"
            fi
            INFO "Detected: $NAME (RedHat-based)"
            ;;
        arch|manjaro)
            PKG_MANAGER="pacman"
            PKG_INSTALL="sudo pacman -S --noconfirm"
            PKG_UPDATE="sudo pacman -Sy"
            INFO "Detected: $NAME (Arch-based)"
            ;;
        *)
            WARNING "Unknown OS ($OS). Defaulting to apt."
            PKG_MANAGER="apt"
            PKG_INSTALL="sudo apt install -y"
            PKG_UPDATE="sudo apt update -y"
            ;;
    esac
}

# ─── CHECK BINARY ────────────────────────────────────────────────────
function CHECK_BINARY() {
    if command -v "$1" &>/dev/null; then
        declare -g "${1^^}_INSTALLED"=true
        return 0
    else
        declare -g "${1^^}_INSTALLED"=false
        return 1
    fi
}

# ─── INSTALL SYSTEM PACKAGES ─────────────────────────────────────────
function install_system_deps() {
    SECTION "Installing System Dependencies"

    $PKG_UPDATE >> "$LOG_FILE" 2>&1

    case "$PKG_MANAGER" in
        apt)
            DEPS=(
                git curl wget unzip python3 python3-pip python3-venv
                nmap masscan nikto sqlmap hydra john hashcat
                net-tools dnsutils whois libpcap-dev build-essential
                ruby ruby-dev libssl-dev libffi-dev
                chromium-driver jq libxml2-utils
            )
            ;;
        dnf|yum)
            DEPS=(
                git curl wget unzip python3 python3-pip
                nmap masscan nikto sqlmap hydra john hashcat
                net-tools bind-utils whois libpcap-devel gcc gcc-c++
                ruby ruby-devel openssl-devel libffi-devel
                jq libxml2
            )
            ;;
        pacman)
            DEPS=(
                git curl wget unzip python python-pip
                nmap masscan nikto sqlmap hydra john hashcat
                net-tools bind-tools whois libpcap base-devel
                ruby openssl libffi jq libxml2
            )
            ;;
    esac

    for dep in "${DEPS[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            $PKG_INSTALL "$dep" >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                SUCCESS "$dep installed"
            else
                WARNING "$dep failed to install (may not be available in repos)"
            fi
        else
            INFO "$dep already installed"
        fi
    done
}

# ─── INSTALL GO ──────────────────────────────────────────────────────
function install_go() {
    SECTION "Checking Go Installation"

    if CHECK_BINARY go; then
        GO_VERSION=$(go version | awk '{print $3}')
        SUCCESS "Go already installed: $GO_VERSION"
        return
    fi

    INFO "Go not found. Installing..."
    GO_VERSION="1.21.5"
    ARCH=$(uname -m)

    case "$ARCH" in
        x86_64) GO_ARCH="amd64" ;;
        aarch64|arm64) GO_ARCH="arm64" ;;
        *) GO_ARCH="amd64" ;;
    esac

    wget -q "https://go.dev/dl/go${GO_VERSION}.linux-${GO_ARCH}.tar.gz" -O /tmp/go.tar.gz
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf /tmp/go.tar.gz
    rm /tmp/go.tar.gz

    # Add to PATH for current session and permanently
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

    # Add to shell config
    for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
        if [ -f "$rc" ]; then
            if ! grep -q "/usr/local/go/bin" "$rc"; then
                echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> "$rc"
            fi
        fi
    done

    if CHECK_BINARY go; then
        SUCCESS "Go installed successfully: $(go version)"
    else
        ERROR "Go installation failed. Please install manually from https://go.dev/dl/"
        exit 1
    fi
}

# ─── INSTALL GO TOOL ─────────────────────────────────────────────────
TOTAL_GO=0
PASS_GO=0
FAIL_GO=0

function install_go_tool() {
    local name="$1"
    local cmd="$2"
    TOTAL_GO=$((TOTAL_GO + 1))

    eval "$cmd" >> "$LOG_FILE" 2>&1
    if [ $? -eq 0 ] && command -v "$name" &>/dev/null 2>&1 || [ -f "$HOME/go/bin/$name" ]; then
        SUCCESS "$name installed ($PASS_GO/$TOTAL_GO)"
        PASS_GO=$((PASS_GO + 1))
    else
        ERROR "Failed: $name — try: $cmd"
        FAIL_GO=$((FAIL_GO + 1))
        FAILED_TOOLS+=("$name")
    fi
}

# ─── INSTALL PYTHON TOOLS ────────────────────────────────────────────
function install_python_tools() {
    SECTION "Python Tools"

    declare -A pytools=(
        ["theHarvester"]="pip3 install theHarvester"
        ["shodan"]="pip3 install shodan"
        ["arjun"]="pip3 install arjun"
        ["dnsrecon"]="pip3 install dnsrecon"
        ["trufflehog"]="pip3 install trufflehog"
        ["wafw00f"]="pip3 install wafw00f"
        ["wfuzz"]="pip3 install wfuzz"
        ["S3Scanner"]="pip3 install s3scanner"
        ["certipy-ad"]="pip3 install certipy-ad"
    )

    for tool in "${!pytools[@]}"; do
        pip3 install "$tool" >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            SUCCESS "$tool installed"
        else
            WARNING "$tool failed — try manually: ${pytools[$tool]}"
            FAILED_TOOLS+=("$tool")
        fi
    done
}

# ─── INSTALL GIT-CLONED TOOLS ────────────────────────────────────────
function install_git_tools() {
    SECTION "Git-based Tools"

    TOOLS_DIR="$HOME/tools"
    mkdir -p "$TOOLS_DIR"

    declare -A git_tools=(
        ["LinkFinder"]="https://github.com/GerbenJavado/LinkFinder.git"
        ["GitTools"]="https://github.com/internetwache/GitTools.git"
        ["dirsearch"]="https://github.com/maurosoria/dirsearch.git"
        ["jwt_tool"]="https://github.com/ticarpi/jwt_tool.git"
        ["CORScanner"]="https://github.com/chenjj/CORScanner.git"
        ["CORS-Scanner"]="https://github.com/RUB-NDS/CORStest.git"
        ["403bypass"]="https://github.com/iamj0ker/bypass-403.git"
        ["XSStrike"]="https://github.com/s0md3v/XSStrike.git"
        ["CMSeeK"]="https://github.com/Tuhinshubhra/CMSeeK.git"
        ["Wordlists-SecLists"]="https://github.com/danielmiessler/SecLists.git"
    )

    for tool in "${!git_tools[@]}"; do
        DEST="$TOOLS_DIR/$tool"
        if [ -d "$DEST" ]; then
            INFO "$tool already cloned — pulling latest"
            git -C "$DEST" pull -q >> "$LOG_FILE" 2>&1
        else
            git clone --depth=1 "${git_tools[$tool]}" "$DEST" >> "$LOG_FILE" 2>&1
            if [ $? -eq 0 ]; then
                SUCCESS "$tool cloned to $DEST"
            else
                ERROR "$tool clone failed"
                FAILED_TOOLS+=("$tool")
            fi
        fi
    done
}

# ─── COPY GO BINARIES ────────────────────────────────────────────────
function copy_go_bins() {
    SECTION "Copying Go Binaries to /usr/local/bin"
    if [ -d "$HOME/go/bin" ]; then
        sudo cp "$HOME/go/bin/"* /usr/local/bin/ 2>/dev/null
        SUCCESS "All Go binaries copied to /usr/local/bin"
    else
        WARNING "$HOME/go/bin not found — binaries may not be in PATH"
    fi
}

# ─── SUMMARY REPORT ──────────────────────────────────────────────────
function print_summary() {
    duration=$SECONDS
    SECTION "Installation Summary"
    echo -e ""
    echo -e "${green}  ✔  Go Tools Installed    : $PASS_GO${reset}"
    echo -e "${red}  ✘  Go Tools Failed      : $FAIL_GO${reset}"
    echo -e "${cyan}  📁 Tools Directory      : $HOME/tools${reset}"
    echo -e "${cyan}  📄 Full log             : $LOG_FILE${reset}"
    echo -e "${yellow}  ⏱  Total Time           : $(($duration / 60))m $(($duration % 60))s${reset}"
    echo -e ""

    if [ ${#FAILED_TOOLS[@]} -ne 0 ]; then
        WARNING "Failed tools (install manually):"
        for t in "${FAILED_TOOLS[@]}"; do
            echo -e "    ${red}→ $t${reset}"
        done
    fi

    echo -e ""
    echo -e "${white}  ══════════════════════════════════════════════${reset}"
    echo -e "${cyan}  RootX Toolkit ready. Run 'source ~/.bashrc' to reload PATH.${reset}"
    echo -e "${red}  [!] Only use on authorized targets.${reset}"
    echo -e "${white}  ══════════════════════════════════════════════${reset}"
}

# ════════════════════════════════════════════════════════════════════
#  MAIN EXECUTION
# ════════════════════════════════════════════════════════════════════

banner
echo "" > "$LOG_FILE"
INFO "RootX Toolkit Installer started at $(date)" | tee -a "$LOG_FILE"

detect_os
install_system_deps
install_go

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# ─── GO TOOLS ───────────────────────────────────────────────────────

# ProjectDiscovery Suite
SECTION "ProjectDiscovery Suite"
install_go_tool "nuclei"            "go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"
install_go_tool "subfinder"         "go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"
install_go_tool "httpx"             "go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest"
install_go_tool "naabu"             "go install -v github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
install_go_tool "notify"            "go install -v github.com/projectdiscovery/notify/cmd/notify@latest"
install_go_tool "dnsx"              "go install -v github.com/projectdiscovery/dnsx/cmd/dnsx@latest"
install_go_tool "interactsh-client" "go install -v github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
install_go_tool "mapcidr"           "go install -v github.com/projectdiscovery/mapcidr/cmd/mapcidr@latest"
install_go_tool "tlsx"              "go install -v github.com/projectdiscovery/tlsx/cmd/tlsx@latest"
install_go_tool "katana"            "go install -v github.com/projectdiscovery/katana/cmd/katana@latest"
install_go_tool "cdncheck"          "go install -v github.com/projectdiscovery/cdncheck/cmd/cdncheck@latest"
install_go_tool "asnmap"            "go install -v github.com/projectdiscovery/asnmap/cmd/asnmap@latest"
install_go_tool "uncover"           "go install -v github.com/projectdiscovery/uncover/cmd/uncover@latest"
install_go_tool "pdtm"              "go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest"
install_go_tool "cloudlist"         "go install -v github.com/projectdiscovery/cloudlist/cmd/cloudlist@latest"
install_go_tool "proxify"           "go install -v github.com/projectdiscovery/proxify/cmd/proxify@latest"
install_go_tool "shuffledns"        "go install -v github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"
install_go_tool "alterx"            "go install -v github.com/projectdiscovery/alterx/cmd/alterx@latest"

# OWASP
SECTION "OWASP Tools"
install_go_tool "amass" "go install -v github.com/owasp-amass/amass/v4/...@master"

# Tom Hudson (tomnomnom) Tools
SECTION "TomNomNom Tools"
install_go_tool "gf"           "go install -v github.com/tomnomnom/gf@latest"
install_go_tool "qsreplace"    "go install -v github.com/tomnomnom/qsreplace@latest"
install_go_tool "waybackurls"  "go install -v github.com/tomnomnom/waybackurls@latest"
install_go_tool "anew"         "go install -v github.com/tomnomnom/anew@latest"
install_go_tool "unfurl"       "go install -v github.com/tomnomnom/unfurl@latest"
install_go_tool "inscope"      "go install -v github.com/tomnomnom/hacks/inscope@latest"
install_go_tool "httprobe"     "go install -v github.com/tomnomnom/httprobe@latest"
install_go_tool "assetfinder"  "go install -v github.com/tomnomnom/assetfinder@latest"
install_go_tool "meg"          "go install -v github.com/tomnomnom/meg@latest"
install_go_tool "freq"         "go install -v github.com/tomnomnom/freq@latest"
install_go_tool "concurl"      "go install -v github.com/tomnomnom/concurl@latest"

# Reconnaissance Tools
SECTION "Reconnaissance and OSINT Tools"
install_go_tool "github-subdomains"       "go install -v github.com/gwen001/github-subdomains@latest"
install_go_tool "github-endpoints"        "go install -v github.com/gwen001/github-endpoints@latest"
install_go_tool "analyticsrelationships"  "go install -v github.com/Josue87/analyticsrelationships@latest"
install_go_tool "gotator"                 "go install -v github.com/Josue87/gotator@latest"
install_go_tool "roboxtractor"            "go install -v github.com/Josue87/roboxtractor@latest"
install_go_tool "puredns"                 "go install -v github.com/d3mondev/puredns/v2@latest"
install_go_tool "hakrawler"               "go install -v github.com/hakluke/hakrawler@latest"
install_go_tool "hakrevdns"               "go install -v github.com/hakluke/hakrevdns@latest"
install_go_tool "hakcheckurl"             "go install -v github.com/hakluke/hakcheckurl@latest"
install_go_tool "asnip"                   "go install -v github.com/harleo/asnip@latest"

# URL and Parameter Tools
SECTION "URL and Parameter Tools"
install_go_tool "gauplus"  "go install -v github.com/bp0lr/gauplus@latest"
install_go_tool "gau"      "go install -v github.com/lc/gau/v2/cmd/gau@latest"
install_go_tool "subjs"    "go install -v github.com/lc/subjs@latest"
install_go_tool "dsieve"   "go install -v github.com/trickest/dsieve@master"
install_go_tool "mksub"    "go install -v github.com/trickest/mksub@latest"
install_go_tool "rush"     "go install -v github.com/shenwei356/rush@latest"

# Web Application Testing Tools
SECTION "Web Application Testing Tools"
install_go_tool "ffuf"                          "go install -v github.com/ffuf/ffuf@latest"
install_go_tool "Gxss"                          "go install -v github.com/KathanP19/Gxss@latest"
install_go_tool "gospider"                      "go install -v github.com/jaeles-project/gospider@latest"
install_go_tool "gowitness"                     "go install -v github.com/sensepost/gowitness@latest"
install_go_tool "crlfuzz"                       "go install -v github.com/dwisiswant0/crlfuzz/cmd/crlfuzz@latest"
install_go_tool "dalfox"                        "go install -v github.com/hahwul/dalfox/v2@latest"
install_go_tool "Web-Cache-Vulnerability-Scanner" "go install -v github.com/Hackmanit/Web-Cache-Vulnerability-Scanner@latest"
install_go_tool "headi"                         "go install -v github.com/mlcsec/headi@latest"
install_go_tool "shortscan"                     "go install -v github.com/bitquark/shortscan/cmd/shortscan@latest"
install_go_tool "kxss"                          "go install -v github.com/Emoe/kxss@latest"
install_go_tool "bxss"                          "go install -v github.com/ethiack/bxss@latest"
install_go_tool "mantra"                        "go install -v github.com/MrEmpy/mantra@latest"
install_go_tool "haklistgen"                    "go install -v github.com/hakluke/haklistgen@latest"

# DNS and Subdomain Takeover
SECTION "DNS and Subdomain Takeover Tools"
install_go_tool "dnstake"    "go install -v github.com/pwnesia/dnstake/cmd/dnstake@latest"
install_go_tool "enumerepo"  "go install -v github.com/trickest/enumerepo@latest"

# Infrastructure and Cloud
SECTION "Infrastructure and Cloud Tools"
install_go_tool "ipcdn"        "go install -v github.com/six2dez/ipcdn@latest"
install_go_tool "smap"         "go install -v github.com/s0md3v/smap/cmd/smap@latest"
install_go_tool "cdncheck"     "go install -v github.com/projectdiscovery/cdncheck/cmd/cdncheck@latest"
install_go_tool "cent"         "go install -v github.com/xm1k3/cent@latest"

# Git and Secret Scanning
SECTION "Git and Secret Scanning Tools"
install_go_tool "gitdorks_go"  "go install -v github.com/damit5/gitdorks_go@latest"
install_go_tool "gitleaks"     "go install -v github.com/zricethezav/gitleaks/v8@latest"

# Python, Git, and System Tools
install_python_tools
install_git_tools
copy_go_bins
print_summary

