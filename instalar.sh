#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}=== Instalador Simplificado OpenClaw ===${NC}"

# 1. Pedir dados ao usuário
read -p "Digite o seu domínio (ex: agentes.dominio.com): " DOMAIN
read -p "Defina a senha para a UI (Interface): " UI_PASSWORD

echo -e "${GREEN}Iniciando instalação... Isso pode levar alguns minutos.${NC}"

# 2. Atualizar sistema e instalar dependências
apt update && apt upgrade -y
apt install -y curl gnupg2

# 3. Instalar Docker
if ! command -v docker &> /dev/null; then
    echo "Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

# 4. Instalar Caddy (SSL Automático)
if ! command -v caddy &> /dev/null; then
    echo "Instalando Caddy Server..."
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
    apt update && apt install caddy -y
fi

# 5. Criar pastas e Docker Compose
mkdir -p ~/openclaw/data
chmod -R 777 ~/openclaw/data
cd ~/openclaw

cat <<EOF > docker-compose.yml
services:
  openclaw:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw
    restart: always
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DOMAIN=$DOMAIN
      - UI_PASSWORD=$UI_PASSWORD
    volumes:
      - ./data:/app/data
EOF

# 6. Configurar Caddyfile
cat <<EOF > /etc/caddy/Caddyfile
$DOMAIN {
    reverse_proxy localhost:3000
}
EOF

# 7. Subir os serviços
systemctl restart caddy
docker compose up -d

echo -e "${GREEN}-------------------------------------------------------"
echo "INSTALAÇÃO CONCLUÍDA!"
echo "Acesse: https://$DOMAIN"
echo "Senha da Interface: $UI_PASSWORD"
echo "-------------------------------------------------------${NC}"