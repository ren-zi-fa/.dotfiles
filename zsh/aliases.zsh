# Personal aliases and helper functions.
# Sourced from ~/.zshrc to keep configuration modular.

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
alias econf='file="$(fd --type f --hidden --exclude .git | fzf --height 50% --reverse --border)" && [[ -n "$file" ]] && nvim "$file"'

# Fungsi untuk fzf navigasi folder dan file
fzf_cd_file() {
  # Gunakan fd atau find untuk daftar semua file dan folder
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

# Shortcut untuk menjalankan fzf_cd_file
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
