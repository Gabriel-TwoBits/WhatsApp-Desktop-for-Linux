#!/bin/bash

# --- 1. Determina o Usuário e Variáveis ---
if [ "$SUDO_USER" ]; then
    USER_NAME="$SUDO_USER"
else
    USER_NAME="$(whoami)"
fi

USER_HOME=$(eval echo "~$USER_NAME") # /home/usuario
APP_NAME="WhatsApp"
APP_DIR="$USER_HOME/.whatsapp_linux"
APP_PATH="$APP_DIR/$APP_NAME"
DESKTOP_FILE="/usr/share/applications/whatsapp.desktop"

echo "========================================"
echo "  Iniciando a Remoção do WhatsApp WebApp"
echo "  Usuário de Destino: $USER_NAME"
echo "========================================"

# --- 2. Remoção do Diretório do Aplicativo ---
echo -e "\n[PASSO 1/3] Removendo pasta do aplicativo ($APP_DIR)..."
if [ -d "$APP_DIR" ]; then
    # Remove todo o diretório recursivamente
    rm -rf "$APP_DIR"
    echo "Diretório do aplicativo removido."
else
    echo "Diretório do aplicativo não encontrado em $APP_DIR. Ignorando..."
fi

# --- 3. Remoção do Atalho de Desktop (.desktop) ---
echo -e "\n[PASSO 2/3] Removendo arquivo .desktop ($DESKTOP_FILE)..."
if [ -f "$DESKTOP_FILE" ]; then
    # Necessita de permissão root para remover de /usr/share/applications/
    sudo rm "$DESKTOP_FILE"
    echo "Atalho de desktop removido."
    # Atualiza o banco de dados de desktop
    sudo update-desktop-database &> /dev/null
else
    echo "Arquivo .desktop não encontrado. Ignorando..."
fi

# --- 4. Remoção do Nativefier (Opcional) ---
echo -e "\n[PASSO 3/3] Removendo Nativefier (Global - Opcional)..."
read -p "Deseja remover o Nativefier (npm) e liberar espaço de disco? (s/N): " REMOVE_NATIVEFIER
if [[ "$REMOVE_NATIVEFIER" =~ ^[sS]$ ]]; then
    # Necessita de permissão root para remover módulos npm globais
    sudo npm uninstall -g nativefier
    echo "Nativefier removido."
else
    echo "Nativefier mantido no sistema."
fi

echo -e "\n[SUCESSO] Remoção concluída!"
echo "O WhatsApp WebApp foi completamente removido do seu sistema."
echo "========================================"
