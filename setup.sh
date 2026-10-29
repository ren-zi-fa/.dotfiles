#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# VPS Development Setup
# Debian / Ubuntu
# ==========================================

# Resolve target user.
TARGET_USER="${SUDO_USER:-$(id -un)}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"

if [[ -z "$TARGET_HOME" || ! -d "$TARGET_HOME" ]]; then
    echo "Error: Home directory user $TARGET_USER tidak ditemukan."
    exit 1
fi

if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    command -v sudo >/dev/null 2>&1 || {
        echo "Error: sudo tidak tersedia."
        exit 1
    }
    SUDO="sudo"
fi

run_user() {
    if [[ "$TARGET_USER" == "root" ]]; then
        "$@"
    elif [[ $EUID -eq 0 ]]; then
        runuser -u "$TARGET_USER" -- "$@"
    else
        sudo -u "$TARGET_USER" -H "$@"
    fi
}

DOTFILES="$TARGET_HOME/.dotfiles"

if ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: APT hanya didukung pada Debian/Ubuntu."
    exit 1
fi

echo "==> Target user: $TARGET_USER"
echo "==> Home: $TARGET_HOME"

# ==========================================
# 1. System packages
# ==========================================

echo "==> Updating system..."

$SUDO apt-get update
$SUDO apt-get upgrade -y

$SUDO apt-get install -y \
    ca-certificates \
    curl \
    wget \
    git \
    gnupg \
    unzip \
    zip \
    tar \
    xz-utils \
    build-essential \
    pkg-config \
    tmux \
    stow \
    zsh \
    fzf \
    fd-find \
    bat \
    htop \
    bmon \
    python3 \
    python3-pip \
    python3-venv \
    pipx \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    php-bcmath \
    php-sqlite3 \
    php-mysql \
    php-intl \
    php-gd \
    php-fpm \
    php-pgsql

# ==========================================
# 2. Install Docker
# ==========================================

echo "==> Installing Docker..."

if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed."
else
    $SUDO install -d -m 0755 /etc/apt/keyrings

    DOCKER_DISTRO="$(. /etc/os-release && echo "$ID")"
    case "$DOCKER_DISTRO" in
        debian) DOCKER_REPO="debian" ;;
        *)      DOCKER_REPO="ubuntu" ;;
    esac

    CODENAME="$(
        set +u
        . /etc/os-release
        echo "${VERSION_CODENAME:-$UBUNTU_CODENAME}"
    )"

    curl -fsSL "https://download.docker.com/linux/$DOCKER_REPO/gpg" \
        | $SUDO gpg --dearmor --yes \
            -o /etc/apt/keyrings/docker.gpg

    $SUDO chmod 644 /etc/apt/keyrings/docker.gpg

    echo "deb [signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$DOCKER_REPO $CODENAME stable" \
        | $SUDO tee /etc/apt/sources.list.d/docker.list >/dev/null

    $SUDO apt-get update
    $SUDO apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin
fi

if [[ "$TARGET_USER" != "root" ]]; then
    $SUDO usermod -aG docker "$TARGET_USER"
    echo "==> User $TARGET_USER ditambahkan ke grup 'docker'."
    echo "    Logout/login ulang (atau jalankan 'newgrp docker') agar perubahan aktif."
fi

# ==========================================
# 3. Install eza repository
# ==========================================

echo "==> Installing eza..."

$SUDO install -d -m 0755 /etc/apt/keyrings

curl -fsSL \
    https://raw.githubusercontent.com/eza-community/eza/main/deb.asc \
    | $SUDO gpg --dearmor --yes \
        -o /etc/apt/keyrings/gierens.gpg

$SUDO chmod 644 /etc/apt/keyrings/gierens.gpg

echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] https://deb.gierens.de stable main" \
    | $SUDO tee /etc/apt/sources.list.d/gierens.list >/dev/null

$SUDO apt-get update
$SUDO apt-get install -y eza

# ==========================================
# 4. Install Neovim
# ==========================================

echo "==> Installing Neovim..."

NVIM_DIR="$TARGET_HOME/.local/nvim-linux-x86_64"

if [[ ! -x "$NVIM_DIR/bin/nvim" ]]; then
    TMP_FILE="$(mktemp --suffix=.tar.gz)"
    trap 'rm -f "$TMP_FILE"' EXIT

    curl -fsSL \
        https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
        -o "$TMP_FILE"

    run_user mkdir -p "$TARGET_HOME/.local"

    $SUDO tar -xzf "$TMP_FILE" \
        -C "$TARGET_HOME/.local"

    $SUDO chown -R "$TARGET_USER":"$(id -gn "$TARGET_USER")" "$NVIM_DIR"

    rm -f "$TMP_FILE"
    trap - EXIT
fi

# ==========================================
# 5. Install Oh My Zsh
# ==========================================

echo "==> Installing Oh My Zsh..."

OMZ_DIR="$TARGET_HOME/.dotfiles/oh-my-zsh/.oh-my-zsh"

if [[ ! -d "$OMZ_DIR" ]]; then
    run_user mkdir -p "$TARGET_HOME/.dotfiles/oh-my-zsh"
    run_user git clone --depth=1 \
        https://github.com/ohmyzsh/ohmyzsh.git \
        "$OMZ_DIR"
else
    echo "Oh My Zsh already installed."
fi

ZSH_CUSTOM="$OMZ_DIR/custom"

# ==========================================
# 6. Install Powerlevel10k
# ==========================================

echo "==> Installing Powerlevel10k..."

if [[ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]]; then
    run_user git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git \
        "$ZSH_CUSTOM/themes/powerlevel10k"
fi

# ==========================================
# 7. Install Zsh plugins
# ==========================================

echo "==> Installing Zsh plugins..."

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    run_user git clone --depth=1 \
        https://github.com/zsh-users/zsh-autosuggestions.git \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    run_user git clone --depth=1 \
        https://github.com/zsh-users/zsh-syntax-highlighting.git \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# ==========================================
# 8. Install Composer
# ==========================================

echo "==> Installing Composer..."

if ! command -v composer >/dev/null 2>&1; then
    EXPECTED="$(curl -fsSL https://composer.github.io/installer.sig)"
    INSTALLER="$(mktemp)"
    trap 'rm -f "$INSTALLER"' EXIT

    curl -fsSL https://getcomposer.org/installer -o "$INSTALLER"

    ACTUAL="$(
        php -r 'echo hash_file("sha384", $argv[1]);' "$INSTALLER"
    )"

    if [[ "$EXPECTED" != "$ACTUAL" ]]; then
        echo "Error: Composer checksum tidak cocok."
        exit 1
    fi

    $SUDO php "$INSTALLER" \
        --install-dir=/usr/local/bin \
        --filename=composer

    rm -f "$INSTALLER"
    trap - EXIT
fi

# ==========================================
# 9. Install tldr using pipx
# ==========================================

echo "==> Installing tldr..."

if ! command -v tldr >/dev/null 2>&1; then
    run_user pipx install tldr
fi

# ==========================================
# 10. Stow dotfiles
# ==========================================

echo "==> Setting up dotfiles..."

if [[ -d "$DOTFILES" ]]; then
    PACKAGES=()

    for package in tmux zsh nvim oh-my-zsh; do
        if [[ -d "$DOTFILES/$package" ]]; then
            PACKAGES+=("$package")
        fi
    done

    if ((${#PACKAGES[@]})); then
        run_user stow \
            --dir="$DOTFILES" \
            --target="$TARGET_HOME" \
            "${PACKAGES[@]}"
    fi
else
    echo "Dotfiles tidak ditemukan: $DOTFILES"
    echo "Lewati Stow."
fi

# ==========================================
# 11. Set default shell
# ==========================================

echo "==> Setting default shell..."

ZSH_PATH="$(command -v zsh)"

if [[ -n "$ZSH_PATH" ]]; then
    if [[ "$TARGET_USER" == "root" || $EUID -eq 0 ]]; then
        $SUDO chsh -s "$ZSH_PATH" "$TARGET_USER"
    else
        chsh -s "$ZSH_PATH"
    fi
fi

# ==========================================
# 12. Verification
# ==========================================

echo
echo "==> Installed versions"

git --version
tmux -V
zsh --version
eza --version | head -n 1 || true
php --version | head -n 1 || true
composer --version
docker --version || true
docker compose version || true
python3 --version
pipx --version

echo
echo "Setup selesai untuk user: $TARGET_USER"
echo "Jalankan sesi Zsh baru untuk memuat konfigurasi."
echo "Node.js LTS belum diinstal."
