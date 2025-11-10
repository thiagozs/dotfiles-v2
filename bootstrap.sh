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

# Limpa a tela e mostra um cabeçalho bonitinho
clear
gum style --foreground 212 -- "🚀 Bootstrap de ambiente - ThiagoZS"
gum style --foreground 99 -- "------------------------------------"

# Usa mapfile para preservar opções com espaços quando o usuário seleciona várias
run_all=false
if [[ ${DOTFILES_INSTALL_ALL:-0} -eq 1 ]]; then
  run_all=true
else
  gum style --foreground 244 "Use ↑ ↓ para navegar, Espaço para selecionar/deselecionar e Enter para confirmar."
  mapfile -t CHOICES < <(gum choose --no-limit \
    --selected "Instalar Utils do Sistema" \
    --selected "Instalar Utils do Shell" \
    --selected "Instalar Dev Tools" \
    --selected "Instalar tudo" \
    "Instalar Utils do Sistema" \
    "Instalar Utils do Shell" \
    "Instalar Dev Tools" \
    "Instalar tudo")

  for choice in "${CHOICES[@]}"; do
    if [[ "$choice" == "Instalar tudo" ]]; then
      run_all=true
      break
    fi
  done
fi

if [[ "$run_all" == true ]]; then
  DOTFILES_INSTALL_ALL=1 bash ./install_system_utils.sh
  DOTFILES_INSTALL_ALL=1 bash ./install_shell_utils.sh
  DOTFILES_INSTALL_ALL=1 bash ./install_dev_tools.sh
else
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
    esac
  done
fi

gum style --foreground 212 "✅ Bootstrap concluído! Reinicie o terminal."
