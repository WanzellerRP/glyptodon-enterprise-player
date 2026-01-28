# 📜 Guia de Scripts de Atualização

Este documento explica como usar os scripts automatizados para atualizar o container Docker do GuacPlayer CAIXA.

---

## 📋 Scripts Disponíveis

### 1. `update-container.sh` - Atualização Completa (Recomendado)

**Uso:** Para atualizar o container com rebuild completo da imagem.

**Características:**
- ✅ Atualização permanente
- ✅ Faz backup do container atual
- ✅ Atualiza código do GitHub
- ✅ Compila com Maven (se disponível)
- ✅ Reconstrói imagem Docker
- ✅ Cria novo container

**Como usar:**

```bash
# Uso básico (usa configurações padrão)
./update-container.sh

# Com configurações customizadas
CONTAINER_NAME=meu-guacplayer PORT=8080 ./update-container.sh
```

**Variáveis de ambiente:**
- `CONTAINER_NAME` - Nome do container (padrão: guacplayer-caixa)
- `IMAGE_NAME` - Nome da imagem (padrão: guacplayer-caixa)
- `IMAGE_TAG` - Tag da imagem (padrão: latest)
- `PORT` - Porta de exposição (padrão: 80)
- `BACKUP_ENABLED` - Fazer backup (padrão: true)

**Exemplo:**
```bash
CONTAINER_NAME=guacplayer PORT=8080 BACKUP_ENABLED=false ./update-container.sh
```

---

### 2. `quick-update.sh` - Atualização Rápida (Temporária)

**Uso:** Para testar alterações rapidamente sem rebuild.

**Características:**
- ⚡ Muito rápido (segundos)
- ⚠️ Alterações temporárias
- ❌ Perdidas ao recriar container
- ✅ Ideal para testes

**Como usar:**

```bash
# Uso básico
./quick-update.sh

# Especificar nome do container
./quick-update.sh meu-container
```

**Quando usar:**
- Testar alterações de CSS rapidamente
- Validar mudanças visuais
- Debug de problemas de layout
- Desenvolvimento iterativo

**⚠️ IMPORTANTE:** Sempre execute `update-container.sh` depois para persistir as mudanças!

---

### 3. Docker Compose - Gerenciamento Simplificado

#### 3.1 Produção (`docker-compose.yml`)

**Uso:** Para deploy em produção com configurações otimizadas.

```bash
# Iniciar
docker-compose up -d

# Rebuild e iniciar
docker-compose up -d --build

# Parar
docker-compose down

# Ver logs
docker-compose logs -f

# Reiniciar
docker-compose restart
```

**Características:**
- Porta: 80
- Restart automático
- Healthcheck configurado
- Logs persistentes

#### 3.2 Desenvolvimento (`docker-compose.dev.yml`)

**Uso:** Para desenvolvimento com hot-reload.

```bash
# Iniciar ambiente de desenvolvimento
docker-compose -f docker-compose.dev.yml up -d

# Ver logs
docker-compose -f docker-compose.dev.yml logs -f

# Parar
docker-compose -f docker-compose.dev.yml down
```

**Características:**
- Porta: 8080
- Volume mount (alterações em tempo real)
- Sem necessidade de rebuild
- Ideal para desenvolvimento

---

## 🎯 Fluxo de Trabalho Recomendado

### Para Produção

```bash
# 1. Atualizar código
git pull origin master

# 2. Atualizar container (método completo)
./update-container.sh

# 3. Verificar
docker ps
docker logs -f guacplayer-caixa
```

### Para Desenvolvimento

```bash
# 1. Iniciar ambiente de desenvolvimento
docker-compose -f docker-compose.dev.yml up -d

# 2. Fazer alterações nos arquivos
# (alterações refletidas automaticamente)

# 3. Testar no navegador
# http://localhost:8080

# 4. Quando satisfeito, fazer deploy em produção
./update-container.sh
```

### Para Testes Rápidos

```bash
# 1. Fazer alterações nos arquivos

# 2. Atualização rápida
./quick-update.sh

# 3. Testar no navegador (Ctrl+Shift+R para limpar cache)

# 4. Se OK, persistir alterações
./update-container.sh
```

---

## 🔧 Comandos Docker Úteis

### Gerenciamento de Containers

```bash
# Listar containers em execução
docker ps

# Listar todos os containers
docker ps -a

# Parar container
docker stop guacplayer-caixa

# Iniciar container
docker start guacplayer-caixa

# Reiniciar container
docker restart guacplayer-caixa

# Remover container
docker rm -f guacplayer-caixa
```

### Logs e Debug

```bash
# Ver logs em tempo real
docker logs -f guacplayer-caixa

# Ver últimas 100 linhas
docker logs --tail 100 guacplayer-caixa

# Acessar shell do container
docker exec -it guacplayer-caixa sh

# Verificar arquivos dentro do container
docker exec guacplayer-caixa ls -la /usr/share/nginx/html/
```

### Imagens

```bash
# Listar imagens
docker images

# Remover imagem
docker rmi guacplayer-caixa:latest

# Limpar imagens não utilizadas
docker image prune -a

# Ver histórico da imagem
docker history guacplayer-caixa:latest
```

### Backup e Restore

```bash
# Criar backup da imagem
docker save guacplayer-caixa:latest > guacplayer-backup.tar

# Restaurar backup
docker load < guacplayer-backup.tar

# Criar backup do container
docker commit guacplayer-caixa guacplayer-backup

# Exportar container
docker export guacplayer-caixa > container-backup.tar
```

---

## 🐛 Troubleshooting

### Problema: Script não executa

```bash
# Dar permissão de execução
chmod +x update-container.sh
chmod +x quick-update.sh

# Verificar se o script tem erros
bash -n update-container.sh
```

### Problema: Porta já em uso

```bash
# Verificar o que está usando a porta
netstat -tuln | grep :80

# Ou usar outra porta
PORT=8080 ./update-container.sh
```

### Problema: Container não inicia

```bash
# Ver logs de erro
docker logs guacplayer-caixa

# Verificar se a imagem foi criada
docker images | grep guacplayer

# Tentar iniciar manualmente
docker run -it --rm -p 8080:80 guacplayer-caixa:latest
```

### Problema: Alterações não aparecem

```bash
# 1. Limpar cache do navegador (Ctrl+Shift+R)

# 2. Verificar se os arquivos foram copiados
docker exec guacplayer-caixa cat /usr/share/nginx/html/custom.css

# 3. Reiniciar container
docker restart guacplayer-caixa

# 4. Verificar logs
docker logs guacplayer-caixa
```

---

## 📊 Comparação dos Métodos

| Método | Tempo | Persistência | Complexidade | Uso Recomendado |
|--------|-------|--------------|--------------|-----------------|
| `update-container.sh` | ~2-5 min | ✅ Permanente | Média | Produção |
| `quick-update.sh` | ~10 seg | ❌ Temporária | Baixa | Testes |
| `docker-compose.yml` | ~2-5 min | ✅ Permanente | Baixa | Produção |
| `docker-compose.dev.yml` | ~10 seg | ✅ Permanente | Baixa | Desenvolvimento |

---

## ✅ Checklist de Atualização

Antes de atualizar:
- [ ] Fazer backup do container atual
- [ ] Verificar se há alterações não commitadas
- [ ] Testar em ambiente de desenvolvimento primeiro
- [ ] Avisar usuários sobre a manutenção (se aplicável)

Após atualizar:
- [ ] Verificar se o container está rodando (`docker ps`)
- [ ] Verificar logs (`docker logs guacplayer-caixa`)
- [ ] Testar acesso no navegador
- [ ] Verificar se as cores CAIXA estão aplicadas
- [ ] Verificar se o logo aparece corretamente
- [ ] Testar funcionalidades principais

---

## 📞 Suporte

Para mais informações, consulte:
- **GUIA_ATUALIZACAO_CONTAINER.md** - Guia completo de atualização
- **ALTERACOES_APLICADAS.md** - Documentação das alterações
- **README.md** - Documentação do projeto

---

**Autor:** Wanzeller (IT Consultant)  
**Data:** 28 de Janeiro de 2026  
**Projeto:** GuacPlayer - CAIXA
