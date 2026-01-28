# 🐳 Guia de Atualização do Container Docker - GuacPlayer CAIXA

Este guia apresenta diferentes métodos para aplicar as alterações do padrão visual CAIXA no container Docker do GuacPlayer.

---

## 📋 Pré-requisitos

- Docker instalado e em execução
- Acesso ao servidor onde o container está rodando
- Permissões para parar/iniciar containers
- Git instalado (para alguns métodos)

---

## 🎯 Métodos de Atualização

### Método 1: Rebuild Completo (Recomendado)

Este é o método mais limpo e recomendado, pois reconstrói a imagem Docker com todas as alterações.

#### Passo 1: Clonar o Repositório Atualizado

```bash
# Se ainda não tem o repositório
git clone https://github.com/WanzellerRP/glyptodon-enterprise-player.git
cd glyptodon-enterprise-player

# Se já tem o repositório, apenas atualize
cd glyptodon-enterprise-player
git pull origin master
```

#### Passo 2: Compilar o Projeto com Maven

```bash
# Compilar o projeto (gera o build otimizado)
mvn clean package

# Aguarde a conclusão do build
# O resultado estará em: target/glyptodon-enterprise-player-1.1.0-1.tar.gz
```

#### Passo 3: Extrair o Build

```bash
# Extrair o arquivo gerado
cd target
tar -xzf glyptodon-enterprise-player-1.1.0-1.tar.gz
cd ..
```

#### Passo 4: Parar o Container Atual

```bash
# Listar containers em execução
docker ps

# Parar o container (substitua CONTAINER_NAME pelo nome real)
docker stop CONTAINER_NAME

# Opcional: Remover o container antigo
docker rm CONTAINER_NAME
```

#### Passo 5: Rebuild da Imagem Docker

```bash
# Construir nova imagem com as alterações
docker build -t guacplayer-caixa:latest .

# Ou com nome específico
docker build -t guacplayer-caixa:1.1.0-caixa .
```

#### Passo 6: Executar o Novo Container

```bash
# Executar o container na porta 80
docker run -d --name guacplayer-caixa -p 80:80 guacplayer-caixa:latest

# Ou em outra porta (ex: 8080)
docker run -d --name guacplayer-caixa -p 8080:80 guacplayer-caixa:latest
```

#### Passo 7: Verificar o Container

```bash
# Verificar se está rodando
docker ps

# Ver logs
docker logs guacplayer-caixa

# Testar no navegador
# Acesse: http://localhost:80 ou http://SEU_SERVIDOR:80
```

---

### Método 2: Atualização Direta (Sem Rebuild)

Este método atualiza os arquivos diretamente no container em execução. **Atenção:** As alterações serão perdidas se o container for recriado.

#### Passo 1: Identificar o Container

```bash
# Listar containers em execução
docker ps

# Anotar o CONTAINER_ID ou CONTAINER_NAME
```

#### Passo 2: Copiar Arquivos Modificados

```bash
# Copiar arquivo custom.css
docker cp src/main/webapp/custom.css CONTAINER_ID:/usr/share/nginx/html/custom.css

# Copiar index.html
docker cp src/main/webapp/index.html CONTAINER_ID:/usr/share/nginx/html/index.html

# Copiar arquivos CSS modificados
docker cp src/main/webapp/modules/app/styles/app.css CONTAINER_ID:/usr/share/nginx/html/modules/app/styles/app.css
docker cp src/main/webapp/modules/app/styles/welcome.css CONTAINER_ID:/usr/share/nginx/html/modules/app/styles/welcome.css

# Copiar arquivos do player
docker cp src/main/webapp/modules/player/styles/player.css CONTAINER_ID:/usr/share/nginx/html/modules/player/styles/player.css
docker cp src/main/webapp/modules/player/styles/progressIndicator.css CONTAINER_ID:/usr/share/nginx/html/modules/player/styles/progressIndicator.css
docker cp src/main/webapp/modules/player/styles/seek.css CONTAINER_ID:/usr/share/nginx/html/modules/player/styles/seek.css

# Copiar imagens CAIXA
docker cp src/main/webapp/assets/img/CAIXA_elemento_cor_chapado_positivo.png CONTAINER_ID:/usr/share/nginx/html/assets/img/
docker cp src/main/webapp/assets/img/logo-caixa.png CONTAINER_ID:/usr/share/nginx/html/assets/img/
```

#### Passo 3: Reiniciar Nginx (Opcional)

```bash
# Recarregar configuração do Nginx
docker exec CONTAINER_ID nginx -s reload
```

#### Passo 4: Limpar Cache do Navegador

```bash
# No navegador, pressione Ctrl+Shift+R (ou Cmd+Shift+R no Mac)
# para forçar o reload sem cache
```

---

### Método 3: Docker Compose (Se Aplicável)

Se você usa Docker Compose, este é o método mais prático.

#### Passo 1: Criar/Atualizar docker-compose.yml

```yaml
version: '3.8'

services:
  guacplayer-caixa:
    build: .
    container_name: guacplayer-caixa
    ports:
      - "80:80"
    restart: unless-stopped
    volumes:
      - ./logs:/var/log/nginx
```

#### Passo 2: Atualizar e Rebuild

```bash
# Parar containers
docker-compose down

# Rebuild e iniciar
docker-compose up -d --build

# Ver logs
docker-compose logs -f
```

---

### Método 4: Volume Mount (Desenvolvimento)

Para desenvolvimento contínuo, monte os arquivos como volume.

#### Criar docker-compose.dev.yml

```yaml
version: '3.8'

services:
  guacplayer-caixa-dev:
    image: nginx:1.25-alpine
    container_name: guacplayer-caixa-dev
    ports:
      - "8080:80"
    volumes:
      - ./src/main/webapp:/usr/share/nginx/html:ro
    restart: unless-stopped
```

#### Executar

```bash
docker-compose -f docker-compose.dev.yml up -d

# Qualquer alteração nos arquivos será refletida imediatamente
# (pode precisar limpar cache do navegador)
```

---

## 🔄 Atualização Rápida com Script

### Script de Atualização Automática

Crie um arquivo `update-container.sh`:

```bash
#!/bin/bash

# Configurações
CONTAINER_NAME="guacplayer-caixa"
IMAGE_NAME="guacplayer-caixa:latest"
PORT="80"

echo "🚀 Iniciando atualização do GuacPlayer CAIXA..."

# 1. Atualizar repositório
echo "📥 Atualizando código do GitHub..."
git pull origin master

# 2. Compilar projeto
echo "🔨 Compilando projeto com Maven..."
mvn clean package

# 3. Extrair build
echo "📦 Extraindo build..."
cd target
tar -xzf glyptodon-enterprise-player-1.1.0-1.tar.gz
cd ..

# 4. Parar container antigo
echo "🛑 Parando container antigo..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# 5. Remover imagem antiga
echo "🗑️ Removendo imagem antiga..."
docker rmi $IMAGE_NAME 2>/dev/null || true

# 6. Construir nova imagem
echo "🏗️ Construindo nova imagem Docker..."
docker build -t $IMAGE_NAME .

# 7. Executar novo container
echo "▶️ Iniciando novo container..."
docker run -d --name $CONTAINER_NAME -p $PORT:80 --restart unless-stopped $IMAGE_NAME

# 8. Verificar status
echo "✅ Verificando status..."
sleep 2
docker ps | grep $CONTAINER_NAME

echo ""
echo "🎉 Atualização concluída!"
echo "🌐 Acesse: http://localhost:$PORT"
echo ""
echo "📋 Comandos úteis:"
echo "  - Ver logs: docker logs -f $CONTAINER_NAME"
echo "  - Parar: docker stop $CONTAINER_NAME"
echo "  - Reiniciar: docker restart $CONTAINER_NAME"
```

#### Tornar o Script Executável

```bash
chmod +x update-container.sh
```

#### Executar o Script

```bash
./update-container.sh
```

---

## 🔍 Verificação e Testes

### 1. Verificar Container em Execução

```bash
# Listar containers
docker ps

# Ver logs em tempo real
docker logs -f guacplayer-caixa

# Verificar recursos
docker stats guacplayer-caixa
```

### 2. Testar no Navegador

```bash
# Teste local
curl http://localhost:80

# Ou abra no navegador
# http://localhost:80
```

### 3. Verificar Arquivos Dentro do Container

```bash
# Acessar shell do container
docker exec -it guacplayer-caixa sh

# Dentro do container, verificar arquivos
ls -la /usr/share/nginx/html/
cat /usr/share/nginx/html/custom.css
exit
```

### 4. Checklist de Verificação

- [ ] Container está rodando (`docker ps`)
- [ ] Porta está acessível (teste no navegador)
- [ ] Logo CAIXA aparece no header
- [ ] Cores azul (#1a237e) e laranja (#FF8200) aplicadas
- [ ] Textos em português brasileiro
- [ ] Fonte Poppins carregada
- [ ] Botões arredondados (border-radius: 10px)
- [ ] Efeitos glassmorphism visíveis

---

## 🐛 Troubleshooting

### Problema: Container não inicia

```bash
# Ver logs de erro
docker logs guacplayer-caixa

# Verificar se a porta está em uso
netstat -tuln | grep :80

# Tentar outra porta
docker run -d --name guacplayer-caixa -p 8080:80 guacplayer-caixa:latest
```

### Problema: Alterações não aparecem

```bash
# Limpar cache do navegador (Ctrl+Shift+R)

# Verificar se os arquivos foram copiados
docker exec guacplayer-caixa ls -la /usr/share/nginx/html/

# Reiniciar container
docker restart guacplayer-caixa
```

### Problema: Erro no build Maven

```bash
# Verificar versão do Maven
mvn --version

# Limpar cache do Maven
mvn clean

# Tentar build novamente
mvn package -X  # modo debug
```

### Problema: Imagem muito grande

```bash
# Ver tamanho da imagem
docker images | grep guacplayer

# Limpar imagens não utilizadas
docker image prune -a
```

---

## 📊 Comparação dos Métodos

| Método | Velocidade | Persistência | Complexidade | Recomendado Para |
|--------|-----------|--------------|--------------|------------------|
| **Rebuild Completo** | ⭐⭐⭐ | ✅ Permanente | ⭐⭐⭐ | Produção |
| **Atualização Direta** | ⭐⭐⭐⭐⭐ | ❌ Temporária | ⭐⭐ | Testes rápidos |
| **Docker Compose** | ⭐⭐⭐⭐ | ✅ Permanente | ⭐⭐ | Produção |
| **Volume Mount** | ⭐⭐⭐⭐⭐ | ✅ Permanente | ⭐ | Desenvolvimento |

---

## 🎯 Recomendações

### Para Produção
1. Use o **Método 1 (Rebuild Completo)** ou **Método 3 (Docker Compose)**
2. Sempre faça backup do container atual antes de atualizar
3. Teste em ambiente de homologação primeiro
4. Configure restart policy: `--restart unless-stopped`
5. Configure logs: `-v /var/log/nginx:/var/log/nginx`

### Para Desenvolvimento
1. Use o **Método 4 (Volume Mount)** para ver alterações em tempo real
2. Mantenha o código sincronizado com o GitHub
3. Use `docker-compose.dev.yml` separado

### Para Testes Rápidos
1. Use o **Método 2 (Atualização Direta)** para validações rápidas
2. Sempre faça rebuild depois para persistir as mudanças

---

## 📚 Recursos Adicionais

### Comandos Docker Úteis

```bash
# Backup do container
docker commit guacplayer-caixa guacplayer-caixa-backup

# Exportar imagem
docker save guacplayer-caixa:latest > guacplayer-caixa.tar

# Importar imagem
docker load < guacplayer-caixa.tar

# Ver histórico da imagem
docker history guacplayer-caixa:latest

# Inspecionar container
docker inspect guacplayer-caixa
```

### Links Úteis

- **Repositório GitHub:** https://github.com/WanzellerRP/glyptodon-enterprise-player
- **Docker Hub (Nginx):** https://hub.docker.com/_/nginx
- **Documentação Maven:** https://maven.apache.org/guides/

---

## ✅ Checklist Final

Após a atualização, verifique:

- [ ] Container está rodando sem erros
- [ ] Aplicação acessível via navegador
- [ ] Padrão visual CAIXA aplicado corretamente
- [ ] Todas as funcionalidades funcionando
- [ ] Logs sem erros críticos
- [ ] Performance adequada
- [ ] Backup do container anterior realizado
- [ ] Documentação atualizada

---

**📅 Data de Criação:** 28 de Janeiro de 2026  
**👤 Autor:** Wanzeller (IT Consultant)  
**🎯 Projeto:** GuacPlayer - CAIXA
