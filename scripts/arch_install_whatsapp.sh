#!/bin/bash

# --- 1. Determina o Usuário e Diretório HOME Corretos ---
if [ "$SUDO_USER" ]; then
    USER_NAME="$SUDO_USER"
else
    USER_NAME="$(whoami)"
fi

USER_HOME=$(eval echo "~$USER_NAME") # /home/usuario
APP_NAME="WhatsApp"
APP_DIR="$USER_HOME/.whatsapp_linux"
APP_PATH="$APP_DIR/$APP_NAME"
DESKTOP_FILE_NAME="whatsapp.desktop"
ICON_PATH="$APP_PATH/resources/app/icon.png" # Caminho do ícone gerado pelo Electron
EXECUTABLE_PATH="$APP_PATH/$APP_NAME"

echo "========================================"
echo "  Iniciando a Automação do WhatsApp WebApp"
echo "  Usuário de Destino: $USER_NAME"
echo "  Caminho de Destino: $APP_DIR"
echo "========================================"

# --- 2. Instalação de Pré-requisitos (com sudo) ---
echo -e "\n[PASSO 1/5] Verificando e instalando Node.js, npm e Nativefier (Requer sudo)..."
if ! command -v npm &> /dev/null; then
    sudo pacman -Syu
    sudo pacman -Syu nodejs npm
fi
if ! command -v nativefier &> /dev/null; then
    sudo npm install -g nativefier
fi

# --- 3. Preparação do Diretório ---
echo -e "\n[PASSO 2/5] Preparando diretório de instalação..."
# Cria o diretório com o usuário correto
mkdir -p "$APP_DIR"
sudo chown -R "$USER_NAME:$USER_NAME" "$APP_DIR"

if [ -d "$APP_PATH" ]; then
    rm -rf "$APP_PATH"
fi

# --- 4. Criação e Otimização do WebApp (COMO USUÁRIO NORMAL) ---
echo -e "\n[PASSO 3/5] Criando WebApp Otimizado como usuário $USER_NAME..."

# Executa o Nativefier como o usuário normal para criar a pasta com permissões corretas
su -l "$USER_NAME" -c "mkdir -p '$APP_DIR' && cd '$APP_DIR' && nativefier 'https://web.whatsapp.com' \
  --name '$APP_NAME' \
  --platform linux \
  --arch x64 \
  --single-instance \
  --disable-gpu \
  --enable-context-menu \
  --tray"

# --- 5. Criação do Atalho de Desktop (.desktop) (com sudo) ---
echo -e "\n[PASSO 4/5] Criando o arquivo .desktop para o menu e ícone..."

# Cria o conteúdo do arquivo .desktop
cat <<EOF > "$DESKTOP_FILE_NAME"
[Desktop Entry]
Name=WhatsApp
Comment=WhatsApp Web App otimizado com Nativefier
Exec="$USER_HOME/.whatsapp_linux/WhatsAppLinux"
Icon=$USER_HOME/.whatsapp_linux/resources/app/icon.png
Terminal=false
Type=Application
Categories=Network;
StartupWMClass=whatsapp-linux-nativefier-d40211
EOF

# Move o arquivo .desktop para o diretório de aplicações (Requer sudo)
sudo mv "$DESKTOP_FILE_NAME" /usr/share/applications/

echo -e "\n[SUCESSO] Processo concluído!"
echo "O WhatsApp WebApp foi instalado corretamente em $APP_PATH"
echo "========================================"
