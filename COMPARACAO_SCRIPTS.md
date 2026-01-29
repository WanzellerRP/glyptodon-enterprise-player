# 🔄 Comparação Detalhada: quick-update.sh vs update-container.sh

Este documento explica em detalhes as diferenças entre os dois scripts de atualização e quando usar cada um.

---

## 📊 Visão Geral Comparativa

| Característica | quick-update.sh | update-container.sh |
|----------------|-----------------|---------------------|
| **Tempo de execução** | ~10 segundos | ~2-5 minutos |
| **Persistência** | ❌ Temporária | ✅ Permanente |
| **Requer Maven** | ❌ Não | ⚠️ Opcional |
| **Requer rebuild** | ❌ Não | ✅ Sim |
| **Backup automático** | ❌ Não | ✅ Sim |
| **Downtime** | ❌ Zero | ✅ Sim (~30s) |
| **Ideal para** | Testes rápidos | Produção |
| **Complexidade** | Baixa | Média |

---

## 🚀 quick-update.sh - Atualização Rápida

### O que faz?

O `quick-update.sh` copia os arquivos modificados **diretamente** para dentro do container em execução, sem parar ou recriar o container.

### Como funciona?

```bash
# 1. Verifica se o container está rodando
docker ps | grep guacplayer-caixa

# 2. Cria diretórios necessários (se não existirem)
docker exec guacplayer-caixa mkdir -p /usr/share/nginx/html/assets/img

# 3. Copia arquivos modificados para o container
docker cp src/main/webapp/custom.css guacplayer-caixa:/usr/share/nginx/html/custom.css
docker cp src/main/webapp/index.html guacplayer-caixa:/usr/share/nginx/html/index.html
# ... e assim por diante para todos os arquivos

# 4. Recarrega o Nginx (opcional)
docker exec guacplayer-caixa nginx -s reload
```

### Fluxo de Execução

```
┌─────────────────────────────────────────────────────────────┐
│                    quick-update.sh                          │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Container está rodando?│
              └────────────┬───────────┘
                           │ Sim
                           ▼
              ┌────────────────────────┐
              │ Criar diretórios       │
              │ (se necessário)        │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Copiar arquivos CSS    │
              │ diretamente no         │
              │ container              │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Copiar index.html      │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Copiar imagens CAIXA   │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Substituir logo antigo │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Recarregar Nginx       │
              └────────────┬───────────┘
                           │
                           ▼
                    ✅ CONCLUÍDO
              (Container continua rodando)
```

### ✅ Vantagens

1. **Extremamente rápido** - Leva apenas 10 segundos
2. **Zero downtime** - Container continua rodando durante a atualização
3. **Não requer Maven** - Não precisa compilar o projeto
4. **Ideal para testes** - Perfeito para validar mudanças visuais rapidamente
5. **Reversível** - Basta reiniciar o container para voltar ao estado anterior

### ❌ Desvantagens

1. **Alterações temporárias** - Perdidas se o container for recriado
2. **Não atualiza a imagem Docker** - A imagem original permanece inalterada
3. **Sem backup** - Não faz backup do estado anterior
4. **Requer container rodando** - Não funciona se o container não existir
5. **Não adequado para produção** - Apenas para testes e desenvolvimento

### ⚠️ IMPORTANTE: Quando NÃO usar

- ❌ Em ambiente de produção (alterações serão perdidas)
- ❌ Quando precisar garantir persistência
- ❌ Antes de reiniciar/recriar o container
- ❌ Em ambientes com múltiplos containers (não escala)

---

## 🏗️ update-container.sh - Atualização Completa

### O que faz?

O `update-container.sh` faz um **rebuild completo** da imagem Docker, garantindo que todas as alterações sejam permanentes e estejam na imagem.

### Como funciona?

```bash
# 1. Faz backup do container atual
docker commit guacplayer-caixa guacplayer-caixa-backup-20260128

# 2. Atualiza código do GitHub
git pull origin master

# 3. Compila o projeto com Maven (se disponível)
mvn clean package

# 4. Extrai o build
tar -xzf target/glyptodon-enterprise-player-1.1.0-1.tar.gz

# 5. Substitui logo antigo pelo logo CAIXA
cp assets/img/logo-caixa.png images/glen-icon-small.png

# 6. Para e remove o container antigo
docker stop guacplayer-caixa
docker rm guacplayer-caixa

# 7. Reconstrói a imagem Docker
docker build -t guacplayer-caixa:latest .

# 8. Cria e inicia novo container
docker run -d --name guacplayer-caixa -p 80:80 guacplayer-caixa:latest
```

### Fluxo de Execução

```
┌─────────────────────────────────────────────────────────────┐
│                   update-container.sh                       │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Verificar Docker/Git   │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Fazer BACKUP do        │
              │ container atual        │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ git pull origin master │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ mvn clean package      │
              │ (compilar projeto)     │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Extrair build          │
              │ (tar.gz)               │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Substituir logo CAIXA  │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ PARAR container antigo │
              │ (downtime inicia)      │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Remover container      │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ docker build           │
              │ (criar nova imagem)    │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ docker run             │
              │ (novo container)       │
              └────────────┬───────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Verificar status       │
              └────────────┬───────────┘
                           │
                           ▼
                    ✅ CONCLUÍDO
           (Nova imagem + novo container)
```

### ✅ Vantagens

1. **Alterações permanentes** - Gravadas na imagem Docker
2. **Backup automático** - Cria backup antes de atualizar
3. **Atualização completa** - Inclui todas as dependências e otimizações
4. **Produção-ready** - Adequado para ambientes de produção
5. **Versionamento** - Cria imagens versionadas
6. **Reproduzível** - Pode recriar o container a qualquer momento
7. **Escalável** - Imagem pode ser usada em múltiplos containers

### ❌ Desvantagens

1. **Mais lento** - Leva 2-5 minutos para completar
2. **Downtime** - Container fica fora do ar por ~30 segundos
3. **Requer Maven** - Precisa compilar (ou pular com build pré-existente)
4. **Mais complexo** - Mais etapas e possíveis pontos de falha
5. **Consome mais recursos** - Build Maven + Docker build

---

## 🎯 Quando Usar Cada Script?

### Use `quick-update.sh` quando:

✅ **Desenvolvimento ativo**
```bash
# Você está ajustando cores CSS e quer ver o resultado imediatamente
./quick-update.sh
# Recarrega navegador (Ctrl+Shift+R)
# Vê as mudanças em 10 segundos
```

✅ **Testes rápidos**
```bash
# Quer testar se uma mudança visual ficou boa
./quick-update.sh
# Se não gostar, basta reverter o arquivo e rodar novamente
```

✅ **Debug de problemas visuais**
```bash
# Identificou um problema no CSS e quer testar a correção
./quick-update.sh
# Valida a correção instantaneamente
```

✅ **Demonstrações**
```bash
# Precisa mostrar uma alteração para o cliente rapidamente
./quick-update.sh
# Apresenta em segundos
```

### Use `update-container.sh` quando:

✅ **Deploy em produção**
```bash
# Vai colocar as alterações em produção
./update-container.sh
# Garante que tudo está persistido e versionado
```

✅ **Finalizar desenvolvimento**
```bash
# Terminou os testes com quick-update.sh e quer persistir
./update-container.sh
# Cria imagem final com todas as alterações
```

✅ **Primeira instalação**
```bash
# Instalando o GuacPlayer pela primeira vez
./update-container.sh
# Cria tudo do zero
```

✅ **Atualização de versão**
```bash
# Nova versão do projeto no GitHub
git pull origin master
./update-container.sh
# Atualiza tudo completamente
```

✅ **Backup e versionamento**
```bash
# Quer criar um snapshot do estado atual
./update-container.sh
# Cria backup automático antes de atualizar
```

---

## 🔄 Fluxo de Trabalho Recomendado

### Cenário 1: Desenvolvimento de Nova Feature Visual

```bash
# 1. Fazer alterações nos arquivos CSS/HTML
vim src/main/webapp/custom.css

# 2. Testar rapidamente (múltiplas vezes)
./quick-update.sh  # Teste 1
# Ajustar código...
./quick-update.sh  # Teste 2
# Ajustar código...
./quick-update.sh  # Teste 3

# 3. Quando estiver satisfeito, persistir
./update-container.sh

# 4. Commit no Git
git add .
git commit -m "feat: Nova feature visual"
git push origin master
```

### Cenário 2: Correção Urgente em Produção

```bash
# 1. Identificar o problema
# 2. Fazer correção no código
# 3. Testar localmente com quick-update
./quick-update.sh

# 4. Se OK, fazer deploy completo
./update-container.sh

# 5. Verificar em produção
docker logs -f guacplayer-caixa
```

### Cenário 3: Atualização de Produção Planejada

```bash
# 1. Atualizar código do GitHub
git pull origin master

# 2. Testar em ambiente de desenvolvimento
./quick-update.sh  # Validação rápida

# 3. Se OK, fazer deploy completo
./update-container.sh

# 4. Monitorar
docker ps
docker logs -f guacplayer-caixa
```

---

## 📈 Comparação de Performance

### Tempo de Execução

```
quick-update.sh:
├─ Verificações:        1s
├─ Criar diretórios:    1s
├─ Copiar arquivos:     5s
├─ Recarregar Nginx:    1s
└─ TOTAL:              ~8-10s

update-container.sh:
├─ Verificações:        2s
├─ Backup:              5s
├─ Git pull:            3s
├─ Maven build:        60s  ← Maior parte do tempo
├─ Extrair build:       5s
├─ Parar container:     3s
├─ Docker build:       30s
├─ Iniciar container:   5s
└─ TOTAL:            ~113s (2-5 minutos)
```

### Downtime

```
quick-update.sh:
└─ Downtime: 0s (container continua rodando)

update-container.sh:
└─ Downtime: ~30-40s (entre parar e iniciar novo container)
```

---

## 🔍 Análise Técnica Detalhada

### quick-update.sh - Internamente

```bash
# O que acontece por baixo dos panos:

# 1. docker cp copia arquivos do host para o container
#    - Usa API do Docker
#    - Não reinicia processos
#    - Arquivos sobrescrevem os existentes

# 2. Nginx continua servindo os arquivos
#    - Cache do navegador pode interferir
#    - Por isso é importante: Ctrl+Shift+R

# 3. Arquivos ficam na camada "writable" do container
#    - Não afeta a imagem Docker original
#    - Perdidos ao recriar o container
```

### update-container.sh - Internamente

```bash
# O que acontece por baixo dos panos:

# 1. Maven compila e otimiza:
#    - Minifica JavaScript e CSS
#    - Gera templates AngularJS
#    - Empacota dependências
#    - Cria arquivo .tar.gz

# 2. Docker build cria camadas:
#    Layer 1: nginx:1.25-alpine (base)
#    Layer 2: COPY arquivos compilados
#    Layer 3: EXPOSE porta 80
#    └─ Resultado: Nova imagem imutável

# 3. docker run cria container da imagem:
#    - Container é instância da imagem
#    - Pode criar quantos containers quiser
#    - Todos idênticos (reproduzível)
```

---

## 🎓 Analogia para Entender Melhor

### quick-update.sh = Editar documento com caneta

- ✅ Rápido e direto
- ✅ Vê o resultado imediatamente
- ❌ Não pode desfazer facilmente
- ❌ Se perder o papel, perde as anotações

### update-container.sh = Editar e salvar no computador

- ✅ Mudanças salvas permanentemente
- ✅ Pode fazer backup
- ✅ Pode recuperar depois
- ❌ Leva mais tempo para salvar

---

## 📋 Checklist de Decisão

Use este checklist para decidir qual script usar:

```
┌─────────────────────────────────────────────────────┐
│          QUAL SCRIPT DEVO USAR?                     │
└─────────────────────────────────────────────────────┘

Responda as perguntas:

1. É ambiente de produção?
   └─ SIM → update-container.sh
   └─ NÃO → Continue

2. Precisa que as alterações sejam permanentes?
   └─ SIM → update-container.sh
   └─ NÃO → Continue

3. Vai reiniciar/recriar o container em breve?
   └─ SIM → update-container.sh
   └─ NÃO → Continue

4. Está apenas testando mudanças visuais?
   └─ SIM → quick-update.sh
   └─ NÃO → update-container.sh

5. Precisa de velocidade máxima?
   └─ SIM → quick-update.sh
   └─ NÃO → update-container.sh

6. Pode ter downtime de 30 segundos?
   └─ NÃO → quick-update.sh
   └─ SIM → update-container.sh
```

---

## 💡 Dicas Práticas

### Para Desenvolvimento

```bash
# Crie um alias para agilizar
echo "alias qup='./quick-update.sh'" >> ~/.bashrc
echo "alias fup='./update-container.sh'" >> ~/.bashrc
source ~/.bashrc

# Agora pode usar:
qup  # Quick update
fup  # Full update
```

### Para Produção

```bash
# Sempre faça backup manual antes
docker commit guacplayer-caixa guacplayer-backup-$(date +%Y%m%d)

# Depois execute
./update-container.sh

# Se algo der errado, restaure:
docker stop guacplayer-caixa
docker rm guacplayer-caixa
docker run -d --name guacplayer-caixa -p 80:80 guacplayer-backup-20260128
```

### Para Testes A/B

```bash
# Teste versão A (quick)
./quick-update.sh
# Mostre para usuários, colete feedback

# Se não gostar, reverta:
docker restart guacplayer-caixa  # Volta ao estado da imagem

# Se gostar, persista:
./update-container.sh
```

---

## 🚨 Avisos Importantes

### ⚠️ quick-update.sh

```
NUNCA use quick-update.sh em produção e esqueça!

Cenário perigoso:
1. Você usa quick-update.sh em produção
2. Funciona perfeitamente
3. Semanas depois, o servidor reinicia
4. Container é recriado da imagem antiga
5. Todas as alterações DESAPARECEM! 😱

Solução:
Sempre execute update-container.sh depois de validar
com quick-update.sh
```

### ⚠️ update-container.sh

```
ATENÇÃO ao downtime!

Durante a execução:
- Container antigo é parado (~30s de downtime)
- Usuários não conseguem acessar
- Conexões ativas são perdidas

Solução:
- Agende para horário de baixo uso
- Avise usuários com antecedência
- Ou use estratégia blue-green deployment
```

---

## 📚 Resumo Executivo

| Aspecto | quick-update.sh | update-container.sh |
|---------|-----------------|---------------------|
| **Velocidade** | ⚡⚡⚡⚡⚡ Muito rápido | ⚡⚡⚡ Moderado |
| **Persistência** | ❌ Temporária | ✅ Permanente |
| **Segurança** | ⚠️ Baixa | ✅ Alta |
| **Backup** | ❌ Não | ✅ Sim |
| **Downtime** | ✅ Zero | ❌ ~30s |
| **Produção** | ❌ Não recomendado | ✅ Recomendado |
| **Desenvolvimento** | ✅ Ideal | ⚠️ Excessivo |
| **Complexidade** | ⭐ Simples | ⭐⭐⭐ Moderada |

---

## 🎯 Conclusão

**Use `quick-update.sh` para:**
- 🔬 Desenvolvimento e testes
- ⚡ Validações rápidas
- 🎨 Ajustes visuais iterativos
- 🐛 Debug de problemas

**Use `update-container.sh` para:**
- 🚀 Deploy em produção
- 💾 Persistir alterações
- 📦 Criar versões
- 🔒 Garantir estabilidade

**Fluxo ideal:**
```
Desenvolvimento → quick-update.sh (múltiplas vezes)
     ↓
Validação OK → update-container.sh (uma vez)
     ↓
Produção → Monitorar e manter
```

---

**Autor:** Wanzeller (IT Consultant)  
**Data:** 28 de Janeiro de 2026  
**Projeto:** GuacPlayer - CAIXA  
**Versão:** 1.1.0-CAIXA
