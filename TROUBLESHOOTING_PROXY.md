# 🔧 Troubleshooting - Problemas com Proxy

Guia completo para resolver problemas de compilação Maven através de proxy corporativo.

---

## 🚨 Problema Relatado

```
Exception in thread "main" java.io.IOError: java.io.IOException: Pipe quebrado
Caused by: java.io.IOException: Pipe quebrado
```

**Causa:** Maven não consegue baixar dependências através do proxy corporativo.

---

## 🎯 Soluções Disponíveis

### Solução 1: Configurar Proxy no Maven (Recomendado)

Use o script automatizado para configurar o proxy:

```bash
./configure-maven-proxy.sh
```

O script irá:
1. Solicitar informações do proxy (host, porta, usuário, senha)
2. Criar/atualizar o arquivo `~/.m2/settings.xml`
3. Configurar proxy para HTTP e HTTPS
4. Testar a conexão

**Informações necessárias:**
- Host do proxy (ex: `proxy.empresa.com`)
- Porta do proxy (ex: `8080`, `3128`)
- Usuário e senha (se autenticação for necessária)
- Hosts que não devem usar proxy (ex: `localhost,127.0.0.1`)

---

### Solução 2: Usar Build Existente (Sem Maven)

Se você já compilou o projeto antes ou tem o arquivo `.tar.gz`:

```bash
./update-container.sh --skip-maven
```

**Requisitos:**
- Arquivo `target/glyptodon-enterprise-player-1.1.0-1.tar.gz` deve existir

**Vantagens:**
- ✅ Não precisa de Maven
- ✅ Não precisa de acesso à internet
- ✅ Muito mais rápido

**Desvantagens:**
- ❌ Não compila alterações novas no código Java
- ❌ Não minifica CSS/JS novamente

---

### Solução 3: Modo Offline do Maven

Se você já baixou as dependências antes:

```bash
./update-container.sh --offline
```

ou

```bash
mvn clean package -o
```

**Quando usar:**
- Você já compilou o projeto antes nesta máquina
- As dependências já estão em `~/.m2/repository/`
- Proxy está bloqueando novos downloads

---

### Solução 4: Compilar em Outra Máquina

Se nenhuma das soluções acima funcionar:

```bash
# Em uma máquina SEM proxy (ex: sua máquina local):
git clone https://github.com/WanzellerRP/glyptodon-enterprise-player.git
cd glyptodon-enterprise-player
mvn clean package

# Copiar o arquivo gerado para o servidor:
scp target/glyptodon-enterprise-player-1.1.0-1.tar.gz usuario@servidor:/caminho/

# No servidor:
cd glyptodon-enterprise-player
mkdir -p target
mv /caminho/glyptodon-enterprise-player-1.1.0-1.tar.gz target/
./update-container.sh --skip-maven
```

---

## 📋 Configuração Manual do Proxy Maven

Se preferir configurar manualmente, edite `~/.m2/settings.xml`:

```xml
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
      <host>proxy.empresa.com</host>
      <port>8080</port>
      <username>seu_usuario</username>
      <password>sua_senha</password>
      <nonProxyHosts>localhost|127.0.0.1</nonProxyHosts>
    </proxy>
    
    <!-- Proxy HTTPS -->
    <proxy>
      <id>https-proxy</id>
      <active>true</active>
      <protocol>https</protocol>
      <host>proxy.empresa.com</host>
      <port>8080</port>
      <username>seu_usuario</username>
      <password>sua_senha</password>
      <nonProxyHosts>localhost|127.0.0.1</nonProxyHosts>
    </proxy>
  </proxies>
  
</settings>
```

**Substitua:**
- `proxy.empresa.com` → Endereço do seu proxy
- `8080` → Porta do seu proxy
- `seu_usuario` → Seu usuário (se necessário)
- `sua_senha` → Sua senha (se necessário)

---

## 🔍 Diagnóstico de Problemas

### Verificar se o Maven está usando o proxy

```bash
mvn help:system | grep proxy
```

Deve mostrar as configurações de proxy.

### Testar conexão com Maven Central

```bash
curl -I https://repo.maven.apache.org/maven2/
```

**Se funcionar:** Problema é específico do Maven  
**Se não funcionar:** Problema é de rede/proxy

### Verificar configuração do proxy no sistema

```bash
echo $http_proxy
echo $https_proxy
echo $HTTP_PROXY
echo $HTTPS_PROXY
```

Se estiverem configuradas, o Maven pode precisar usar essas variáveis.

### Testar download de dependência específica

```bash
mvn dependency:get -Dartifact=junit:junit:4.12
```

---

## 🐛 Problemas Comuns e Soluções

### Problema 1: "Connection refused"

**Causa:** Host ou porta do proxy incorretos

**Solução:**
```bash
# Verificar proxy do sistema
env | grep -i proxy

# Testar conectividade
telnet proxy.empresa.com 8080
# ou
nc -zv proxy.empresa.com 8080
```

### Problema 2: "407 Proxy Authentication Required"

**Causa:** Credenciais de autenticação incorretas ou ausentes

**Solução:**
1. Verificar usuário e senha
2. Adicionar `<username>` e `<password>` no settings.xml
3. Verificar se a senha tem caracteres especiais (pode precisar escapar)

### Problema 3: "PKIX path building failed" ou "SSL certificate problem"

**Causa:** Certificado SSL do proxy não é confiável

**Solução A - Adicionar certificado (recomendado):**
```bash
# Obter certificado do proxy
openssl s_client -connect proxy.empresa.com:8080 -showcerts

# Adicionar ao keystore do Java
sudo keytool -import -alias proxy-cert -file proxy-cert.pem \
  -keystore $JAVA_HOME/lib/security/cacerts
```

**Solução B - Desabilitar verificação SSL (NÃO recomendado para produção):**
```bash
mvn clean package -Dmaven.wagon.http.ssl.insecure=true \
  -Dmaven.wagon.http.ssl.allowall=true
```

### Problema 4: "Pipe quebrado" (Broken pipe)

**Causa:** Conexão interrompida durante download

**Soluções:**
1. Aumentar timeout do Maven:
```xml
<settings>
  <servers>
    <server>
      <id>central</id>
      <configuration>
        <timeout>60000</timeout>
      </configuration>
    </server>
  </servers>
</settings>
```

2. Usar modo offline se já tiver dependências:
```bash
./update-container.sh --offline
```

3. Pular Maven completamente:
```bash
./update-container.sh --skip-maven
```

### Problema 5: Download muito lento

**Causa:** Proxy lento ou limitação de banda

**Soluções:**
1. Usar mirror Maven mais próximo:
```xml
<mirrors>
  <mirror>
    <id>central-mirror</id>
    <name>Maven Central Mirror</name>
    <url>https://repo.maven.apache.org/maven2</url>
    <mirrorOf>central</mirrorOf>
  </mirror>
</mirrors>
```

2. Compilar em horário de menor uso da rede

3. Compilar em máquina local e transferir build

---

## 🎯 Fluxo de Decisão

```
┌─────────────────────────────────────────────────────────┐
│                                                         │
│  Você tem acesso direto à internet?                    │
│                                                         │
│    SIM ──────────────► ./update-container.sh           │
│     │                                                   │
│    NÃO                                                  │
│     │                                                   │
│     ▼                                                   │
│  Você conhece as configurações do proxy?               │
│                                                         │
│    SIM ──────────────► ./configure-maven-proxy.sh      │
│     │                  Depois: ./update-container.sh   │
│    NÃO                                                  │
│     │                                                   │
│     ▼                                                   │
│  Você já compilou o projeto antes?                     │
│                                                         │
│    SIM ──────────────► ./update-container.sh           │
│                        --skip-maven                     │
│     │                                                   │
│    NÃO                                                  │
│     │                                                   │
│     ▼                                                   │
│  Pode compilar em outra máquina?                       │
│                                                         │
│    SIM ──────────────► Compilar localmente             │
│                        Transferir .tar.gz              │
│                        ./update-container.sh           │
│                        --skip-maven                     │
│     │                                                   │
│    NÃO ──────────────► Contatar TI para               │
│                        configurar proxy                 │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

---

## 📚 Referências e Links Úteis

### Documentação Oficial

- [Maven Proxy Configuration](https://maven.apache.org/guides/mini/guide-proxies.html)
- [Maven Settings Reference](https://maven.apache.org/settings.html)
- [Maven Offline Mode](https://maven.apache.org/plugins/maven-dependency-plugin/examples/using-offline-mode.html)

### Comandos Úteis

```bash
# Verificar versão do Maven
mvn -v

# Listar dependências do projeto
mvn dependency:tree

# Baixar todas as dependências
mvn dependency:go-offline

# Limpar cache do Maven
rm -rf ~/.m2/repository/*

# Ver configurações efetivas do Maven
mvn help:effective-settings

# Ver configurações efetivas do POM
mvn help:effective-pom

# Debug do Maven (verbose)
mvn clean package -X
```

---

## 🆘 Checklist de Troubleshooting

Antes de pedir ajuda, verifique:

- [ ] Proxy está configurado corretamente no `~/.m2/settings.xml`
- [ ] Host e porta do proxy estão corretos
- [ ] Credenciais de autenticação estão corretas (se necessário)
- [ ] Consegue acessar `https://repo.maven.apache.org/maven2/` via navegador
- [ ] Firewall não está bloqueando conexões Maven
- [ ] Certificados SSL estão válidos
- [ ] Tem espaço em disco suficiente (~500MB para dependências)
- [ ] Variáveis de ambiente de proxy não estão conflitando
- [ ] Maven está usando a versão correta do Java (11+)

---

## 💡 Dicas de Prevenção

### 1. Baixar dependências antecipadamente

```bash
# Em uma máquina com internet livre:
mvn dependency:go-offline

# Isso baixa todas as dependências para ~/.m2/repository/
# Depois você pode copiar esse diretório para o servidor
```

### 2. Usar repositório Maven corporativo

Se sua empresa tem um Nexus ou Artifactory:

```xml
<mirrors>
  <mirror>
    <id>nexus</id>
    <name>Nexus Corporativo</name>
    <url>http://nexus.empresa.com/repository/maven-public/</url>
    <mirrorOf>*</mirrorOf>
  </mirror>
</mirrors>
```

### 3. Manter build atualizado

```bash
# Sempre que compilar com sucesso, faça backup do .tar.gz
cp target/glyptodon-enterprise-player-1.1.0-1.tar.gz ~/backup/
```

---

## 📞 Suporte

Se nenhuma das soluções funcionou:

1. **Verifique os logs completos:**
   ```bash
   mvn clean package -X > maven-debug.log 2>&1
   ```

2. **Colete informações do ambiente:**
   ```bash
   mvn -v
   echo $http_proxy
   echo $https_proxy
   cat ~/.m2/settings.xml
   ```

3. **Teste conectividade:**
   ```bash
   curl -v https://repo.maven.apache.org/maven2/
   telnet proxy.empresa.com 8080
   ```

4. **Contate o time de TI** com essas informações

---

## ✅ Resumo das Soluções

| Situação | Solução | Comando |
|----------|---------|---------|
| **Proxy conhecido** | Configurar Maven | `./configure-maven-proxy.sh` |
| **Já compilou antes** | Usar build existente | `./update-container.sh --skip-maven` |
| **Dependências baixadas** | Modo offline | `./update-container.sh --offline` |
| **Sem acesso à internet** | Compilar em outro lugar | Transferir `.tar.gz` |
| **Proxy bloqueando tudo** | Quick update | `./quick-update.sh` |

---

**Autor:** Wanzeller (IT Consultant)  
**Data:** 29 de Janeiro de 2026  
**Projeto:** GuacPlayer - CAIXA  
**Versão:** 1.1.0-CAIXA
