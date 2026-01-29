#!/bin/bash

#############################################################################
# Script de Configuração de Proxy para Maven
# 
# Este script configura o Maven para trabalhar através de proxy corporativo
#############################################################################

set -e

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     Configuração de Proxy para Maven                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Detectar diretório Maven
MAVEN_HOME=""
if [ -d "$HOME/.m2" ]; then
    MAVEN_HOME="$HOME/.m2"
elif [ -d "/root/.m2" ]; then
    MAVEN_HOME="/root/.m2"
else
    MAVEN_HOME="$HOME/.m2"
    mkdir -p "$MAVEN_HOME"
fi

SETTINGS_FILE="$MAVEN_HOME/settings.xml"

echo -e "${BLUE}ℹ  Diretório Maven: $MAVEN_HOME${NC}"
echo ""

# Perguntar se quer configurar proxy
echo -e "${YELLOW}Você está atrás de um proxy corporativo?${NC}"
echo "1) Sim, configurar proxy"
echo "2) Não, usar configuração direta"
echo "3) Usar modo offline (sem downloads)"
echo ""
read -p "Escolha uma opção [1-3]: " PROXY_CHOICE

case $PROXY_CHOICE in
    1)
        # Configurar proxy
        echo ""
        echo -e "${BLUE}═══ Configuração de Proxy ═══${NC}"
        echo ""
        
        # Solicitar informações do proxy
        read -p "Host do proxy (ex: proxy.empresa.com): " PROXY_HOST
        read -p "Porta do proxy (ex: 8080): " PROXY_PORT
        read -p "Usuário do proxy (deixe em branco se não houver): " PROXY_USER
        
        if [ -n "$PROXY_USER" ]; then
            read -sp "Senha do proxy: " PROXY_PASS
            echo ""
        fi
        
        read -p "Hosts que NÃO devem usar proxy (ex: localhost,127.0.0.1): " NO_PROXY
        
        # Criar backup do settings.xml se existir
        if [ -f "$SETTINGS_FILE" ]; then
            echo ""
            echo -e "${YELLOW}⚠  Fazendo backup do settings.xml existente...${NC}"
            cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        
        # Criar settings.xml com configuração de proxy
        cat > "$SETTINGS_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
  <proxies>
    <!-- Proxy HTTP -->
    <proxy>
      <id>http-proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>${PROXY_HOST}</host>
      <port>${PROXY_PORT}</port>
EOF

        if [ -n "$PROXY_USER" ]; then
            cat >> "$SETTINGS_FILE" << EOF
      <username>${PROXY_USER}</username>
      <password>${PROXY_PASS}</password>
EOF
        fi

        if [ -n "$NO_PROXY" ]; then
            cat >> "$SETTINGS_FILE" << EOF
      <nonProxyHosts>${NO_PROXY}</nonProxyHosts>
EOF
        fi

        cat >> "$SETTINGS_FILE" << EOF
    </proxy>
    
    <!-- Proxy HTTPS -->
    <proxy>
      <id>https-proxy</id>
      <active>true</active>
      <protocol>https</protocol>
      <host>${PROXY_HOST}</host>
      <port>${PROXY_PORT}</port>
EOF

        if [ -n "$PROXY_USER" ]; then
            cat >> "$SETTINGS_FILE" << EOF
      <username>${PROXY_USER}</username>
      <password>${PROXY_PASS}</password>
EOF
        fi

        if [ -n "$NO_PROXY" ]; then
            cat >> "$SETTINGS_FILE" << EOF
      <nonProxyHosts>${NO_PROXY}</nonProxyHosts>
EOF
        fi

        cat >> "$SETTINGS_FILE" << EOF
    </proxy>
  </proxies>
  
  <!-- Repositórios mirror (opcional, para acelerar downloads) -->
  <mirrors>
    <mirror>
      <id>central-mirror</id>
      <name>Maven Central Mirror</name>
      <url>https://repo.maven.apache.org/maven2</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
  
</settings>
EOF

        echo ""
        echo -e "${GREEN}✅ Proxy configurado com sucesso!${NC}"
        echo -e "${BLUE}ℹ  Arquivo: $SETTINGS_FILE${NC}"
        ;;
        
    2)
        # Configuração direta (sem proxy)
        if [ -f "$SETTINGS_FILE" ]; then
            echo ""
            echo -e "${YELLOW}⚠  Fazendo backup do settings.xml existente...${NC}"
            cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        fi
        
        cat > "$SETTINGS_FILE" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
  <!-- Sem proxy, acesso direto à internet -->
  
  <mirrors>
    <mirror>
      <id>central-mirror</id>
      <name>Maven Central</name>
      <url>https://repo.maven.apache.org/maven2</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
  
</settings>
EOF

        echo ""
        echo -e "${GREEN}✅ Configuração direta criada!${NC}"
        echo -e "${BLUE}ℹ  Arquivo: $SETTINGS_FILE${NC}"
        ;;
        
    3)
        # Modo offline
        echo ""
        echo -e "${YELLOW}⚠  Modo offline selecionado${NC}"
        echo -e "${BLUE}ℹ  O Maven usará apenas dependências já baixadas${NC}"
        echo -e "${BLUE}ℹ  Use a flag -o ou --offline ao executar mvn${NC}"
        echo ""
        echo -e "${BLUE}Exemplo: mvn clean package -o${NC}"
        ;;
        
    *)
        echo ""
        echo -e "${RED}❌ Opção inválida${NC}"
        exit 1
        ;;
esac

# Testar configuração
if [ "$PROXY_CHOICE" != "3" ]; then
    echo ""
    echo -e "${BLUE}═══ Testando Configuração ═══${NC}"
    echo ""
    echo -e "${BLUE}ℹ  Testando conexão com Maven Central...${NC}"
    
    if curl -s --max-time 10 https://repo.maven.apache.org/maven2/ > /dev/null; then
        echo -e "${GREEN}✅ Conexão com Maven Central OK!${NC}"
    else
        echo -e "${YELLOW}⚠  Não foi possível conectar ao Maven Central${NC}"
        echo -e "${YELLOW}   Verifique as configurações de proxy${NC}"
    fi
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Configuração concluída!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Mostrar próximos passos
echo -e "${BLUE}📋 Próximos passos:${NC}"
echo ""

if [ "$PROXY_CHOICE" = "1" ]; then
    echo "1. Teste a configuração:"
    echo "   mvn -v"
    echo ""
    echo "2. Execute o build:"
    echo "   mvn clean package"
    echo ""
    echo "3. Se houver problemas, verifique:"
    echo "   - Credenciais do proxy"
    echo "   - Firewall corporativo"
    echo "   - Certificados SSL"
elif [ "$PROXY_CHOICE" = "2" ]; then
    echo "1. Execute o build normalmente:"
    echo "   mvn clean package"
elif [ "$PROXY_CHOICE" = "3" ]; then
    echo "1. Certifique-se de ter as dependências baixadas"
    echo ""
    echo "2. Execute o build em modo offline:"
    echo "   mvn clean package -o"
    echo ""
    echo "3. Ou use o script update-container.sh com --skip-maven:"
    echo "   ./update-container.sh --skip-maven"
fi

echo ""
echo -e "${BLUE}📚 Documentação:${NC}"
echo "   - TROUBLESHOOTING_PROXY.md (em breve)"
echo "   - https://maven.apache.org/guides/mini/guide-proxies.html"
echo ""
