# Instalador Simplificado OpenClaw

Este script (`instalar.sh`) automatiza a instalação e configuração do **OpenClaw** em um servidor Linux (focado em distribuições baseadas no Debian/Ubuntu). Ele cuida de todas as dependências, provisionamento do Docker e configuração de SSL automático utilizando o Caddy Server.

## O que o script faz?

1. **Solicita dados de configuração**: Pede o domínio onde o sistema ficará acessível e a senha para a interface (UI).
2. **Atualiza o sistema**: Executa `apt update && apt upgrade` e instala pacotes básicos (`curl` e `gnupg2`).
3. **Instala o Docker**: Verifica se o Docker está instalado; caso não esteja, faz a instalação automática via script oficial (`get.docker.com`).
4. **Instala o Caddy Server**: Adiciona o repositório oficial do Caddy e realiza a instalação. O Caddy atuará como proxy reverso e gerenciará os certificados SSL automaticamente.
5. **Configura o OpenClaw**:
   - Cria o diretório `~/openclaw` e o subdiretório `data` com as permissões corretas.
   - Cria o arquivo `docker-compose.yml` rodando a imagem oficial `ghcr.io/openclaw/openclaw:latest` na porta `3000`.
6. **Configura o Domínio**: Adiciona as regras ao `/etc/caddy/Caddyfile` para rotear o tráfego do domínio informado para o container na porta 3000.
7. **Inicia os serviços**: Reinicia o Caddy e sobe os containers do Docker (`docker compose up -d`).

## Pré-requisitos

- Um servidor VPS (Ubuntu/Debian) com acesso **root**.
- Um **domínio** ou subdomínio (ex: `agentes.seudominio.com.br`) já apontado (registro A) para o IP público deste servidor.

## Como usar

1. Faça o download ou crie o arquivo `instalar.sh` no seu servidor.
2. Dê permissão de execução ao script:
   ```bash
   chmod +x instalar.sh
   ```
3. Execute o instalador como root (ou com sudo):
   ```bash
   ./instalar.sh
   # ou
   sudo ./instalar.sh
   ```
4. Siga as instruções na tela:
   - Digite o seu domínio (certifique-se de que o DNS já propagou).
   - Defina uma senha segura para acesso à interface.
5. Aguarde o fim da instalação. Ao concluir, você verá a mensagem de sucesso com a URL de acesso.

## Após a instalação

Basta acessar o painel pelo seu navegador:

- **URL:** `https://<seu-dominio>`
- **Senha:** A senha informada durante a instalação.

Todos os dados persistentes do OpenClaw ficarão salvos em `~/openclaw/data`.
