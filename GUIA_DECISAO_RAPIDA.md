# ⚡ Guia de Decisão Rápida - Qual Script Usar?

Um guia visual e prático para escolher entre `quick-update.sh` e `update-container.sh`.

---

## 🎯 Decisão em 30 Segundos

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│  Você está em PRODUÇÃO ou precisa de PERSISTÊNCIA?         │
│                                                             │
│         SIM ──────────────────────────► update-container.sh │
│          │                                                  │
│         NÃO                                                 │
│          │                                                  │
│          ▼                                                  │
│  Está apenas TESTANDO mudanças visuais?                    │
│                                                             │
│         SIM ──────────────────────────► quick-update.sh     │
│          │                                                  │
│         NÃO ──────────────────────────► update-container.sh │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔍 Identificação Rápida por Situação

### Situação 1: "Estou ajustando cores CSS"
```
Você: Mudei o azul de #1a237e para #1a247e
      Quero ver se ficou melhor

Use: ./quick-update.sh

Por quê: Você vai testar várias vezes até achar
         a cor perfeita. Quick é ideal para isso.

Depois: Quando encontrar a cor ideal:
        ./update-container.sh (para persistir)
```

### Situação 2: "Vou colocar em produção"
```
Você: Terminei todas as alterações
      Vou fazer deploy no servidor de produção

Use: ./update-container.sh

Por quê: Produção exige persistência e backup.
         Quick não é adequado para produção.

Atenção: Agende para horário de baixo uso
         (há ~30s de downtime)
```

### Situação 3: "Quero testar se o logo ficou bom"
```
Você: Substituí o logo
      Quero ver como ficou na tela

Use: ./quick-update.sh

Por quê: Teste visual rápido, sem compromisso.
         Se não gostar, reverte fácil.

Depois: Se gostar do resultado:
        ./update-container.sh
```

### Situação 4: "Instalação nova do zero"
```
Você: Clonei o repositório
      Vou instalar pela primeira vez

Use: ./update-container.sh

Por quê: Primeira instalação precisa criar
         tudo do zero com build completo.

Nota: Quick só funciona com container existente
```

### Situação 5: "Cliente quer ver uma prévia AGORA"
```
Você: Cliente ligou pedindo para ver
      Preciso mostrar em 2 minutos

Use: ./quick-update.sh

Por quê: 10 segundos vs 5 minutos.
         Quick permite demonstração imediata.

Depois: Após aprovação do cliente:
        ./update-container.sh
```

### Situação 6: "Servidor vai reiniciar amanhã"
```
Você: TI vai reiniciar o servidor amanhã
      Preciso atualizar hoje

Use: ./update-container.sh

Por quê: Quick perde alterações no reinício.
         Update garante persistência.

Atenção: NUNCA use quick se vai reiniciar!
```

---

## 📊 Matriz de Decisão

|  | Desenvolvimento | Homologação | Produção |
|---|---|---|---|
| **Teste inicial** | quick-update.sh | quick-update.sh | ❌ Não teste em prod! |
| **Validação** | quick-update.sh | update-container.sh | update-container.sh |
| **Deploy final** | update-container.sh | update-container.sh | update-container.sh |
| **Correção urgente** | quick-update.sh | update-container.sh | update-container.sh |
| **Iteração rápida** | quick-update.sh | quick-update.sh | ❌ Use homologação |

---

## 🚦 Semáforo de Decisão

### 🟢 SEMPRE use quick-update.sh quando:

- ✅ Está desenvolvendo localmente
- ✅ Quer testar múltiplas variações
- ✅ Precisa de feedback visual imediato
- ✅ Está debugando problemas de CSS
- ✅ Não pode ter downtime
- ✅ Vai reverter as mudanças depois

### 🟡 PODE usar quick-update.sh quando:

- ⚠️ Está em ambiente de homologação (mas prefira update)
- ⚠️ Precisa de demonstração rápida (mas persista depois)
- ⚠️ Está validando correção urgente (mas faça update logo)

### 🔴 NUNCA use quick-update.sh quando:

- ❌ Está em produção
- ❌ Servidor vai reiniciar em breve
- ❌ Precisa de persistência garantida
- ❌ Vai escalar para múltiplos containers
- ❌ Precisa de versionamento
- ❌ Precisa de backup

### 🟢 SEMPRE use update-container.sh quando:

- ✅ Vai fazer deploy em produção
- ✅ Quer persistir alterações
- ✅ Precisa de backup automático
- ✅ Vai versionar a imagem
- ✅ Finalizou o desenvolvimento
- ✅ Primeira instalação

### 🟡 PODE usar update-container.sh quando:

- ⚠️ Está desenvolvendo (mas é mais lento que quick)
- ⚠️ Quer testar o build completo

### 🔴 EVITE update-container.sh quando:

- ⚠️ Está iterando rapidamente (use quick primeiro)
- ⚠️ Não pode ter downtime (use quick para teste)
- ⚠️ Não tem Maven instalado (mas pode pular build)

---

## 🎬 Cenários Práticos Passo a Passo

### Cenário A: Desenvolvimento de Nova Feature

```bash
# Dia 1 - Desenvolvimento
vim src/main/webapp/custom.css
./quick-update.sh          # Teste 1
# Ajustar...
./quick-update.sh          # Teste 2
# Ajustar...
./quick-update.sh          # Teste 3
# Ajustar...
./quick-update.sh          # Teste 4

# Dia 2 - Finalização
./quick-update.sh          # Teste final
# Está perfeito!
./update-container.sh      # Persistir
git commit -m "feat: Nova feature"
git push
```

**Por que assim?**
- Quick para iterações rápidas durante desenvolvimento
- Update no final para persistir tudo
- Economiza tempo (4 testes em 40s vs 20 minutos)

### Cenário B: Correção Urgente em Produção

```bash
# 1. Identificar problema
# "O botão está com cor errada!"

# 2. Corrigir localmente
vim src/main/webapp/modules/app/styles/app.css

# 3. Testar em DEV
./quick-update.sh
# Verificar no navegador
# OK, corrigido!

# 4. Deploy em PROD
./update-container.sh
# Aguardar 2-5 minutos
# Verificar em produção
# Problema resolvido!

# 5. Commit
git add .
git commit -m "fix: Corrigir cor do botão"
git push
```

**Por que assim?**
- Quick em DEV para validar rapidamente
- Update em PROD para garantir persistência
- Minimiza risco de erro em produção

### Cenário C: Atualização Planejada de Versão

```bash
# Sexta-feira 18h (baixo uso)

# 1. Backup manual
docker commit guacplayer-caixa backup-antes-update

# 2. Atualizar código
git pull origin master

# 3. Testar em DEV primeiro
./quick-update.sh
# Navegar pela aplicação
# Testar funcionalidades
# Tudo OK!

# 4. Deploy em PROD
./update-container.sh
# Aguardar conclusão

# 5. Verificar
docker ps
docker logs -f guacplayer-caixa
# Testar no navegador
# Tudo funcionando!

# 6. Monitorar por 30 minutos
# Se tudo OK, fim!
# Se houver problema:
docker stop guacplayer-caixa
docker rm guacplayer-caixa
docker run -d --name guacplayer-caixa backup-antes-update
```

**Por que assim?**
- Backup manual como segurança extra
- Quick em DEV para pré-validação
- Update em PROD para deploy oficial
- Plano de rollback preparado

### Cenário D: Cliente Quer Ver Prévia

```bash
# Cliente: "Pode mostrar como ficou o novo layout?"
# Você: "Claro, 2 minutos!"

# 1. Aplicar alterações
./quick-update.sh
# 10 segundos

# 2. Compartilhar tela
# Cliente vê as alterações

# Cliente: "Ficou ótimo! Pode publicar?"
# Você: "Sim, vou publicar agora"

# 3. Persistir e publicar
./update-container.sh
# 5 minutos

# Cliente: "Perfeito!"
```

**Por que assim?**
- Quick permite demonstração imediata
- Update garante que vai para produção corretamente
- Cliente satisfeito com agilidade

---

## 🎓 Regras de Ouro

### Regra #1: Quick é Temporário
```
Se você usar quick-update.sh,
SEMPRE execute update-container.sh depois
(quando estiver satisfeito com o resultado)
```

### Regra #2: Produção Exige Update
```
NUNCA use quick-update.sh em produção
e esqueça de fazer update-container.sh
```

### Regra #3: Desenvolvimento Prefere Quick
```
Durante desenvolvimento ativo,
use quick-update.sh para iterar rapidamente
```

### Regra #4: Downtime Requer Planejamento
```
update-container.sh causa ~30s de downtime
Agende para horário de baixo uso
```

### Regra #5: Backup é Essencial
```
Antes de update-container.sh em produção,
SEMPRE faça backup manual
```

---

## 📝 Checklist Antes de Executar

### Antes de `quick-update.sh`:

- [ ] Container está rodando?
- [ ] É ambiente de desenvolvimento/teste?
- [ ] Não preciso de persistência agora?
- [ ] Vou fazer update-container.sh depois?

### Antes de `update-container.sh`:

- [ ] Fiz backup do container atual?
- [ ] Posso ter ~30s de downtime?
- [ ] Código está commitado no Git?
- [ ] Testei as alterações antes?
- [ ] Avisei usuários (se produção)?

---

## 🆘 Perguntas Frequentes

### "Posso usar quick em produção só uma vez?"

**Não recomendado!** Mesmo "só uma vez" pode causar problemas:
- Se o servidor reiniciar, você perde tudo
- Outros admins não saberão das mudanças
- Não há backup das alterações
- Não é reproduzível

**Alternativa:** Se é urgente:
1. Use quick para validar
2. Imediatamente faça update
3. Total: 15 segundos + 5 minutos = 5min15s

### "Quick é mais rápido, por que não usar sempre?"

Porque quick não persiste! É como:
- Escrever em papel vs salvar no computador
- Anotar no quadro branco vs documentar
- Testar vs publicar

Quick é para **testar**, update é para **publicar**.

### "Posso pular o Maven no update-container.sh?"

Sim! Se não tem Maven instalado, o script detecta e usa o build existente. Mas você perde:
- Minificação de JS/CSS
- Otimizações
- Templates atualizados

### "E se eu esquecer de fazer update depois do quick?"

**Problema:** Próximo restart do container = perde tudo!

**Solução preventiva:**
```bash
# Crie um lembrete visual
echo "#!/bin/bash" > quick-update.sh
echo "echo '⚠️  LEMBRE-SE: Execute update-container.sh depois!'" >> quick-update.sh
echo "# ... resto do script" >> quick-update.sh
```

### "Qual é mais seguro?"

**update-container.sh** é mais seguro porque:
- ✅ Faz backup automático
- ✅ Cria imagem versionada
- ✅ Persistente e reproduzível
- ✅ Pode reverter facilmente

**quick-update.sh** é menos seguro porque:
- ❌ Sem backup
- ❌ Alterações voláteis
- ❌ Pode ser esquecido
- ❌ Difícil de reverter

---

## 🎯 Resumo Ultra-Rápido

```
┌─────────────────────────────────────────────────┐
│                                                 │
│  TESTANDO?          → quick-update.sh           │
│  PUBLICANDO?        → update-container.sh       │
│                                                 │
│  DESENVOLVIMENTO?   → quick-update.sh           │
│  PRODUÇÃO?          → update-container.sh       │
│                                                 │
│  RÁPIDO?            → quick-update.sh           │
│  PERSISTENTE?       → update-container.sh       │
│                                                 │
│  SEM DOWNTIME?      → quick-update.sh           │
│  COM BACKUP?        → update-container.sh       │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## 💡 Dica Final

**Crie um workflow pessoal:**

```bash
# Seu workflow de desenvolvimento
alias dev-test='./quick-update.sh'
alias dev-publish='./update-container.sh'

# Durante o dia
dev-test  # Múltiplas vezes

# Fim do dia
dev-publish  # Uma vez

# Commit
git add . && git commit -m "..." && git push
```

Assim você:
- ✅ Itera rapidamente durante o dia
- ✅ Persiste no final do dia
- ✅ Nunca esquece de fazer update
- ✅ Mantém Git sincronizado

---

**Lembre-se:**
> Quick é para **testar**, Update é para **publicar**!

---

**Autor:** Wanzeller (IT Consultant)  
**Data:** 28 de Janeiro de 2026  
**Projeto:** GuacPlayer - CAIXA
