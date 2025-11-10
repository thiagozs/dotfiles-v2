#!/usr/bin/env bash
set -euo pipefail

# Utilitários de sistema (Docker, apps desktop, brew etc.)
gum style --bold --foreground 99 "💻 Utils do Sistema"

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

apt_update() {
  wait_for_apt_lock
  sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
}

apt_install() {
  wait_for_apt_lock
  sudo DEBIAN_FRONTEND=noninteractive apt-get install -y "$@"
}
export -f wait_for_apt_lock apt_update apt_install

if [[ ${DOTFILES_INSTALL_ALL:-0} -eq 1 ]]; then
  SYS_UTILS=(
    "docker cli"
    "docker compose"
    "vscode"
    "slack"
    "discord"
    "brew"
  )
else
  # mapfile preserva itens multi-palavra ao coletar as escolhas do usuário
  gum style --foreground 244 "Use ↑ ↓ para navegar, Espaço para selecionar/deselecionar e Enter para confirmar."
  mapfile -t SYS_UTILS < <(gum choose --no-limit \
    --selected "docker cli" \
    --selected "docker compose" \
    --selected "vscode" \
    --selected "slack" \
    --selected "discord" \
    --selected "brew" \
    "docker cli" \
    "docker compose" \
    "vscode" \
    "slack" \
    "discord" \
    "brew")
fi

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
        apt_update
        apt_install docker-compose-plugin
      '
      ;;
    "vscode")
      gum spin --spinner line --title "Baixando e instalando VSCode..." -- bash -c '
        URL=$(curl -s "https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64" -w "%{url_effective}" -o /dev/null)
        wget -O vscode.deb "$URL"
        apt_update
        apt_install ./vscode.deb
        rm -f vscode.deb
      '
      ;;
    "slack")
      gum spin --spinner line --title "Configurando repositório do Slack..." -- bash -c '
        set -euo pipefail
        KEYRING="/usr/share/keyrings/slack-archive-keyring.gpg"
        SOURCES="/etc/apt/sources.list.d/slack.list"
        curl -fsSL https://packagecloud.io/slacktechnologies/slack/gpgkey | sudo gpg --dearmor -o "$KEYRING"
        echo "deb [arch=amd64 signed-by=$KEYRING] https://packagecloud.io/slacktechnologies/slack/debian/ jessie main" | sudo tee "$SOURCES" >/dev/null
        apt_update
        apt_install slack-desktop
      '
      ;;
    "discord")
      gum spin --spinner line --title "Baixando e instalando Discord..." -- bash -c '
        URL=$(curl -s -L -o /dev/null -w "%{url_effective}" "https://discord.com/api/download?platform=linux&format=deb")
        wget -O discord.deb "$URL"
        apt_update
        apt_install ./discord.deb
        rm -f discord.deb
      '
      ;;
    "brew")
      gum spin --spinner line --title "Instalando Homebrew..." -- bash -c '
        NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        BREW_PREFIX="${HOME}/.linuxbrew"
        if [ -d "$BREW_PREFIX" ]; then
          SHELL_ENV="eval \"\$(${BREW_PREFIX}/bin/brew shellenv)\""
          if ! grep -Fxq "$SHELL_ENV" ~/.bashrc 2>/dev/null; then
            echo "$SHELL_ENV" >> ~/.bashrc
          fi
          if ! grep -Fxq "$SHELL_ENV" ~/.zshrc 2>/dev/null; then
            echo "$SHELL_ENV" >> ~/.zshrc
          fi
        fi
      '
      ;;
  esac
done

gum style --foreground 35 "✅ Utils do sistema instalados!"
