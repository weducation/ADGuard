#!/bin/bash

# Check if running as root
if [ "$EUID" -ne 0 ]
then 
  echo "ERRO: Esse script deve ser executado como root."
  echo -e "\nTente: sudo su\n"
  echo "Antes de executar esse script."
  exit 1
fi

# Variables
composeRepo="docker/compose"
composePath="/usr/local/lib/docker/cli-plugins"
composeFile="docker-compose-linux-x86_64"
composeDestFile="docker-compose"
composeLatestVersion=$(curl -s https://api.github.com/repos/$composeRepo/releases/latest | grep 'tag_name' | cut -d\" -f4)
workDir="/opt/ADGuard"

# Clear the screen
clear

# Disable systemd-resolved
echo "Desabilitando systemd-resolved..."
systemctl stop systemd-resolved &> /dev/null
systemctl disable systemd-resolved &> /dev/null

# Update APT repositories
echo "Atualizando repositórios..."
apt update &> /dev/null

# Install docker
echo "Instalando docker..."
apt install -y docker.io &> /dev/null

# Install docker compose
echo "Instalando docker compose..."

# Create docker cli plugins folder
mkdir -p $composePath &> /dev/null

# Download that version
wget https://github.com/$composeRepo/releases/download/$composeLatestVersion/$composeFile -O $composePath/$composeDestFile &> /dev/null

# Mark the file as executable
chmod +x $composePath/$composeDestFile &> /dev/null

# Login to docker hub
echo "Logando no docker hub..."
read -p "Digite o token da sua unidade e pressione ENTER: " dockerUnitToken
docker login -u weducation --password-stdin <<< $dockerUnitToken &> /dev/null

# Create a directory for the ADGuard compose file and CD onto it
mkdir -p $workDir &> /dev/null
cd $workDir &> /dev/null

# Get the docker-compose.yaml file
wget https://raw.githubusercontent.com/weducation/ADGuard/main/docker-compose.yaml -O $workDir/docker-compose.yaml &> /dev/null

# Down the containers just in case...
echo "Parando containers..."
docker compose down 2> /dev/null

# Up the containers
echo "Iniciando containers..."
docker compose up -d
