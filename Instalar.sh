#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]
then 
  echo "ERRO: Esse script deve ser executado como root."
  echo -e "\nTente: sudo su\n"
  echo "Antes de executar esse script."
  exit 1
fi

# Clear the screen
clear

# Update APT repositories
echo "Atualizando repositórios..."
apt update &> /dev/null

# Install docker
echo "Instalando docker..."
apt install -y docker.io &> /dev/null

# Install docker compose
echo "Instalando docker compose..."

# Extract docker compose latest version
version=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

# Create docker cli plugins folder
mkdir -p /usr/local/lib/docker/cli-plugins &> /dev/null

# Download that version
wget https://github.com/docker/compose/releases/download/$version/docker-compose-linux-x86_64 -O /usr/local/lib/docker/cli-plugins/docker-compose &> /dev/null

# Mark the file as executable
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose &> /dev/null

# Login to docker hub
echo "Logando no docker hub..."
read -p "Digite o token da sua unidade e pressione ENTER: " dockerUnitToken
docker login -u weducation --password-stdin <<< $dockerUnitToken &> /dev/null

# Create a directory for the ADGuard compose file and CD onto it
mkdir -p /opt/ADGuard &> /dev/null
cd /opt/ADGuard &> /dev/null

# Get the docker-compose.yaml file
wget https://raw.githubusercontent.com/weducation/ADGuard/main/docker-compose.yaml -O /opt/ADGuard/docker-compose.yaml &> /dev/null

# Down the containers just in case...
echo "Parando containers..."
docker compose down &> /dev/null

# Up the containers
echo "Iniciando containers..."
docker compose up -d
