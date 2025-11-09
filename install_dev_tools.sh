#!/usr/bin/env bash
set -euo pipefail

gum style --bold --foreground 99 "🧑‍💻 Dev Tools Setup"

DEV_TOOLS=$(gum choose --no-limit \
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

for tool in $DEV_TOOLS; do
  case $tool in
    "git")
      sudo apt install -y git
      git config --global init.defaultBranch main
      git config --global pull.rebase false
      ;;
    "make")
      sudo apt install -y make
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
      sudo apt install -y python3 python3-pip python3-venv
      ;;
    "postgresql + client")
      gum spin --spinner line --title "Instalando PostgreSQL e cliente..." -- bash -c '
        sudo apt install -y postgresql postgresql-client libpq-dev
        sudo systemctl enable postgresql
      '
      ;;
    "sqlite3")
      sudo apt install -y sqlite3
      ;;
    "jq")
      sudo apt install -y jq
      ;;
    "httpie")
      sudo apt install -y httpie
      ;;
    "gh (GitHub CLI)")
      gum spin --spinner line --title "Instalando GitHub CLI..." -- bash -c '
        type -p curl >/dev/null || sudo apt install curl -y
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update && sudo apt install gh -y
      '
      ;;
    "build essentials")
      sudo apt install -y build-essential pkg-config libssl-dev
      ;;
    "docker buildx")
      sudo apt install -y docker-buildx-plugin
      ;;
    "redis-cli")
      sudo apt install -y redis-tools
      ;;
  esac
done

gum style --foreground 35 "✅ Dev Tools instaladas com sucesso!"
