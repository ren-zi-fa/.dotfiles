
#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# VPS Development Environment Setup
# Supported: Debian / Ubuntu
# ==========================================

if [[ $EUID -eq 0 ]]; then
    echo "Jalankan script sebagai user biasa, bukan root."
    exit 1
fi

if ! command -v apt-get >/dev/null 2>&1; then
    echo "Error: Script ini membutuhkan APT (Debian/Ubuntu)."
    exit 1
fi

echo "==> Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y

echo "==> Installing essential utilities..."
sudo apt-get install -y \
    ca-certificates \
    curl \
    wget \
    fzf \
    fd-find \
    gnupg \
    unzip \
    zip \
    tar \
    xz-utils \
    build-essential \
    pkg-config \
    tmux \
    stow \
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

echo "==> Installing eza if available..."
if apt-cache show eza >/dev/null 2>&1; then
    sudo apt-get install -y eza
else
    echo "Package eza tidak tersedia di repository APT saat ini."
fi

echo "==> Installing Neovim (tarball)..."
if command -v nvim >/dev/null 2>&1; then
    echo "Neovim sudah tersedia: $(nvim --version | head -n 1)"
else
    NVIM_TARBALL="nvim-linux-x86_64.tar.gz"
    NVIM_URL="https://github.com/neovim/neovim/releases/latest/download/${NVIM_TARBALL}"
    NVIM_DEST="$HOME/.local"

    mkdir -p "$NVIM_DEST"
    TMP_TARBALL="$(mktemp --suffix=.tar.gz)"
    trap 'rm -f "$TMP_TARBALL"' EXIT

    curl -fsSL "$NVIM_URL" -o "$TMP_TARBALL"
    tar -xzf "$TMP_TARBALL" -C "$NVIM_DEST"
    rm -f "$TMP_TARBALL"
    trap - EXIT

    if [[ -d "$NVIM_DEST/nvim-linux-x86_64/bin" ]]; then
        echo "Neovim terinstal di $NVIM_DEST/nvim-linux-x86_64"
    else
        echo "Error: ekstraksi Neovim gagal."
        exit 1
    fi
fi

echo "==> Configuring pipx..."
pipx ensurepath

echo "==> Installing tldr..."
if command -v tldr >/dev/null 2>&1; then
    echo "tldr sudah tersedia."
elif command -v pipx >/dev/null 2>&1; then
    pipx install tldr
fi

echo "==> Installing Composer..."
if ! command -v composer >/dev/null 2>&1; then
    EXPECTED_CHECKSUM="$(curl -fsSL https://composer.github.io/installer.sig)"
    INSTALLER="$(mktemp)"
    trap 'rm -f "$INSTALLER"' EXIT

    curl -fsSL https://getcomposer.org/installer -o "$INSTALLER"

    ACTUAL_CHECKSUM="$(php -r \
        "echo hash_file('sha384', '$INSTALLER');")"

    if [[ "$EXPECTED_CHECKSUM" != "$ACTUAL_CHECKSUM" ]]; then
        echo "Error: Composer installer checksum tidak cocok."
        exit 1
    fi

    sudo php "$INSTALLER" --install-dir=/usr/local/bin --filename=composer
    rm -f "$INSTALLER"
    trap - EXIT
fi

echo
echo "==> Installed versions:"
git --version
tmux -V
python3 --version
pipx --version
php --version
composer --version

if command -v eza >/dev/null 2>&1; then
    eza --version | head -n 1
fi

echo
echo "Setup dasar selesai."
echo "Node.js LTS belum diinstal; lihat langkah berikutnya."

DOTFILES="$HOME/.dotfiles"

if ! command -v stow >/dev/null 2>&1; then
    echo "GNU Stow belum terinstal."
    exit 1
fi

cd "$DOTFILES"

echo "==> Menghubungkan konfigurasi dotfiles..."

stow --target="$HOME" tmux zsh nvim

echo "==> Setup dotfiles selesai."