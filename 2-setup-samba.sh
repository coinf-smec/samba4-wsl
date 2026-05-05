#!/bin/bash
set -e

SHARE_NAME="compartilhado"
SHARE_PATH="/mnt/c/$SHARE_NAME"
SMB_USER="${1:-$USER}"

echo "==> Criando pasta na estrutura do Windows (C:\$SHARE_NAME)..."
mkdir -p "$SHARE_PATH"

echo "==> Instalando Samba..."
sudo apt update -qq && sudo apt install -y samba samba-common-bin smbclient

echo "==> Gerando /etc/samba/smb.conf com Lixeira ativada..."
sudo tee /etc/samba/smb.conf > /dev/null <<EOF
[global]
   workgroup = WORKGROUP
   server string = WSL Samba Server
   server role = standalone server
   security = user
   map to guest = never
   server min protocol = SMB2
   client min protocol = SMB2
   socket options = TCP_NODELAY IPTOS_LOWDELAY
   load printers = no
   disable spoolss = yes

[$SHARE_NAME]
   comment = Pasta Compartilhada no C:
   path = $SHARE_PATH
   browseable = yes
   read only = no
   writable = yes
   guest ok = no
   valid users = $SMB_USER
   force user = $SMB_USER
   
   # --- Configuração da Lixeira (Recycle Bin) ---
   vfs objects = recycle
   recycle:repository = .lixeira
   recycle:keeptree = yes
   recycle:versions = yes
   recycle:touch = yes
   recycle:exclude = *.tmp, *.temp, ~$*
EOF

echo "==> Defina a SENHA SMB para acessar pelo Windows:"
sudo smbpasswd -a "$SMB_USER"

# Apenas garante o automount, inicialização de serviços será via .bat
sudo tee /etc/wsl.conf > /dev/null <<EOF
[automount]
enabled = true
options = "metadata,umask=22,fmask=11"
EOF

echo "==> Instalação do Samba no Linux concluída."