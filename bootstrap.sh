#!/usr/bin/env bash
set -euo pipefail

# ============================================================
# 🚀 Bootstrap de ambiente Linux (Ubuntu/Debian)
# Autor: Thiago Zilli
# ============================================================

if ! command -v gum &>/dev/null; then
  echo "🔧 Instalando gum..."
  sudo apt update -y && sudo apt install -y curl wget apt-transport-https
  echo "deb [trusted=yes] https://repo.charm.sh/apt/ * *" | sudo tee /etc/apt/sources.list.d/charm.list >/dev/null
  sudo apt update -y && sudo apt install -y gum
fi

clear
gum style --foreground 212 -- "🚀 Bootstrap de ambiente - ThiagoZS"
gum style --foreground 99 -- "------------------------------------"

mapfile -t CHOICES < <(gum choose --no-limit \
  "Instalar Utils do Sistema" \
  "Instalar Utils do Shell" \
  "Instalar Dev Tools" \
  "Instalar tudo")

for choice in "${CHOICES[@]}"; do
  case "$choice" in
    "Instalar Utils do Sistema")
      bash ./install_system_utils.sh
      ;;
    "Instalar Utils do Shell")
      bash ./install_shell_utils.sh
      ;;
    "Instalar Dev Tools")
      bash ./install_dev_tools.sh
      ;;
    "Instalar tudo")
      bash ./install_system_utils.sh
      bash ./install_shell_utils.sh
      bash ./install_dev_tools.sh
      ;;
  esac
done

gum style --foreground 212 "\n✅ Bootstrap concluído! Reinicie o terminal."
