# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH=$PATH:$HOME/go/bin
export PATH=$PATH:$HOME/.local/go/bin
# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# export EDITOR='vim'

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes.
# For a full list of active aliases, run `alias`.

alias cdc="cd"
alias fd="fdfind"
alias ls="eza --icons=always --color=always "
alias ll="eza --icons=always --color=always -la"
alias tree="eza --icons --tree"
alias bat="batcat"

ff() {
  local dir
  dir=$(fd --type d --hidden --exclude .git | fzf --preview 'ls -a --color=always {}') || return
  cd "$dir" || return
}

f() {
  cd ~ || return
  local dir
  dir=$(fd --type d --hidden --exclude .git | fzf --preview 'ls -a --color=always {}') || return
  cd "$dir" || return
}

alias cls="clear"
alias econf='file="$(fd --type f --hidden --exclude .git | fzf --height 50% --reverse --border)" && [[ -n "$file" ]] && vim "$file"'

# Fungsi navigasi folder dan file menggunakan fzf.
fzf_cd_file() {
  # Gunakan find untuk menampilkan file dan folder di direktori saat ini.
  local selected
  selected=$(find . -maxdepth 1 | sed 's|^\./||' | fzf --height 40% --border --ansi \
    --preview '[[ -d {} ]] && ls -l {} || cat {}' \
    --bind 'ctrl-d:preview-page-down,ctrl-u:preview-page-up')

  if [[ -n "$selected" ]]; then
    if [[ -d "$selected" ]]; then
      cd "$selected" || return
      echo "Masuk ke folder: $selected"
    else
      echo "Isi file $selected:"
      cat "$selected"
    fi
  fi
}

# Pintasan untuk menjalankan fzf_cd_file.
alias gohome='cd ~/'
alias fz='fzf_cd_file'
alias py='python3'

perm() {
  for f in "$@"; do
    stat -c "%a %n" "$f"
  done
}

dcl() {
  docker compose -f docker-compose.local.yml --env-file .env.local "$@"
}

dcdb() {
  docker compose -f docker-compose.db.yml --env-file .env.dev "$@"
}

dcp() {
  docker compose -f docker-compose.production.yml --env-file .env.prod "$@"
}

alias opencode-delete-session="opencode session list --format json \
  | jq -r '.[].id' \
  | xargs -r -n1 opencode session delete"

alias docker-db='docker compose -f docker-compose.db.yml --env-file .env.dev'
alias glog='git log --graph --oneline --all --decorate -50'

export ZED_ALLOW_EMULATED_GPU=1

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
# Flutter SDK
export PATH="$HOME/.flutter-sdk/bin:$PATH"
# nvm (Node Version Manager)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$PATH:$HOME/.config/composer/vendor/bin"

export PATH="$PATH:$HOME/Antigravity"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# Created by `pipx` on 2026-09-20 15:32:22
export PATH="$PATH:$HOME/.local/bin"

# strix
export PATH=$HOME/.strix/bin:$PATH

# Strix LLM via OpenRouter (free responsif 2026-09-28; Qwen/Gemma free sedang 429)
export STRIX_LLM="openrouter/nvidia/nemotron-3-super-120b-a12b:free"
# Isi token OpenRouter kamu di bawah (jangan commit). Alternatif: export manual per sesi.
# export LLM_API_KEY="sk-or-v1-PASTE_TOKEN_KAMU_DI_SINI"
# export OPENROUTER_API_KEY="$LLM_API_KEY"
