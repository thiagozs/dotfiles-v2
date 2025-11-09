#!/usr/bin/env bash
set -euo pipefail

gum style --bold --foreground 99 "💻 Utils do Sistema"

mapfile -t SYS_UTILS < <(gum choose --no-limit \
  "docker cli" \
  "docker compose" \
  "vscode" \
  "slack" \
  "discord" \
  "brew")

for util in "${SYS_UTILS[@]}"; do
  case $util in
    "docker cli")
      gum spin --spinner line --title "Instalando Docker CLI..." -- bash -c '
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker $USER
        rm -f get-docker.sh
      '
      ;;
    "docker compose")
      gum spin --spinner line --title "Instalando Docker Compose..." -- bash -c '
        sudo apt install -y docker-compose-plugin
      '
      ;;
    "vscode")
      gum spin --spinner line --title "Baixando e instalando VSCode..." -- bash -c '
        URL=$(curl -s https://code.visualstudio.com/sha/download?build=stable\&os=linux-deb-x64 -w "%{url_effective}" -o /dev/null)
        wget -O vscode.deb "$URL"
        sudo apt install -y ./vscode.deb
        rm -f vscode.deb
      '
      ;;
    "slack")
      gum spin --spinner line --title "Baixando e instalando Slack..." -- bash -c '
        URL=$(curl -s https://slack.com/downloads/instructions/ubuntu | grep -Eo "https://downloads.slack-edge.com/linux_releases/slack-desktop-[0-9.]+-amd64.deb" | head -1)
        wget -O slack.deb "$URL"
        sudo apt install -y ./slack.deb
        rm -f slack.deb
      '
      ;;
    "discord")
      gum spin --spinner line --title "Baixando e instalando Discord..." -- bash -c '
        URL=$(curl -s -L -o /dev/null -w "%{url_effective}" "https://discord.com/api/download?platform=linux&format=deb")
        wget -O discord.deb "$URL"
        sudo apt install -y ./discord.deb
        rm -f discord.deb
      '
      ;;
    "brew")
      gum spin --spinner line --title "Instalando Homebrew..." -- bash -c '
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
        echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.zshrc
      '
      ;;
  esac
done

gum style --foreground 35 "✅ Utils do sistema instalados!"
