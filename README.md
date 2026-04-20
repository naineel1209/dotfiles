# 🚀 The Ultimate WSL2 Fedora Developer Environment on D: Drive
### Complete End-to-End Setup Guide

> A bulletproof, portable, visually stunning developer environment with WSL2 + WSLg + Fedora on D: drive, featuring AWS, Terraform, Zed IDE, VS Code, Oh My Zsh, and a complete disaster-recovery workflow.

---

## 📋 Master Table of Contents

### 🏗 PHASE 1 — FOUNDATION
1. [Prerequisites & System Requirements](#1-prerequisites)
2. [WSL2 + WSLg Installation on Windows](#2-wsl-install)
3. [Directory Structure on D: Drive](#3-d-structure)

### 🐧 PHASE 2 — FEDORA ON D:
4. [Install Fedora to D: Drive](#4-fedora-install)
5. [Initial Fedora Configuration](#5-fedora-config)
6. [System Updates & Core Packages](#6-updates)

### 🎨 PHASE 3 — TERMINAL & SHELL
7. [Zsh + Oh My Zsh + Powerlevel10k](#7-shell)
8. [Nerd Fonts & Windows Terminal](#8-terminal)

### 🛠 PHASE 4 — DEV TOOLS
9. [Git, GitHub CLI, SSH Setup](#9-git)
10. [Language Runtimes (Node, Python, Go, Rust)](#10-languages)
11. [AWS CLI + Terraform + IaC Tools](#11-cloud)
12. [Docker & Kubernetes](#12-containers)

### 💻 PHASE 5 — IDEs
13. [VS Code with WSL Integration](#13-vscode)
14. [Zed IDE via WSLg](#14-zed)
15. [Productivity CLI Tools](#15-productivity)

### 🔐 PHASE 6 — BACKUP & DISASTER RECOVERY
16. [Dotfiles Management](#16-dotfiles)
17. [Automated Backup System](#17-backup)
18. [Disaster Recovery Playbook](#18-recovery)

### 🎯 PHASE 7 — WORKFLOW
19. [End-to-End Daily Workflow](#19-workflow)
20. [Quick Reference & Cheatsheet](#20-cheatsheet)

---

# 🏗 PHASE 1 — FOUNDATION

## 1. Prerequisites & System Requirements <a name="1-prerequisites"></a>

### ✅ Hardware Requirements
- **OS:** Windows 11 (or Windows 10 build 19044+)
- **RAM:** 16 GB minimum (32 GB recommended)
- **Disk:** 50+ GB free on D: drive
- **Virtualization:** Enabled in BIOS (Intel VT-x / AMD-V)

### ✅ GPU Drivers (for WSLg hardware acceleration)
- **NVIDIA:** [CUDA on WSL driver](https://developer.nvidia.com/cuda/wsl)
- **AMD:** Latest Adrenalin drivers
- **Intel:** Latest Intel Graphics driver

### ✅ Verify Virtualization

Open **Task Manager** → Performance → CPU → check "Virtualization: Enabled"

---

## 2. WSL2 + WSLg Installation on Windows <a name="2-wsl-install"></a>

### Step 2.1 — Install WSL (PowerShell as Administrator)

```powershell
# Enable WSL without installing any distro
wsl --install --no-distribution

# Update to latest kernel (includes WSLg)
wsl --update

# Set WSL2 as default
wsl --set-default-version 2

# Verify installation
wsl --version
```

✅ You should see output including `WSL version`, `Kernel version`, and **`WSLg version`**.

### Step 2.2 — Create Global `.wslconfig`

Create `C:\Users\<YourUser>\.wslconfig`:

```ini
[wsl2]
memory=8GB
processors=4
swap=4GB
localhostForwarding=true
nestedVirtualization=true

[experimental]
autoMemoryReclaim=gradual
sparseVhd=true
```

> 💡 Adjust `memory` and `processors` based on your machine. The `sparseVhd=true` keeps vhdx small.

---

## 3. Directory Structure on D: Drive <a name="3-d-structure"></a>

### Step 3.1 — Create Organized Folders (PowerShell)

```powershell
$dirs = @(
    "D:\WSL",
    "D:\WSL\Distros",
    "D:\WSL\Distros\FedoraDev",
    "D:\WSL\Backups",
    "D:\WSL\Tarballs",
    "D:\WSL\Scripts"
)
foreach ($d in $dirs) { New-Item -ItemType Directory -Force -Path $d | Out-Null }

Write-Host "✅ D: drive structure created" -ForegroundColor Green
tree D:\WSL /F
```

### 🗂 Final Structure

```
D:\
└── WSL\
    ├── Distros\              ← VHDX files live here
    │   └── FedoraDev\
    │       └── ext4.vhdx     ← Your dev environment
    ├── Backups\              ← Scheduled exports
    ├── Tarballs\             ← Source rootfs images
    └── Scripts\              ← Backup/restore scripts
```

---

# 🐧 PHASE 2 — FEDORA ON D:

## 4. Install Fedora to D: Drive <a name="4-fedora-install"></a>

### Step 4.1 — Get the Fedora Rootfs Tarball

**Easiest method: via Docker (using Docker Desktop OR any existing WSL distro)**

From PowerShell (if you have Docker installed):

```powershell
cd D:\WSL\Tarballs

docker pull fedora:latest
docker create --name fedora-temp fedora:latest
docker export fedora-temp -o fedora-rootfs.tar
docker rm fedora-temp

Write-Host "✅ Rootfs downloaded" -ForegroundColor Green
Get-Item D:\WSL\Tarballs\fedora-rootfs.tar
```

**Alternative: Download from Fedora registry (no Docker needed)**

```powershell
cd D:\WSL\Tarballs
Invoke-WebRequest `
  -Uri "https://github.com/fedora-cloud/docker-brew-fedora/raw/42/x86_64/fedora-42-x86_64.tar.xz" `
  -OutFile "fedora-42.tar.xz"
```

### Step 4.2 — Import Fedora to D:

```powershell
wsl --import FedoraDev D:\WSL\Distros\FedoraDev D:\WSL\Tarballs\fedora-rootfs.tar --version 2

# Set as default distro
wsl --set-default FedoraDev

# Verify
wsl --list --verbose
Get-Item D:\WSL\Distros\FedoraDev\ext4.vhdx
```

✅ You should see `ext4.vhdx` living on D: drive.

---

## 5. Initial Fedora Configuration <a name="5-fedora-config"></a>

### Step 5.1 — First Launch & User Creation

```powershell
wsl -d FedoraDev
```

Inside Fedora (running as root):

```bash
# Install essentials for user setup
dnf install -y sudo passwd util-linux-user which

# Create your user (replace 'yourusername')
useradd -m -G wheel -s /bin/bash yourusername
passwd yourusername

# Grant passwordless sudo
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
chmod 440 /etc/sudoers.d/wheel
```

### Step 5.2 — Configure `/etc/wsl.conf`

```bash
cat > /etc/wsl.conf << 'EOF'
[user]
default=yourusername

[boot]
systemd=true

[interop]
enabled=true
appendWindowsPath=true

[network]
generateHosts=true
generateResolvConf=true
hostname=fedora-dev

[automount]
enabled=true
options="metadata,umask=22,fmask=11"
EOF

exit
```

### Step 5.3 — Restart & Verify

```powershell
wsl --shutdown
Start-Sleep -Seconds 3
wsl -d FedoraDev
```

Inside Fedora:
```bash
whoami            # → yourusername
echo $DISPLAY     # → :0 (WSLg working)
echo $WAYLAND_DISPLAY  # → wayland-0
```

---

## 6. System Updates & Core Packages <a name="6-updates"></a>

```bash
# Full system update
sudo dnf upgrade --refresh -y

# Enable RPM Fusion repos
sudo dnf install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Install development essentials
sudo dnf groupinstall -y "Development Tools" "Development Libraries"

# Install core utilities
sudo dnf install -y \
  curl wget git vim nano \
  unzip tar zip xz \
  openssl-devel ca-certificates \
  dnf-plugins-core \
  htop tree jq yq \
  procps-ng iproute net-tools \
  man-db man-pages \
  gcc gcc-c++ make cmake \
  python3-pip
```

---

# 🎨 PHASE 3 — TERMINAL & SHELL

## 7. Zsh + Oh My Zsh + Powerlevel10k <a name="7-shell"></a>

### Step 7.1 — Install Zsh

```bash
sudo dnf install -y zsh
chsh -s $(which zsh)
```

### Step 7.2 — Install Oh My Zsh

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
```

### Step 7.3 — Install Powerlevel10k Theme

```bash
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
```

### Step 7.4 — Install Essential Plugins

```bash
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

git clone https://github.com/zsh-users/zsh-autosuggestions      $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting  $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions          $ZSH_CUSTOM/plugins/zsh-completions
git clone https://github.com/Aloxaf/fzf-tab                     $ZSH_CUSTOM/plugins/fzf-tab
```

### Step 7.5 — Configure `~/.zshrc`

```bash
cat > ~/.zshrc << 'EOF'
# Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  docker
  docker-compose
  kubectl
  terraform
  aws
  npm
  python
  sudo
  history
  z
  fzf-tab
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source $ZSH/oh-my-zsh.sh

# Powerlevel10k config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===== PATH =====
export PATH="$HOME/.local/bin:$PATH"

# ===== Aliases =====
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --git'
alias tree='eza --tree --icons'
alias cat='bat --style=plain'
alias grep='rg'
alias find='fd'

alias tf='terraform'
alias k='kubectl'
alias d='docker'
alias dc='docker compose'
alias gs='git status'
alias gp='git pull'
alias lg='lazygit'
alias reload='source ~/.zshrc'

alias winhome='cd /mnt/c/Users/$USER'
alias explorer='explorer.exe .'

# ===== NVM =====
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ===== pyenv =====
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
command -v pyenv >/dev/null && eval "$(pyenv init -)"

# ===== Go =====
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin

# ===== Rust =====
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

# ===== tfenv =====
export PATH="$HOME/.tfenv/bin:$PATH"

# ===== zoxide =====
command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# ===== direnv =====
command -v direnv >/dev/null && eval "$(direnv hook zsh)"

# ===== FZF =====
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
EOF

source ~/.zshrc
p10k configure   # Interactive wizard
```

---

## 8. Nerd Fonts & Windows Terminal <a name="8-terminal"></a>

### Step 8.1 — Install MesloLGS NF Font (on Windows)

Download all 4 files and install each (right-click → "Install for all users"):

- [Regular](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf)
- [Bold](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf)
- [Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf)
- [Bold Italic](https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf)

### Step 8.2 — Windows Terminal Profile

Open **Windows Terminal** → `Ctrl + ,` → "Open JSON file" (bottom-left gear).

Add this profile inside `profiles.list`:

```json
{
    "name": "🐧 Fedora Dev",
    "commandline": "wsl.exe -d FedoraDev",
    "startingDirectory": "//wsl$/FedoraDev/home/yourusername",
    "icon": "https://fedoraproject.org/w/uploads/thumb/6/6a/Fedora-logo.png/240px-Fedora-logo.png",
    "font": {
        "face": "MesloLGS NF",
        "size": 11
    },
    "colorScheme": "One Half Dark",
    "useAcrylic": true,
    "opacity": 85,
    "cursorShape": "filledBox",
    "padding": "8, 8, 8, 8"
}
```

Set `"defaultProfile"` to this profile's GUID (or use Settings UI → Startup → Default profile).

---

# 🛠 PHASE 4 — DEV TOOLS

## 9. Git, GitHub CLI, SSH Setup <a name="9-git"></a>

```bash
# Configure Git
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
git config --global pull.rebase true
git config --global core.editor "code --wait"
git config --global color.ui auto

# Generate SSH key
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519 -N ""
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copy public key (paste into GitHub/GitLab SSH keys)
cat ~/.ssh/id_ed25519.pub

# Install GitHub CLI
sudo dnf install -y gh
gh auth login
```

---

## 10. Language Runtimes <a name="10-languages"></a>

### Node.js via NVM

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
source ~/.zshrc

nvm install --lts
nvm use --lts
nvm alias default lts/*

npm install -g pnpm yarn typescript tsx nodemon
```

### Python via pyenv

```bash
# Build dependencies
sudo dnf install -y gcc make patch zlib-devel bzip2 bzip2-devel readline-devel \
  sqlite sqlite-devel openssl-devel tk-devel libffi-devel xz-devel

curl https://pyenv.run | bash
source ~/.zshrc

pyenv install 3.12.3
pyenv global 3.12.3

pip install --upgrade pip pipx poetry virtualenv
```

### Go

```bash
GO_VERSION="1.22.5"
wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
rm go${GO_VERSION}.linux-amd64.tar.gz

go version
```

### Rust

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
rustc --version
```

---

## 11. AWS CLI + Terraform + IaC Tools <a name="11-cloud"></a>

### AWS CLI v2

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

aws --version
aws configure     # Access Key, Secret, Region (or use SSO)
# aws configure sso   (recommended for enterprise)
```

### AWS Supporting Tools

```bash
# AWS Vault — secure credential storage
curl -L https://github.com/99designs/aws-vault/releases/latest/download/aws-vault-linux-amd64 \
  -o aws-vault
chmod +x aws-vault
sudo mv aws-vault /usr/local/bin/

# AWS SAM CLI
pipx install aws-sam-cli

# AWS Copilot (optional)
curl -Lo copilot https://github.com/aws/copilot-cli/releases/latest/download/copilot-linux
chmod +x copilot && sudo mv copilot /usr/local/bin/copilot
```

### Terraform via tfenv

```bash
git clone https://github.com/tfutils/tfenv.git ~/.tfenv
source ~/.zshrc

tfenv install latest
tfenv use latest
terraform -version
```

### Terraform Ecosystem

```bash
# Terragrunt
curl -L https://github.com/gruntwork-io/terragrunt/releases/latest/download/terragrunt_linux_amd64 \
  -o terragrunt
chmod +x terragrunt && sudo mv terragrunt /usr/local/bin/

# TFLint
curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash

# tfsec (security scanner)
curl -s https://raw.githubusercontent.com/aquasecurity/tfsec/master/scripts/install_linux.sh | bash

# Infracost
curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh

# Checkov (policy-as-code)
pipx install checkov
```

---

## 12. Docker & Kubernetes <a name="12-containers"></a>

### Native Docker (no Docker Desktop needed)

```bash
sudo dnf -y install dnf-plugins-core
sudo dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

sudo dnf install -y docker-ce docker-ce-cli containerd.io \
  docker-compose-plugin docker-buildx-plugin

sudo systemctl enable --now docker
sudo usermod -aG docker $USER
newgrp docker

docker run hello-world
```

### Kubernetes Toolkit

```bash
# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# minikube
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
rm minikube-linux-amd64

# k9s — beautiful K8s TUI
curl -sS https://webinstall.dev/k9s | bash

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# kind (Kubernetes in Docker)
go install sigs.k8s.io/kind@latest

# kubectx + kubens
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens  /usr/local/bin/kubens
```

---

# 💻 PHASE 5 — IDEs

## 13. VS Code with WSL Integration <a name="13-vscode"></a>

### Step 13.1 — Install VS Code on Windows

Download: https://code.visualstudio.com/

During install, **check "Add to PATH"** ✅

### Step 13.2 — Install WSL Extension

On Windows VS Code: Extensions → search **"WSL"** by Microsoft → Install

### Step 13.3 — Open Projects from WSL

```bash
cd ~/projects
code .   # Opens VS Code on Windows, but runs inside WSL
```

### Step 13.4 — Essential Extensions (installed from WSL side)

```bash
code --install-extension ms-vscode-remote.remote-wsl
code --install-extension ms-azuretools.vscode-docker
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
code --install-extension hashicorp.terraform
code --install-extension amazonwebservices.aws-toolkit-vscode
code --install-extension ms-python.python
code --install-extension ms-python.vscode-pylance
code --install-extension golang.go
code --install-extension rust-lang.rust-analyzer
code --install-extension dbaeumer.vscode-eslint
code --install-extension esbenp.prettier-vscode
code --install-extension eamodio.gitlens
code --install-extension github.copilot
code --install-extension github.copilot-chat
code --install-extension PKief.material-icon-theme
code --install-extension zhuangtongfa.material-theme
```

---

## 14. Zed IDE via WSLg <a name="14-zed"></a>

Zed runs **inside WSL** and displays through WSLg as a native Windows window!

```bash
# GUI dependencies
sudo dnf install -y mesa-libGL mesa-libEGL vulkan-loader fontconfig \
  libxkbcommon libxkbcommon-x11 wayland-devel

# Install Zed
curl -f https://zed.dev/install.sh | sh

# Launch (opens as a native Windows window via WSLg)
zed
```

### Test Other GUI Apps

```bash
sudo dnf install -y firefox gedit
firefox &      # 🎉 Native Windows window!
```

---

## 15. Productivity CLI Tools <a name="15-productivity"></a>

```bash
# Modern CLI replacements
sudo dnf install -y \
  bat \
  eza \
  fd-find \
  ripgrep \
  fzf \
  zoxide \
  tmux \
  neovim \
  httpie \
  ncdu \
  duf \
  tldr

# Lazygit
sudo dnf copr enable atim/lazygit -y
sudo dnf install -y lazygit

# Lazydocker
curl https://raw.githubusercontent.com/jesseduffield/lazydocker/master/scripts/install_update_linux.sh | bash

# direnv
sudo dnf install -y direnv

# Ensure FZF shell integrations
/usr/share/fzf/shell/key-bindings.zsh 2>/dev/null > ~/.fzf.zsh || true

source ~/.zshrc
```

---

# 🔐 PHASE 6 — BACKUP & DISASTER RECOVERY

## 16. Dotfiles Management <a name="16-dotfiles"></a>

### Bare Repo Strategy (Clean, no symlinks)

```bash
git init --bare $HOME/.dotfiles
echo "alias dot='git --git-dir=\$HOME/.dotfiles/ --work-tree=\$HOME'" >> ~/.zshrc
source ~/.zshrc

dot config --local status.showUntrackedFiles no

# Track your configs
dot add .zshrc .p10k.zsh .gitconfig
dot commit -m "initial dotfiles"

# Push to private GitHub repo
dot remote add origin git@github.com:youruser/dotfiles.git
dot push -u origin main
```

### Restore on a Fresh Install

```bash
git clone --bare git@github.com:youruser/dotfiles.git $HOME/.dotfiles
alias dot='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dot checkout
dot config --local status.showUntrackedFiles no
```

---

## 17. Automated Backup System <a name="17-backup"></a>

### Step 17.1 — Backup Script

Save as `D:\WSL\Scripts\backup-wsl.ps1`:

```powershell
param(
    [string]$DistroName = "FedoraDev",
    [string]$BackupDir  = "D:\WSL\Backups",
    [int]$KeepLast      = 5
)

$ErrorActionPreference = "Stop"
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"
$backupFile = Join-Path $BackupDir "$DistroName-$timestamp.tar"

Write-Host "🔄 Shutting down WSL..." -ForegroundColor Cyan
wsl --shutdown
Start-Sleep -Seconds 3

Write-Host "📦 Exporting $DistroName → $backupFile" -ForegroundColor Cyan
wsl --export $DistroName $backupFile

if (Test-Path $backupFile) {
    $sizeMB = [math]::Round((Get-Item $backupFile).Length / 1MB, 2)
    Write-Host "✅ Backup complete: $sizeMB MB" -ForegroundColor Green
} else {
    Write-Host "❌ Backup failed!" -ForegroundColor Red
    exit 1
}

Write-Host "🧹 Rotating old backups (keep last $KeepLast)..." -ForegroundColor Cyan
Get-ChildItem $BackupDir -Filter "$DistroName-*.tar" |
    Sort-Object LastWriteTime -Descending |
    Select-Object -Skip $KeepLast |
    ForEach-Object {
        Write-Host "  🗑  Removing $($_.Name)" -ForegroundColor Yellow
        Remove-Item $_.FullName -Force
    }

Write-Host "`n🎉 Done!" -ForegroundColor Green
```

Test manually:
```powershell
powershell -ExecutionPolicy Bypass -File D:\WSL\Scripts\backup-wsl.ps1
```

### Step 17.2 — Schedule Weekly Backups (PowerShell as Admin)

```powershell
$action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File D:\WSL\Scripts\backup-wsl.ps1"

$trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At 2am

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries -StartWhenAvailable

Register-ScheduledTask -TaskName "WSL Weekly Backup" `
    -Action $action -Trigger $trigger -Settings $settings `
    -Description "Exports WSL distro to D:\WSL\Backups every Sunday 2 AM"
```

### Step 17.3 — Restore Script

Save as `D:\WSL\Scripts\restore-wsl.ps1`:

```powershell
param(
    [Parameter(Mandatory=$true)][string]$BackupFile,
    [string]$NewName = "FedoraDev",
    [string]$InstallPath = "D:\WSL\Distros\FedoraDev"
)

Write-Host "⚠️  This will UNREGISTER existing '$NewName' distro!" -ForegroundColor Yellow
$confirm = Read-Host "Type YES to continue"
if ($confirm -ne "YES") { exit }

wsl --shutdown
wsl --unregister $NewName 2>$null
Remove-Item $InstallPath -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null

Write-Host "🔄 Restoring from $BackupFile..." -ForegroundColor Cyan
wsl --import $NewName $InstallPath $BackupFile --version 2

Write-Host "✅ Restored! Current distros:" -ForegroundColor Green
wsl --list --verbose
```

### Step 17.4 — VHDX Compaction (Monthly Maintenance)

```bash
# Inside WSL — clean up before compacting
sudo dnf clean all
sudo journalctl --vacuum-time=7d
docker system prune -af 2>/dev/null || true
```

```powershell
# From PowerShell
wsl --shutdown

$diskpart = @"
select vdisk file="D:\WSL\Distros\FedoraDev\ext4.vhdx"
attach vdisk readonly
compact vdisk
detach vdisk
exit
"@
$diskpart | diskpart
```

---

## 18. Disaster Recovery Playbook <a name="18-recovery"></a>

### 🚨 Scenario: Windows Crashes / Laptop Dies

If you've been backing up to D:, recovery takes **5–10 minutes**:

```powershell
# 1. Fresh Windows → install WSL
wsl --install --no-distribution
wsl --update
wsl --set-default-version 2

# 2. Restore from latest backup on D:
$latest = Get-ChildItem D:\WSL\Backups -Filter "FedoraDev-*.tar" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1

wsl --import FedoraDev D:\WSL\Distros\FedoraDev $latest.FullName --version 2
wsl --set-default FedoraDev

# 3. Install fonts (MesloLGS NF) on Windows
# 4. Install Windows Terminal + VS Code
# 5. Launch & work 🎉
wsl
```

### 🚨 Scenario: Only D: Drive Survives

Same as above — your vhdx AND backups are both on D:. You're safe.

### 🚨 Scenario: D: Drive Also Dies

Your **dotfiles on GitHub** are the ultimate fallback:
1. Fresh WSL install
2. Run bootstrap script (see section 19)
3. `dot checkout` → all configs restored
4. Re-authenticate tools (AWS, GitHub)

---

# 🎯 PHASE 7 — WORKFLOW

## 19. End-to-End Daily Workflow <a name="19-workflow"></a>

```
┌────────────────────────────────────────────────────────────────────┐
│                     🌅 START YOUR DAY                              │
└────────────────────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌────────────────────────────────────────────────────────┐
    │  Open Windows Terminal → 🐧 Fedora Dev (default)       │
    │  Acrylic bg · MesloLGS NF · Powerlevel10k prompt 🔥    │
    └────────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌────────────────────────────────────────────────────────┐
    │  z my-app         (zoxide jumps to project)            │
    │  direnv loads .envrc automatically                     │
    └────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┼────────────────┐
              ▼               ▼                ▼
      ┌─────────────┐  ┌─────────────┐  ┌──────────────┐
      │   code .    │  │    zed .    │  │   lazygit    │
      │  (VS Code   │  │  (GUI via   │  │  (Git TUI)   │
      │   Remote)   │  │    WSLg)    │  │              │
      └─────────────┘  └─────────────┘  └──────────────┘
                              │
                              ▼
    ┌────────────────────────────────────────────────────────┐
    │  🏗 INFRASTRUCTURE:                                     │
    │    aws sso login                                       │
    │    tf init && tf plan && tf apply                      │
    │    tfsec . && infracost breakdown --path=.             │
    └────────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌────────────────────────────────────────────────────────┐
    │  🐳 CONTAINERS & K8s:                                   │
    │    dc up -d         (docker compose)                   │
    │    k9s              (beautiful K8s dashboard)          │
    │    lazydocker       (Docker TUI)                       │
    └────────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌────────────────────────────────────────────────────────┐
    │  🧪 CODE · TEST · COMMIT                                │
    │    Write code in Zed/VS Code                           │
    │    Run tests                                           │
    │    lg → stage → commit → push                          │
    └────────────────────────────────────────────────────────┘
                              │
                              ▼
    ┌────────────────────────────────────────────────────────┐
    │  🌙 END OF DAY:                                         │
    │    dot add -u && dot commit -m "tweaks" && dot push    │
    │                                                        │
    │  📅 Sunday 2 AM (automatic):                            │
    │    Scheduled Task → wsl --export → D:\WSL\Backups      │
    └────────────────────────────────────────────────────────┘
```

### Bootstrap Script (for Fresh Installs)

Save the entire Fedora setup (sections 5–15) as `bootstrap.sh` in your dotfiles repo. Then:

```bash
# On a fresh Fedora WSL
curl -fsSL https://raw.githubusercontent.com/youruser/dotfiles/main/bootstrap.sh | bash
```

**→ 30 minutes from zero to fully restored environment. Forever.**

---

## 20. Quick Reference & Cheatsheet <a name="20-cheatsheet"></a>

### 🧰 WSL Management (PowerShell)

```powershell
wsl --list --verbose                 # Show all distros
wsl -d FedoraDev                     # Launch specific distro
wsl --shutdown                       # Stop all WSL
wsl --set-default FedoraDev          # Set default
wsl --export FedoraDev D:\backup.tar # Manual backup
wsl --import Name Path Tar --version 2  # Restore
wsl --unregister FedoraDev           # ⚠️ DELETE distro
wsl --update                         # Update WSL kernel
```

### 🔍 Verify Environment

```bash
cat > ~/verify.sh << 'EOF'
#!/usr/bin/env zsh
echo "🔍 Environment Verification"
echo "=========================="
echo "Shell:        $SHELL"
echo "Zsh:          $(zsh --version)"
echo "Git:          $(git --version)"
echo "Node:         $(node -v 2>/dev/null)"
echo "Python:       $(python --version 2>/dev/null)"
echo "Go:           $(go version 2>/dev/null)"
echo "Rust:         $(rustc --version 2>/dev/null)"
echo "Docker:       $(docker --version 2>/dev/null)"
echo "kubectl:      $(kubectl version --client 2>/dev/null | head -1)"
echo "Terraform:    $(terraform -version | head -1)"
echo "AWS CLI:      $(aws --version 2>/dev/null)"
echo "Zed:          $(which zed)"
echo "VS Code:      $(which code)"
echo "WSLg DISPLAY: $DISPLAY"
echo "Wayland:      $WAYLAND_DISPLAY"
echo "=========================="
echo "✅ All systems go!"
EOF
chmod +x ~/verify.sh && ~/verify.sh
```

### 🎯 Critical Best Practices

| Rule | Why |
|------|-----|
| 📁 Store projects in `~/projects`, NOT `/mnt/d/` | 10× faster ext4 I/O |
| 💾 All VHDX files on D:\WSL\Distros\ | Survive C: failures |
| 📦 Weekly automated exports to D:\WSL\Backups | 5-min disaster recovery |
| ☁️ Dotfiles pushed to private GitHub | Ultimate config backup |
| 🗓 Monthly vhdx compaction | Reclaim GBs of space |
| 🔒 Enable BitLocker on D: | Encrypt your work at rest |
| 🚫 Never edit vhdx while WSL runs | Prevents corruption |
| 📸 Export before major changes | Instant rollback |

### 📞 Emergency Commands

```powershell
# 🆘 WSL hanging?
wsl --shutdown

# 🆘 Need to reset without losing data?
wsl --export FedoraDev D:\WSL\Backups\emergency.tar
wsl --unregister FedoraDev
wsl --import FedoraDev D:\WSL\Distros\FedoraDev D:\WSL\Backups\emergency.tar --version 2

# 🆘 Check what's on D:
Get-ChildItem -Recurse D:\WSL -Filter "*.vhdx" | Select FullName, Length
Get-ChildItem -Recurse D:\WSL\Backups | Select Name, LastWriteTime
```

---

## 🎉 You've Built a Bulletproof Dev Environment

Here's what you now have:

✅ **Fedora on WSL2** with systemd, GPU acceleration, and WSLg  
✅ **Everything on D: drive** — survives C: failures  
✅ **Stunning terminal** — Powerlevel10k, Nerd Fonts, acrylic Windows Terminal  
✅ **Full toolchain** — AWS, Terraform, Docker, K8s, Node, Python, Go, Rust  
✅ **Two IDEs** — VS Code Remote + Zed via WSLg  
✅ **Automated weekly backups** with rotation  
✅ **Dotfiles in Git** — ultimate config safety net  
✅ **5-minute disaster recovery** — from dead OS to working dev env  

---

## 🚀 What's Next?

I can help you build:
1. 📜 **Complete `bootstrap.sh`** — single script automating sections 5–15
2. 📝 **Ready-made `.zshrc` and `.p10k.zsh`** — copy-paste configs
3. 🏗 **Sample Terraform + AWS starter project** — with CI/CD
4. 🐳 **Dev Container templates** — for reproducible per-project envs
5. 🎨 **Custom Windows Terminal themes** — matching your aesthetic

Just tell me which one you want first! 💪
