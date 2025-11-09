#!/usr/bin/env bash
set -euo pipefail

gum style --bold --foreground 99 "🧠 Utils do Shell"

mapfile -t SHELL_UTILS < <(gum choose --no-limit \
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

for util in "${SHELL_UTILS[@]}"; do
  case $util in
    "zsh")
      sudo apt install -y zsh
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
      sudo apt install -y direnv
      ;;
    "duf")
      sudo apt install -y duf
      ;;
    "exa")
      if ! sudo apt install -y exa; then
        sudo apt install -y eza
      fi
      ;;
    "bat")
      sudo apt install -y bat
      ;;
    "fzf")
      sudo apt install -y fzf
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
      sudo apt install -y fonts-font-awesome
      ;;
    "font firecoda")
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
      ;;
    "ripgrep")
      sudo apt install -y ripgrep
      ;;
    "tldr")
      sudo apt install -y tldr
      ;;
    "zoxide")
      curl -sS https://webinstall.dev/zoxide | bash
      ;;
  esac
done

gum style --foreground 35 "✅ Utils do shell instalados!"
