<div align="center">

```
  ██████╗  ██████╗  ██████╗ ████████╗██╗  ██╗
  ██╔══██╗██╔═══██╗██╔═══██╗╚══██╔══╝╚██╗██╔╝
  ██████╔╝██║   ██║██║   ██║   ██║    ╚███╔╝ 
  ██╔══██╗██║   ██║██║   ██║   ██║    ██╔██╗ 
  ██║  ██║╚██████╔╝╚██████╔╝   ██║   ██╔╝ ██╗
  ╚═╝  ╚═╝ ╚═════╝  ╚═════╝   ╚═╝   ╚═╝  ╚═╝
```

# RootX Security Toolkit

**An automated installer for 60+ offensive security tools**

[![License: MIT](https://img.shields.io/badge/License-MIT-red.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)]()
[![Tools](https://img.shields.io/badge/Tools-60+-green.svg)]()
[![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen.svg)]()

> ⚠️ **For authorized use only. Only test systems you have permission to test.**

</div>

---

## 📦 What's Included

| Category | Tools |
|---|---|
| **Subdomain Enumeration** | subfinder, amass, assetfinder, github-subdomains, puredns, dnsx, shuffledns, alterx |
| **Port Scanning** | naabu, nmap, masscan, smap |
| **Web Crawling** | katana, hakrawler, gospider, gauplus, gau, waybackurls, meg |
| **HTTP Probing** | httpx, httprobe, hakcheckurl |
| **Directory Fuzzing** | ffuf, feroxbuster, dirsearch |
| **XSS Testing** | dalfox, Gxss, kxss, bxss, XSStrike |
| **Parameter Discovery** | arjun, x8, headi |
| **Vulnerability Scanning** | nuclei, nikto |
| **DNS Tools** | dnsx, dnstake, asnmap, asnip |
| **Secret/Git Scanning** | gitleaks, trufflehog, gitdorks_go, github-endpoints |
| **OSINT** | theHarvester, shodan, uncover, analyticsrelationships |
| **TLS/SSL** | tlsx |
| **Cache Attacks** | Web-Cache-Vulnerability-Scanner |
| **Utilities** | anew, unfurl, qsreplace, gf, inscope, jq, rush |
| **Cloud/CDN** | cdncheck, cloudlist, S3Scanner |
| **Payload / Injection** | sqlmap, hydra |
| **Git Cloned Tools** | LinkFinder, dirsearch, jwt_tool, XSStrike, CMSeeK, SecLists |

---

## 🖥️ Supported Systems

| OS | Tested | Package Manager |
|---|---|---|
| **Kali Linux** | ✅ | apt |
| **Debian 11/12** | ✅ | apt |
| **Ubuntu 20.04/22.04** | ✅ | apt |
| **CentOS 7/8** | ✅ | yum/dnf |
| **RHEL / Rocky / AlmaLinux** | ✅ | dnf |
| **Parrot OS** | ✅ | apt |

---

## 🚀 Quick Install

### Kali Linux / Debian / Ubuntu / Parrot

```bash
# Clone the repo
git clone https://github.com/Depanshu-InfoSec/rootx-toolkit.git

# Enter directory
cd rootx-toolkit

# Give execute permission
chmod +x install.sh

# Run as normal user (NOT root — Go tools install to $HOME/go/bin)
./install.sh
```

### CentOS 7

```bash
# Install git first if not present
sudo yum install -y git

# Clone the repo
git clone https://github.com/Depanshu-InfoSec/rootx-toolkit.git
cd rootx-toolkit
chmod +x install.sh
./install.sh
```

### CentOS 8 / RHEL / Rocky / AlmaLinux

```bash
# Install git first if not present
sudo dnf install -y git

# Clone the repo
git clone https://github.com/Depanshu-InfoSec/rootx-toolkit.git
cd rootx-toolkit
chmod +x install.sh
./install.sh
```

---

## 🔄 After Installation

```bash
# Reload your shell PATH so all tools are available
source ~/.bashrc

# Or if using zsh
source ~/.zshrc

# Verify a tool works
subfinder -version
nuclei -version
ffuf -V
```

---

## 📁 Directory Structure After Install

```
$HOME/
├── go/
│   └── bin/          ← all Go binaries installed here
├── tools/
│   ├── LinkFinder/    ← JS endpoint extractor
│   ├── dirsearch/      ← directory brute-forcer
│   ├── XSStrike/        ← XSS scanner
│   ├── jwt_tool/         ← JWT testing
│   ├── CMSeeK/            ← CMS fingerprinting
│   └── SecLists/           ← wordlists
└── rootx_install.log   ← full installation log
```

---

## 🛠️ Manual Installation of a Specific Tool

If a specific tool failed, the installer prints the exact command. You can also run any of these:

```bash
# Example: reinstall nuclei
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Example: reinstall subfinder
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest

# Example: reinstall ffuf
go install -v github.com/ffuf/ffuf@latest

# Copy newly installed binary to /usr/local/bin
sudo cp ~/go/bin/nuclei /usr/local/bin/
```

---

## 📋 Common Tool Usage Examples

```bash
# Subdomain enumeration
subfinder -d target.com -o subs.txt
amass enum -passive -d target.com

# HTTP probing
cat subs.txt | httpx -status-code -title -tech-detect

# Port scanning
naabu -host target.com -p -
nmap -sV -sC -p- target.com

# Directory fuzzing
ffuf -u https://target.com/FUZZ -w ~/tools/SecLists/Discovery/Web-Content/raft-large-directories.txt

# XSS testing
echo "https://target.com/search?q=test" | dalfox pipe

# Vulnerability scanning
nuclei -u https://target.com -t ~/nuclei-templates/

# JS endpoint extraction
python3 ~/tools/LinkFinder/linkfinder.py -i https://target.com/app.js -o cli

# Secret scanning
gitleaks detect --source /path/to/repo
```

---

## 📄 Installation Log

The full log is saved to `~/rootx_install.log`. Check it if something fails:

```bash
cat ~/rootx_install.log | grep ERROR
```

---

## ⚠️ Legal Disclaimer

RootX Toolkit is intended for **authorized security testing, educational use, and CTF challenges only**.

- Do **not** use against systems you do not own or have explicit written permission to test.
- The author is not responsible for any misuse.
- Always follow responsible disclosure practices.

---

## 👤 Author

**Depanshu**
B.Tech Student | Cybersecurity Enthusiast

- GitHub: [@Depanshu-InfoSec](https://github.com/Depanshu-InfoSec)

---

## 📜 License

MIT License — see [LICENSE](LICENSE) for details.
