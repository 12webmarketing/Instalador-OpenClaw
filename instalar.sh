#!/bin/bash

# Cores para o terminal
GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}=== Instalador OpenClaw + Traefik (Hetzner Edition) ===${NC}"

# 1. Solicitação de dados
read -p "Digite o seu domínio (ex: agentes.12webmarketing.com.br): " DOMAIN
read -p "Digite seu e-mail (para o SSL Let's Encrypt): " EMAIL
read -p "Defina a senha da UI (Password): " UI_PASS

# 2. Limpeza de conflitos (Remove o Caddy se estiver rodando)
echo "Limpando possíveis conflitos..."
systemctl stop caddy &> /dev/null
systemctl disable caddy &> /dev/null

# 3. Instalação de dependências
apt update && apt upgrade -y
apt install -y curl gnupg2

# 4. Instalar Docker
if ! command -v docker &> /dev/null; then
    echo "Instalando Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
fi

# 5. Criar estrutura de pastas e permissões
mkdir -p ~/openclaw/data ~/openclaw/letsencrypt
chmod -R 777 ~/openclaw/data
touch ~/openclaw/letsencrypt/acme.json
chmod 600 ~/openclaw/letsencrypt/acme.json
cd ~/openclaw

# 6. Criar o Docker Compose unificado
cat <<EOF > docker-compose.yml
services:
  traefik:
    image: traefik:v3.0
    container_name: traefik
    restart: always
    command:
      - "--providers.docker=true"
      - "--providers.docker.exposedbydefault=false"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
      - "--certificatesresolvers.myresolver.acme.email=$EMAIL"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
      - "./letsencrypt:/letsencrypt"

  openclaw:
    image: ghcr.io/openclaw/openclaw:latest
    container_name: openclaw
    restart: always
    environment:
      - NODE_ENV=production
      - DOMAIN=$DOMAIN
      - HOST=0.0.0.0
      - UI_PASSWORD=$UI_PASS
    volumes:
      - ./data:/app/data
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.openclaw.rule=Host(\`$DOMAIN\`)"
      - "traefik.http.routers.openclaw.entrypoints=websecure"
      - "traefik.http.routers.openclaw.tls.certresolver=myresolver"
      - "traefik.http.services.openclaw.loadbalancer.server.port=18791"
EOF

# 7. Inicializar serviços
docker compose up -d --force-recreate

echo -e "${GREEN}-------------------------------------------------------"
echo "INSTALAÇÃO CONCLUÍDA!"
echo "Acesse: https://$DOMAIN"
echo "Senha configurada: $UI_PASS"
echo "-------------------------------------------------------${NC}"