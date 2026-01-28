# Análise do Padrão de Cores - GuacPlayer CAIXA

## Cores Identificadas no teste.html

### Variáveis CSS Principais
```css
--cor-primaria-escura: #1a237e;  /* Azul Escuro CAIXA */
--cor-secundaria-clara: #f0f4f8; /* Fundo levemente cinza */
--cor-texto: #333;
--cor-sucesso: #28a745;
--cor-alerta: #FF8200;           /* Laranja institucional */
```

### Cores Adicionais do caixa-theme.css
```css
--caixa-azul: #004F9F;
--caixa-azul-escuro: #164194;
--caixa-laranja: #EF7D00;
--caixa-cinza: #F5F6F8;
```

## Padrão Visual Identificado

### Tipografia
- Fonte principal: **Poppins** (300, 400, 600, 700)
- Fonte alternativa: Open Sans, Mulish, system-ui

### Elementos de Design
- **Border-radius**: 8px a 12px (elementos arredondados)
- **Box-shadow**: `0 8px 24px rgba(0,0,0,0.1)` para cards
- **Transições**: 0.3s para efeitos hover
- **Bordas**: `1px solid #c5cae9` com foco em `rgba(26, 35, 126, 0.1)`

### Componentes Principais
1. **Header**: Fundo azul escuro (#1a237e), logo CAIXA, título branco
2. **Cards/Dialogs**: Fundo branco, bordas arredondadas, sombra suave
3. **Botões**: Azul escuro com hover mais escuro (#0d1642)
4. **Campos de Input**: Borda cinza clara (#c5cae9), foco azul
5. **Avisos**: Fundo laranja claro (#fff3e0), borda laranja (#FF8200)

## Imagens Disponíveis
- `CAIXA_elemento_cor_chapado_positivo.png` (51KB) - Logo CAIXA para header
- `logo-caixa.png` (5.4KB) - Logo alternativo

## Aplicação Recomendada
Aplicar este padrão aos seguintes arquivos:
- `/src/main/webapp/modules/app/styles/app.css`
- `/src/main/webapp/modules/app/styles/welcome.css`
- `/src/main/webapp/index.html`
- Outros arquivos CSS de módulos
