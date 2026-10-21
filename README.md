# LICÀRT

Loja virtual da **LICÀRT**, camisas com estampas feitas à mão.

> Desenhado à mão. Impresso em você.

Cada estampa começa como um traço de pincel e um respingo de nanquim numa folha em branco. O app foi pensado como um caderno de rascunhos de artista: muito papel branco, tinta preta forte e um único respingo de cor.

---

## Visão geral

Aplicativo feito em **Flutter** (compilado para Web), com **Firebase** como backend: autenticação de usuários e catálogo de produtos salvos em tempo real no Firestore.

**O que o app tem hoje**

| Área | O que faz |
| --- | --- |
| Vitrine | Catálogo de estampas com filtro por coleção, escolha de tamanho e carrinho |
| Conta | Criação de conta e login (e-mail/senha) via Firebase Authentication |
| Painel admin | Tela restrita para cadastrar, editar e remover estampas do catálogo |
| Catálogo em tempo real | Produtos ficam no Firestore e atualizam para todo mundo ao vivo quando um admin publica algo novo |

## Stack

- **Flutter** (Dart) — alvo principal: Web
- **Provider** — gerenciamento de estado
- **Firebase Authentication** — contas de cliente e admin
- **Cloud Firestore** — catálogo de produtos e perfis de usuário
- **google_fonts**, **file_picker**, **intl**

## Estrutura

```
lib/
├── main.dart                   # inicializa o Firebase e sobe o app
├── firebase_options.dart       # config gerada pelo FlutterFire CLI
├── models/                     # Product, AppUser, CartItem
├── providers/                  # AuthProvider, ProductProvider, CartProvider
├── theme/                      # AppTheme (cores, tipografia)
├── views/                      # telas: home, login, criar conta, admin...
└── widgets/                    # componentes reutilizáveis (card de produto, header...)
```

## Como rodar

Pré-requisitos: [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e um projeto no [Firebase Console](https://console.firebase.google.com/) com **Authentication** (provedor E-mail/Senha) e **Cloud Firestore** ativados.

```bash
flutter pub get

# gera lib/firebase_options.dart a partir do SEU projeto Firebase
dart pub global activate flutterfire_cli
flutterfire configure

flutter run -d chrome
```

### Build de produção (Web)

```bash
flutter build web --release --base-href /
```

O resultado fica em `build/web/` — é só servir essa pasta como arquivos estáticos em qualquer hospedagem.

## Firebase

**Coleções no Firestore**

| Coleção | Conteúdo |
| --- | --- |
| `products` | Catálogo: nome, descrição, preço, categoria, estoque e até 2 fotos (guardadas em base64 dentro do próprio documento — o projeto não usa Cloud Storage) |
| `users` | Perfil de cada conta: nome, e-mail e a flag `isAdmin` |

**Papel de administrador**

Toda conta nova é criada como cliente comum (`isAdmin: false`). Não existe nenhum fluxo no app para se autopromover — virar admin é feito manualmente no Console do Firebase, editando esse campo no documento da conta em `users/{uid}`. As regras de segurança do Firestore (`firestore.rules`) garantem isso no servidor: só quem tem `isAdmin: true` consegue escrever na coleção `products`; a leitura da vitrine é pública.

## Design system

O visual segue o design system da LICÀRT, definido em `lib/theme/app_theme.dart`.

### Cores

| Token | Valor | Uso |
| --- | --- | --- |
| `papel` | `#FFFFFF` | Fundo da página |
| `papel2` | `#F2F0EB` | Cards, faixas, fundo das fotos |
| `tinta` | `#0D0D0D` | Texto, logo, botão principal |
| `tintaHover` | `#2B2B2B` | Hover do botão principal |
| `tintaSuave` | `#5C5A56` | Texto secundário |
| `linha` | `#D9D6CF` | Bordas e divisórias |
| `respingo` | `#D42A1C` | Único acento de cor: no máximo um por tela |
| `sobreRespingo` | `#FFFFFF` | Texto sobre o respingo |

### Tipografia

- **Permanent Marker** (display): só em títulos, nomes de estampas e chamadas curtas. Nunca em parágrafos.
- **Archivo** (texto): todo o resto.

Ambas vêm do Google Fonts.

### Regras da marca

- Quase tudo é tinta sobre papel. O vermelho `respingo` aparece no máximo uma vez por tela.
- Cantos retos em tudo; formas redondas só para gotas de tinta.
- Sem gradientes, sem sombras fortes, sem cores fora da paleta.
- Textos diretos, com verbos fortes. Botões são verbos: "Comprar", "Ver a coleção", "Criar conta".

## O que ainda é provisório

- **Fotos:** guardadas como base64 dentro do Firestore (sem Cloud Storage), então ficam limitadas a 1–2 fotos bem comprimidas por produto.
- **Carrinho:** vive só na sessão do navegador, não é sincronizado com a conta nem salvo entre dispositivos.
- **Checkout:** a sacola só soma os itens na tela; falta integrar um meio de pagamento de verdade.
- **Newsletter:** o formulário só valida o formato do e-mail; falta ligar a um serviço de e-mail de verdade.

---

© 2026 LICÀRT. Todos os direitos reservados. As estampas e o logo são obras originais da marca.
