#!/bin/bash

################################################################################
# Script de Atualização do Container GuacPlayer CAIXA
# 
# Este script automatiza o processo de atualização do container Docker
# com as alterações do padrão visual CAIXA.
#
# Autor: Wanzeller (IT Consultant)
# Data: 28 de Janeiro de 2026
# Projeto: GuacPlayer - CAIXA
################################################################################

# Configurações (ajuste conforme necessário)
CONTAINER_NAME="${CONTAINER_NAME:-guacplayer-caixa}"
IMAGE_NAME="${IMAGE_NAME:-guacplayer-caixa}"
IMAGE_TAG="${IMAGE_TAG:-latest}"
PORT="${PORT:-80}"
BACKUP_ENABLED="${BACKUP_ENABLED:-true}"

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funções auxiliares
print_header() {
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Verificar se Docker está instalado
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker não está instalado!"
        echo "Por favor, instale o Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    print_success "Docker encontrado: $(docker --version)"
}

# Verificar se Maven está instalado
check_maven() {
    if ! command -v mvn &> /dev/null; then
        print_warning "Maven não está instalado!"
        print_info "Tentando usar build pré-compilado..."
        return 1
    fi
    print_success "Maven encontrado: $(mvn --version | head -1)"
    return 0
}

# Verificar se Git está instalado
check_git() {
    if ! command -v git &> /dev/null; then
        print_error "Git não está instalado!"
        echo "Por favor, instale o Git: https://git-scm.com/downloads"
        exit 1
    fi
    print_success "Git encontrado: $(git --version)"
}

# Fazer backup do container atual
backup_container() {
    if [ "$BACKUP_ENABLED" = "true" ]; then
        print_info "Criando backup do container atual..."
        
        if docker ps -a | grep -q "$CONTAINER_NAME"; then
            BACKUP_NAME="${CONTAINER_NAME}-backup-$(date +%Y%m%d-%H%M%S)"
            docker commit "$CONTAINER_NAME" "$BACKUP_NAME" 2>/dev/null
            
            if [ $? -eq 0 ]; then
                print_success "Backup criado: $BACKUP_NAME"
            else
                print_warning "Não foi possível criar backup (container pode não existir)"
            fi
        else
            print_info "Nenhum container existente para backup"
        fi
    fi
}

# Atualizar código do GitHub
update_code() {
    print_info "Verificando atualizações do GitHub..."
    
    # Verificar se estamos em um repositório Git
    if [ ! -d ".git" ]; then
        print_error "Este diretório não é um repositório Git!"
        print_info "Clone o repositório primeiro:"
        echo "  git clone https://github.com/WanzellerRP/glyptodon-enterprise-player.git"
        exit 1
    fi
    
    # Verificar branch atual
    CURRENT_BRANCH=$(git branch --show-current)
    print_info "Branch atual: $CURRENT_BRANCH"
    
    # Fazer pull
    git pull origin "$CURRENT_BRANCH"
    
    if [ $? -eq 0 ]; then
        print_success "Código atualizado do GitHub"
    else
        print_error "Erro ao atualizar código do GitHub"
        exit 1
    fi
}

# Compilar projeto com Maven
build_project() {
    if check_maven; then
        print_info "Compilando projeto com Maven..."
        
        mvn clean package -DskipTests
        
        if [ $? -eq 0 ]; then
            print_success "Projeto compilado com sucesso"
            
    # Extrair build
    print_info "Extraindo build..."
    cd target
    tar -xzf glyptodon-enterprise-player-*.tar.gz 2>/dev/null
    cd ..
    
    # Substituir logo antigo pelo logo CAIXA
    print_info "Substituindo logo antigo pelo logo CAIXA..."
    if [ -f "target/glyptodon-enterprise-player-1.1.0-1/assets/img/logo-caixa.png" ]; then
        cp target/glyptodon-enterprise-player-1.1.0-1/assets/img/logo-caixa.png \
           target/glyptodon-enterprise-player-1.1.0-1/images/glen-icon-small.png
        print_success "Logo substituído"
    else
        print_warning "Logo CAIXA não encontrado, mantendo logo original"
    fi
            
            if [ $? -eq 0 ]; then
                print_success "Build extraído"
                return 0
            else
                print_error "Erro ao extrair build"
                return 1
            fi
        else
            print_error "Erro ao compilar projeto"
            return 1
        fi
    else
        print_warning "Pulando compilação (Maven não disponível)"
        return 1
    fi
}

# Parar e remover container antigo
stop_old_container() {
    print_info "Parando container antigo..."
    
    if docker ps | grep -q "$CONTAINER_NAME"; then
        docker stop "$CONTAINER_NAME"
        print_success "Container parado"
    else
        print_info "Nenhum container em execução"
    fi
    
    if docker ps -a | grep -q "$CONTAINER_NAME"; then
        docker rm "$CONTAINER_NAME"
        print_success "Container removido"
    fi
}

# Construir nova imagem Docker
build_image() {
    print_info "Construindo nova imagem Docker..."
    
    docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
    
    if [ $? -eq 0 ]; then
        print_success "Imagem construída: ${IMAGE_NAME}:${IMAGE_TAG}"
        
        # Mostrar tamanho da imagem
        IMAGE_SIZE=$(docker images "${IMAGE_NAME}:${IMAGE_TAG}" --format "{{.Size}}")
        print_info "Tamanho da imagem: $IMAGE_SIZE"
    else
        print_error "Erro ao construir imagem Docker"
        exit 1
    fi
}

# Executar novo container
run_container() {
    print_info "Iniciando novo container..."
    
    docker run -d \
        --name "$CONTAINER_NAME" \
        -p "${PORT}:80" \
        --restart unless-stopped \
        "${IMAGE_NAME}:${IMAGE_TAG}"
    
    if [ $? -eq 0 ]; then
        print_success "Container iniciado: $CONTAINER_NAME"
        print_info "Porta: $PORT"
    else
        print_error "Erro ao iniciar container"
        exit 1
    fi
}

# Verificar status do container
verify_container() {
    print_info "Verificando status do container..."
    sleep 3
    
    if docker ps | grep -q "$CONTAINER_NAME"; then
        print_success "Container está rodando!"
        
        # Mostrar informações
        echo ""
        docker ps | grep "$CONTAINER_NAME"
        echo ""
        
        # Testar conectividade
        print_info "Testando conectividade..."
        if command -v curl &> /dev/null; then
            HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:${PORT}")
            if [ "$HTTP_CODE" = "200" ]; then
                print_success "Aplicação respondendo (HTTP $HTTP_CODE)"
            else
                print_warning "Aplicação retornou HTTP $HTTP_CODE"
            fi
        else
            print_info "curl não disponível, pulando teste de conectividade"
        fi
    else
        print_error "Container não está rodando!"
        print_info "Verificando logs..."
        docker logs "$CONTAINER_NAME"
        exit 1
    fi
}

# Limpar recursos não utilizados
cleanup() {
    print_info "Limpando recursos não utilizados..."
    
    # Remover imagens dangling
    docker image prune -f > /dev/null 2>&1
    
    print_success "Limpeza concluída"
}

# Mostrar informações finais
show_final_info() {
    echo ""
    print_header "🎉 ATUALIZAÇÃO CONCLUÍDA COM SUCESSO!"
    echo ""
    print_success "Container: $CONTAINER_NAME"
    print_success "Imagem: ${IMAGE_NAME}:${IMAGE_TAG}"
    print_success "Porta: $PORT"
    echo ""
    print_info "🌐 Acesse a aplicação em:"
    echo "   http://localhost:${PORT}"
    echo ""
    print_info "📋 Comandos úteis:"
    echo "   Ver logs:      docker logs -f $CONTAINER_NAME"
    echo "   Parar:         docker stop $CONTAINER_NAME"
    echo "   Reiniciar:     docker restart $CONTAINER_NAME"
    echo "   Remover:       docker rm -f $CONTAINER_NAME"
    echo "   Shell:         docker exec -it $CONTAINER_NAME sh"
    echo ""
}

# Função principal
main() {
    print_header "🚀 ATUALIZAÇÃO DO GUACPLAYER CAIXA"
    echo ""
    
    # Verificações iniciais
    print_header "1️⃣  VERIFICAÇÕES INICIAIS"
    check_docker
    check_git
    echo ""
    
    # Backup
    print_header "2️⃣  BACKUP"
    backup_container
    echo ""
    
    # Atualizar código
    print_header "3️⃣  ATUALIZAÇÃO DO CÓDIGO"
    update_code
    echo ""
    
    # Compilar (opcional)
    print_header "4️⃣  COMPILAÇÃO"
    build_project
    echo ""
    
    # Parar container antigo
    print_header "5️⃣  REMOÇÃO DO CONTAINER ANTIGO"
    stop_old_container
    echo ""
    
    # Construir imagem
    print_header "6️⃣  BUILD DA IMAGEM DOCKER"
    build_image
    echo ""
    
    # Executar container
    print_header "7️⃣  EXECUÇÃO DO NOVO CONTAINER"
    run_container
    echo ""
    
    # Verificar
    print_header "8️⃣  VERIFICAÇÃO"
    verify_container
    echo ""
    
    # Limpar
    print_header "9️⃣  LIMPEZA"
    cleanup
    echo ""
    
    # Informações finais
    show_final_info
}

# Tratamento de erros
set -e
trap 'print_error "Erro na linha $LINENO. Abortando..."; exit 1' ERR

# Executar
main "$@"
