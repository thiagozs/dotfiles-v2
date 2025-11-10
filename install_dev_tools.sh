#!/usr/bin/env bash
set -euo pipefail

# Ferramentas de desenvolvimento (compiladores, CLIs, runtimes)
gum style --bold --foreground 99 "🧑‍💻 Dev Tools Setup"

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
  DEV_TOOLS=(
    "git"
    "make"
    "golang (via goenv)"
    "nodejs (via nodenv)"
    "python3 + pip"
    "postgresql + client"
    "sqlite3"
    "jq"
    "httpie"
    "gh (GitHub CLI)"
    "build essentials"
    "docker buildx"
    "redis-cli"
  )
else
  # mapfile impede que nomes com espaços se quebrem nas seleções do gum
  gum style --foreground 244 "Use ↑ ↓ para navegar, Espaço para selecionar/deselecionar e Enter para confirmar."
  mapfile -t DEV_TOOLS < <(gum choose --no-limit \
    --selected "git" \
    --selected "make" \
    --selected "golang (via goenv)" \
    --selected "nodejs (via nodenv)" \
    --selected "python3 + pip" \
    --selected "postgresql + client" \
    --selected "sqlite3" \
    --selected "jq" \
    --selected "httpie" \
    --selected "gh (GitHub CLI)" \
    --selected "build essentials" \
    --selected "docker buildx" \
    --selected "redis-cli" \
    "git" \
    "make" \
    "golang (via goenv)" \
    "nodejs (via nodenv)" \
    "python3 + pip" \
    "postgresql + client" \
    "sqlite3" \
    "jq" \
    "httpie" \
    "gh (GitHub CLI)" \
    "build essentials" \
    "docker buildx" \
    "redis-cli")
fi

for tool in "${DEV_TOOLS[@]}"; do
  case $tool in
    "git")
      apt_install git
      git config --global init.defaultBranch main
      git config --global pull.rebase false
      ;;
    "make")
      apt_install make
      ;;
    "golang (via goenv)")
      gum spin --spinner line --title "Instalando e configurando goenv..." -- bash -c '
        if [ ! -d "$HOME/.goenv" ]; then
          git clone https://github.com/syndbg/goenv.git ~/.goenv
        fi

        export GOENV_ROOT="$HOME/.goenv"
        export PATH="$GOENV_ROOT/bin:$PATH"
        eval "$(goenv init -)"

        LATEST=$(git -C "$GOENV_ROOT" ls-remote --tags https://go.googlesource.com/go | grep -Eo "refs/tags/go[0-9]+\.[0-9]+(\.[0-9]+)?" | cut -d/ -f3 | sort -V | tail -1 | sed "s/^go//")
        goenv install -s "$LATEST"
        goenv global "$LATEST"

        for rcfile in ~/.zshrc ~/.bashrc; do
          if [ -f "$rcfile" ]; then
            if ! grep -q "goenv init" "$rcfile"; then
              {
                echo ""
                echo "# Goenv configuration"
                echo "export GOENV_ROOT=\"\$HOME/.goenv\""
                echo "export PATH=\"\$GOENV_ROOT/bin:\$PATH\""
                echo "eval \"\$(goenv init -)\""
              } >> "$rcfile"
              echo "📝 Configuração adicionada ao $rcfile"
            fi
          fi
        done
      '
      ;;
    "nodejs (via nodenv)")
      gum spin --spinner line --title "Instalando e configurando nodenv..." -- bash -c '
        if [ ! -d "$HOME/.nodenv" ]; then
          git clone https://github.com/nodenv/nodenv.git ~/.nodenv
        fi
        mkdir -p ~/.nodenv/plugins
        if [ ! -d "$HOME/.nodenv/plugins/node-build" ]; then
          git clone https://github.com/nodenv/node-build.git ~/.nodenv/plugins/node-build
        fi

        export PATH="$HOME/.nodenv/bin:$PATH"
        eval "$(nodenv init -)"

        LATEST=$(nodenv install -l | grep -E "^[0-9]+\.[0-9]+\.[0-9]+$" | tail -1)
        nodenv install -s "$LATEST"
        nodenv global "$LATEST"

        for rcfile in ~/.zshrc ~/.bashrc; do
          if [ -f "$rcfile" ]; then
            if ! grep -q "nodenv init" "$rcfile"; then
              {
                echo ""
                echo "# Nodenv configuration"
                echo "export PATH=\"\$HOME/.nodenv/bin:\$PATH\""
                echo "eval \"\$(nodenv init -)\""
              } >> "$rcfile"
              echo "📝 Configuração adicionada ao $rcfile"
            fi
          fi
        done
      '
      ;;
    "python3 + pip")
      apt_install python3 python3-pip python3-venv
      ;;
    "postgresql + client")
      gum spin --spinner line --title "Instalando PostgreSQL e cliente..." -- bash -c '
        apt_install postgresql postgresql-client libpq-dev
        sudo systemctl enable postgresql
      '
      ;;
    "sqlite3")
      apt_install sqlite3
      ;;
    "jq")
      apt_install jq
      ;;
    "httpie")
      apt_install httpie
      ;;
    "gh (GitHub CLI)")
      gum spin --spinner line --title "Instalando GitHub CLI..." -- bash -c '
        type -p curl >/dev/null || apt_install curl
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        apt_update && apt_install gh
      '
      ;;
    "build essentials")
      apt_install build-essential pkg-config libssl-dev
      ;;
    "docker buildx")
      apt_install docker-buildx-plugin
      ;;
    "redis-cli")
      apt_install redis-tools
      ;;
  esac
done

gum style --foreground 35 "✅ Dev Tools instaladas com sucesso!"
