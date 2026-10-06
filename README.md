# LICÀRT

Site da **LICÀRT**, camisas com desenhos feitos à mão.

> Desenhado à mão. Impresso em você.

Cada estampa começa como um traço de pincel e um respingo de nanquim numa folha em branco. O site foi pensado como um caderno de rascunhos de artista: muito papel branco, tinta preta forte e um único respingo de cor.

---

## Visão geral

Loja de página única, feita só com HTML, CSS e JavaScript, sem build e sem dependências. Basta abrir o `index.html` no navegador.

**Seções da página**

| Seção | O que mostra |
| --- | --- |
| Cabeçalho | Logo, menu (Loja, Processo, Sobre) e sacola com contador |
| Abertura | Chamada principal, selo "Drop" e respingo de nanquim gerado em canvas (botão "Respingar de novo") |
| Faixa | Letreiro rolando com os valores da marca |
| As estampas | Grade com 6 camisas, filtro por coleção, escolha de tamanho (P, M, G, GG) e botão "Comprar" |
| Como a arte nasce | As três etapas: rascunho, nanquim, serigrafia |
| Sobre | Manifesto e números da marca |
| Próximo drop | Cadastro de e-mail com validação |
| Rodapé | Contato, Instagram e política de trocas |

## Estrutura

```
.
├── index.html        # o site inteiro (HTML, CSS e JS no mesmo arquivo)
├── licart-logo.png   # logo original (150×150 px)
└── README.md
```

O logo também está embutido no `index.html` em base64, então a página funciona sozinha.

## Como rodar

Abra o arquivo direto no navegador:

```bash
open index.html        # macOS
xdg-open index.html    # Linux
start index.html       # Windows
```

Ou suba um servidor local:

```bash
python3 -m http.server 8000
# acesse http://localhost:8000
```

### Publicar no GitHub Pages

1. Envie o repositório para o GitHub.
2. Vá em **Settings → Pages**.
3. Em **Source**, escolha a branch `main` e a pasta `/ (root)`.
4. O site fica disponível em `https://<seu-usuario>.github.io/<nome-do-repo>/`.

## Design system

O visual segue o design system da LICÀRT. Todos os valores estão como variáveis CSS no `:root` do `index.html`.

### Cores

| Token | Claro | Escuro | Uso |
| --- | --- | --- | --- |
| `--papel` | `#ffffff` | `#0d0d0d` | Fundo da página |
| `--papel-2` | `#f2f0eb` | `#1c1b19` | Cards, faixas, fundo das fotos |
| `--tinta` | `#0d0d0d` | `#f5f3ee` | Texto, logo, botão principal |
| `--tinta-hover` | `#2b2b2b` | `#d9d6cf` | Hover do botão principal |
| `--tinta-suave` | `#5c5a56` | `#a8a59f` | Texto secundário |
| `--linha` | `#d9d6cf` | `#33312e` | Bordas e divisórias |
| `--respingo` | `#d42a1c` | `#ff6a57` | Único acento: no máximo um por tela |
| `--sobre-respingo` | `#ffffff` | `#0d0d0d` | Texto sobre o respingo |

O tema escuro segue a preferência do sistema operacional (`prefers-color-scheme`) e inverte o logo para branco.

### Tipografia

- **Permanent Marker** (display): só em títulos, nomes de estampas e chamadas curtas. Nunca em parágrafos.
- **Archivo** (texto): todo o resto. Pesos 400, 700 e 800.

Ambas vêm do Google Fonts.

| Estilo | Tamanho / altura de linha | Peso |
| --- | --- | --- |
| `display-xl` | 64 / 64 px | 400 |
| `display-lg` | 40 / 44 px | 400 |
| `heading` | 24 / 30 px | 800 |
| `price` | 20 / 24 px | 700 |
| `body` | 16 / 24 px | 400 |
| `body-sm` | 14 / 20 px | 400 |
| `label` | 12 / 16 px, caixa alta, espaçamento 0.08em | 700 |

### Espaçamento e cantos

| Token | Valor | Uso |
| --- | --- | --- |
| `--space-2` | 8px | Ícone e texto, chips de tamanho |
| `--space-4` | 16px | Padding de cards e botões, margem lateral no celular |
| `--space-6` | 24px | Gap da grade de produtos |
| `--space-12` | 48px | Entre seções |
| `--radius-none` | 0px | Padrão: fotos, cards, botões |
| `--radius-sm` | 2px | Campos de formulário e chips |
| `--radius-full` | 9999px | Só para gotas: selos, contador, respingos |

### Regras da marca

- Quase tudo é tinta sobre papel. O vermelho `respingo` aparece no máximo uma vez por tela.
- Cantos retos em tudo; formas redondas só para gotas de tinta.
- Sem gradientes, sem sombras fortes, sem cores fora da paleta.
- Textos diretos, com verbos fortes. Botões são verbos: "Comprar", "Ver a arte", "Escolher tamanho".

## Editando as estampas

Os produtos ficam no array `products`, dentro do `<script>` no fim do `index.html`:

```js
{
  id: 'corvo',          // identificador único
  name: 'CORVO',        // nome em caixa alta
  desc: 'Asas abertas em três pinceladas. Nanquim, madrugada de outubro.',
  price: 139,           // em reais
  tag: 'drop',          // 'drop' ou 'classicos' (usado no filtro)
  seed: 11              // muda o desenho do respingo gerado
}
```

## O que ainda é provisório

- [ ] **Fotos:** as camisas mostram um respingo gerado por código no lugar das fotos reais.
- [ ] **Produtos:** nomes, descrições e preços são exemplos.
- [ ] **Contato:** e-mail e Instagram do rodapé são exemplos.
- [ ] **Logo:** o PNG atual tem 150×150 px. Trocar por SVG ou PNG em alta resolução com fundo transparente.
- [ ] **Sacola:** só conta os itens na tela. Falta integrar com um checkout (Shopify, Nuvemshop, Mercado Pago etc.).
- [ ] **Newsletter:** o formulário só valida o e-mail. Falta ligar a um serviço de e-mail (Mailchimp, Brevo etc.).

## Acessibilidade

- Contraste de texto de pelo menos 4.5:1 nos dois temas.
- Foco visível em todos os controles.
- Animações desligadas quando o sistema pede `prefers-reduced-motion`.
- Layout responsivo, testado a partir de 400px de largura.

---

© 2026 LICÀRT. Todos os direitos reservados. As estampas e o logo são obras originais da marca.
