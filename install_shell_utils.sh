#!/usr/bin/env bash
set -euo pipefail

# Ferramentas para terminal/zsh (themes, plugins, CLIs)
gum style --bold --foreground 99 "🧠 Utils do Shell"

append_once() {
  local line="$1"
  local file="$2"
  if [ -f "$file" ] && grep -Fxq "$line" "$file"; then
    return
  fi
  echo "$line" >> "$file"
}

wait_for_apt_lock() {
  local lock_files=(
    /var/lib/dpkg/lock-frontend
    /var/lib/dpkg/lock
    /var/cache/apt/archives/lock
  )
  local printed=false
  while true; do
    local locked=false
    for lock in "${lock_files[@]}"; do
      if sudo fuser "$lock" >/dev/null 2>&1; then
        locked=true
        break
      fi
    done
    if ! $locked; then
      if $printed; then
        echo "🔓 Lock do apt liberado."
      fi
      break
    fi
    if ! $printed; then
      echo "⏳ Aguardando o apt liberar o lock..."
      printed=true
    fi
    sleep 3
  done
}

apt_install() {
  wait_for_apt_lock
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}
export -f wait_for_apt_lock apt_install

if [[ ${DOTFILES_INSTALL_ALL:-0} -eq 1 ]]; then
  SHELL_UTILS=(
    "zsh"
    "oh-my-zsh"
    "spaceship theme"
    "plugins zsh"
    "direnv"
    "duf"
    "exa"
    "bat"
    "fzf"
    "goenv"
    "nodenv"
    "font awesome"
    "font firecoda"
    "font nerd fonts"
    "atuin"
    "ripgrep"
    "tldr"
    "zoxide"
  )
else
  # mapfile evita quebrar opções com espaços quando o usuário seleciona várias
  gum style --foreground 244 "Use ↑ ↓ para navegar, Espaço para selecionar/deselecionar e Enter para confirmar."
  mapfile -t SHELL_UTILS < <(gum choose --no-limit \
    --selected "zsh" \
    --selected "oh-my-zsh" \
    --selected "spaceship theme" \
    --selected "plugins zsh" \
    --selected "direnv" \
    --selected "duf" \
    --selected "exa" \
    --selected "bat" \
    --selected "fzf" \
    --selected "goenv" \
    --selected "nodenv" \
    --selected "font awesome" \
    --selected "font firecoda" \
    --selected "font nerd fonts" \
    --selected "atuin" \
    --selected "ripgrep" \
    --selected "tldr" \
    --selected "zoxide" \
    "zsh" \
    "oh-my-zsh" \
    "spaceship theme" \
    "plugins zsh" \
    "direnv" \
    "duf" \
    "exa" \
    "bat" \
    "fzf" \
    "goenv" \
    "nodenv" \
    "font awesome" \
    "font firecoda" \
    "font nerd fonts" \
    "atuin" \
    "ripgrep" \
    "tldr" \
    "zoxide")
fi

for util in "${SHELL_UTILS[@]}"; do
  case $util in
    "zsh")
      apt_install zsh
      sudo chsh -s "$(which zsh)" "$USER"
      ;;
    "oh-my-zsh")
      if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "[info] Oh My Zsh já está instalado, pulando..."
      else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
      fi
      ;;
    "spaceship theme")
      THEME_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt"
      if [ -d "$THEME_DIR/.git" ]; then
        git -C "$THEME_DIR" pull --ff-only
      else
        rm -rf "$THEME_DIR"
        git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$THEME_DIR" --depth=1
      fi
      ln -sf "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme" "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/spaceship.zsh-theme"
      ;;
    "plugins zsh")
      git clone https://github.com/zsh-users/zsh-autosuggestions "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" || true
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" || true
      ;;
    "direnv")
      apt_install direnv
      ;;
    "duf")
      apt_install duf
      ;;
    "exa")
      if apt_install exa; then
        :
      else
        apt_install eza
        if ! command -v exa >/dev/null 2>&1 && command -v eza >/dev/null 2>&1; then
          sudo ln -sf "$(command -v eza)" /usr/local/bin/exa
        fi
      fi
      ;;
    "bat")
      apt_install bat
      ;;
    "fzf")
      apt_install fzf
      append_once 'source <(fzf --zsh)' ~/.zshrc
      ;;
    "goenv")
      git clone https://github.com/syndbg/goenv.git ~/.goenv
      echo 'export GOENV_ROOT="$HOME/.goenv"' >> ~/.zshrc
      echo 'export PATH="$GOENV_ROOT/bin:$PATH"' >> ~/.zshrc
      echo 'eval "$(goenv init -)"' >> ~/.zshrc
      ;;
    "nodenv")
      git clone https://github.com/nodenv/nodenv.git ~/.nodenv
      echo 'export PATH="$HOME/.nodenv/bin:$PATH"' >> ~/.zshrc
      echo 'eval "$(nodenv init -)"' >> ~/.zshrc
      ;;
    "font awesome")
      apt_install fonts-font-awesome
      ;;
    "font firecoda")
      apt_install fontconfig
      apt_install unzip
      wget -qO /tmp/firacode.zip https://github.com/tonsky/FiraCode/releases/latest/download/Fira_Code_v6.2.zip
      sudo unzip -o /tmp/firacode.zip -d /usr/share/fonts/truetype/firacode/
      sudo fc-cache -f -v
      ;;
    "font nerd fonts")
      brew tap homebrew/cask-fonts || true
      brew install --cask font-hack-nerd-font
      ;;
    "atuin")
      bash <(curl https://raw.githubusercontent.com/ellie/atuin/main/install.sh)
      append_once 'eval "$(atuin init zsh)"' ~/.zshrc
      ;;
    "ripgrep")
      apt_install ripgrep
      ;;
    "tldr")
      apt_install tldr
      ;;
    "zoxide")
      curl -sS https://webinstall.dev/zoxide | bash
      append_once 'eval "$(zoxide init bash)"' ~/.bashrc
      append_once 'eval "$(zoxide init zsh)"' ~/.zshrc
      ;;
  esac
done

gum style --foreground 35 "✅ Utils do shell instalados!"
