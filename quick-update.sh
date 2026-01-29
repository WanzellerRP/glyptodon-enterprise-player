#!/bin/bash

################################################################################
# Script de Atualização Rápida (Sem Rebuild)
# 
# Este script copia os arquivos modificados diretamente para o container
# em execução, sem precisar fazer rebuild da imagem.
#
# ATENÇÃO: As alterações serão perdidas se o container for recriado!
#
# Autor: Wanzeller (IT Consultant)
# Data: 28 de Janeiro de 2026
################################################################################

# Configurações
CONTAINER_NAME="${1:-guacplayer-caixa}"
BASE_PATH="/usr/share/nginx/html"

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  🚀 Atualização Rápida do GuacPlayer CAIXA${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Verificar se o container existe
if ! docker ps | grep -q "$CONTAINER_NAME"; then
    echo -e "${RED}❌ Container '$CONTAINER_NAME' não está rodando!${NC}"
    echo ""
    echo "Containers disponíveis:"
    docker ps --format "table {{.Names}}\t{{.Status}}"
    echo ""
    echo "Uso: $0 [NOME_DO_CONTAINER]"
    exit 1
fi

echo -e "${GREEN}✅ Container encontrado: $CONTAINER_NAME${NC}"
echo ""

# Criar diretórios necessários no container
echo -e "${BLUE}📁 Criando diretórios necessários...${NC}"
docker exec "$CONTAINER_NAME" mkdir -p "$BASE_PATH/assets/img" 2>/dev/null
docker exec "$CONTAINER_NAME" mkdir -p "$BASE_PATH/images" 2>/dev/null
echo -e "${GREEN}   ✅ Diretórios criados${NC}"
echo ""

# Função para copiar arquivo
copy_file() {
    local src=$1
    local dest=$2
    
    if [ -f "$src" ]; then
        echo -e "${BLUE}📄 Copiando: $src${NC}"
        docker cp "$src" "$CONTAINER_NAME:$dest"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}   ✅ Copiado com sucesso${NC}"
        else
            echo -e "${RED}   ❌ Erro ao copiar${NC}"
        fi
    else
        echo -e "${YELLOW}   ⚠️  Arquivo não encontrado: $src${NC}"
    fi
}

echo -e "${BLUE}📦 Copiando arquivos modificados...${NC}"
echo ""

# Copiar custom.css
copy_file "src/main/webapp/custom.css" "$BASE_PATH/custom.css"

# Copiar index.html
copy_file "src/main/webapp/index.html" "$BASE_PATH/index.html"

# Copiar arquivos CSS da aplicação
copy_file "src/main/webapp/modules/app/styles/app.css" "$BASE_PATH/modules/app/styles/app.css"
copy_file "src/main/webapp/modules/app/styles/welcome.css" "$BASE_PATH/modules/app/styles/welcome.css"

# Copiar arquivos CSS do player
copy_file "src/main/webapp/modules/player/styles/player.css" "$BASE_PATH/modules/player/styles/player.css"
copy_file "src/main/webapp/modules/player/styles/progressIndicator.css" "$BASE_PATH/modules/player/styles/progressIndicator.css"
copy_file "src/main/webapp/modules/player/styles/seek.css" "$BASE_PATH/modules/player/styles/seek.css"

# Copiar imagens CAIXA
echo ""
echo -e "${BLUE}🖼️  Copiando imagens...${NC}"
copy_file "src/main/webapp/assets/img/CAIXA_elemento_cor_chapado_positivo.png" "$BASE_PATH/assets/img/CAIXA_elemento_cor_chapado_positivo.png"
copy_file "src/main/webapp/assets/img/logo-caixa.png" "$BASE_PATH/assets/img/logo-caixa.png"

# Substituir logo antigo pelo logo CAIXA
echo -e "${BLUE}🔄 Substituindo logo antigo pelo logo CAIXA...${NC}"
copy_file "src/main/webapp/assets/img/logo-caixa.png" "$BASE_PATH/images/glen-icon-small.png"

# Recarregar Nginx
echo ""
echo -e "${BLUE}🔄 Recarregando Nginx...${NC}"
docker exec "$CONTAINER_NAME" nginx -s reload 2>/dev/null

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Nginx recarregado${NC}"
else
    echo -e "${YELLOW}⚠️  Não foi possível recarregar Nginx (pode não ser necessário)${NC}"
fi

# Informações finais
echo ""
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✅ Atualização rápida concluída!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${YELLOW}⚠️  IMPORTANTE:${NC}"
echo "   - As alterações são temporárias"
echo "   - Serão perdidas se o container for recriado"
echo "   - Para alterações permanentes, use: ./update-container.sh"
echo ""
echo -e "${BLUE}💡 Próximos passos:${NC}"
echo "   1. Limpe o cache do navegador (Ctrl+Shift+R)"
echo "   2. Acesse a aplicação e verifique as alterações"
echo "   3. Se estiver tudo OK, faça rebuild para persistir:"
echo "      ./update-container.sh"
echo ""
