# Aprendizagem Frontend

Interface frontend para o app educacional que ensina crianças e adolescentes de 6 a 18 anos a usar assistentes de IA de forma segura e divertida.

## 🚀 Tecnologias

- **Next.js 16** com App Router
- **TypeScript** para type safety
- **Tailwind CSS** com design system customizado para crianças
- **Zustand** para gerenciamento de estado
- **TanStack Query** para data fetching
- **React Hook Form + Zod** para formulários e validação
- **Framer Motion** para animações
- **Radix UI** para componentes acessíveis

## 🎨 Design System

### Paleta de Cores Kid-Friendly
- **Sunny** (amarelo): Primária, elementos alegres
- **Ocean** (azul): Secundária, elementos informativos
- **Mint** (verde): Sucesso, aprovação
- **Sunset** (laranja): Atenção, streaks
- **Grape** (roxo): Especial, conquistas

### Tipografia
- Fonte: **Nunito** (arredondada e legível)
- Escalas específicas por idade:
  - 6-8 anos: fontes ≥18px, botões ≥56px
  - 9-18 anos: fontes ≥16px, botões ≥48px

### Componentes Especializados
- **KidCard**: Cards coloridos com hover animado
- **MascotBubble**: Balões de fala do mascote
- **XPProgress**: Barras de progresso gamificadas
- **AvatarPicker**: Seleção de avatares

## 🏗️ Estrutura do Projeto

```
app/
├── (auth)/              # Rotas de autenticação
│   ├── login/
│   └── signup/
├── (parent)/            # Rotas dos pais
│   ├── dashboard/
│   ├── children/
│   └── account/
├── (child)/             # Rotas das crianças
│   └── play/
├── select/              # Seleção de perfil
└── layout.tsx

components/
├── ui/                  # Componentes primitivos
├── providers/           # Providers (React Query, etc)
├── avatar-picker.tsx    # Seleção de avatares
└── ...

lib/
├── api/                 # Cliente API
├── store/               # Zustand stores
├── mock/                # Dados mock para dev
├── config.ts            # Configuração
└── utils.ts             # Utilitários

types/
├── api.ts               # Tipos da API
└── app.ts               # Tipos específicos do app
```

## 🌍 Variáveis de Ambiente

Copie `.env.example` para `.env.local` e configure:

```bash
# API Configuration
NEXT_PUBLIC_API_BASE_URL=https://api.aprendizagem.app/v1
NEXT_PUBLIC_APP_URL=https://aprendizagem.app

# Supabase (para redirects OAuth dos pais)
NEXT_PUBLIC_SUPABASE_URL=https://xxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOi...

# Development
NEXT_PUBLIC_USE_MOCKS=false
NEXT_PUBLIC_DEBUG=false

# Analytics
SENTRY_DSN=https://...@sentry.io/123
```

## 🚀 Desenvolvimento

```bash
# Instalar dependências
npm install

# Desenvolvimento
npm run dev

# Build
npm run build

# Testes
npm run test
npm run test:e2e

# Type checking
npm run type-check

# Lint
npm run lint
```

## 🔒 Segurança

### Autenticação
- **Pais**: Cookie httpOnly com JWT do Supabase
- **Crianças**: Cookie httpOnly com JWT interno (4h TTL)
- Middleware separa acesso por tipo de usuário

### Proteções
- Frontend **NUNCA** chama Anthropic diretamente
- Frontend **NUNCA** chama Supabase diretamente (exceto auth redirects)
- CSP configurado para bloquear scripts externos
- Sanitização de inputs de crianças

## 🎮 UX por Faixa Etária

### 6-8 Anos
- Textos mínimos, ícones grandes
- Botões ≥56px, fontes ≥18px
- Chat apenas com botões de prompt fechado
- Mascote sempre visível
- Animações mais lentas

### 9-12 Anos
- Interface mais densa
- Slots editáveis no chat (validados)
- Ranking e competição sutil
- Textos explicativos

### Pais
- Interface adulta, densa de informação
- Tables, charts, filtros por data
- Acesso total a transcrições
- Controles de segurança e limite

## 🧪 Testes

### Unitários (Vitest)
```bash
npm run test
```

### E2E (Playwright)
```bash
npm run test:e2e
```

### Casos Críticos
- Criança não pode acessar rotas de pai
- Pai não pode iniciar sessão de criança sem escolher perfil
- Chat bloqueado mostra mensagem amigável
- XP animations funcionam corretamente

## 📱 Responsividade

- Mobile-first design
- Breakpoints: sm(640px), md(768px), lg(1024px), xl(1280px)
- Touch targets ≥44px (iOS guidelines)
- Testes em dispositivos reais recomendados

## 🎯 Acessibilidade

- WCAG AA compliance
- Navegação por teclado completa
- Focus rings visíveis
- Alto contraste de cores
- Screen reader friendly
- Labels apropriados em formulários

## 🚢 Deploy

### Vercel (recomendado)
```bash
# Conectar ao projeto Vercel
vercel link

# Deploy
vercel --prod
```

### Env vars necessárias no Vercel:
- `NEXT_PUBLIC_API_BASE_URL`
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- `SENTRY_DSN` (opcional)

## 🐛 Debug

### Modo Development
- React Query Devtools habilitado
- Console logs detalhados
- Mock data disponível via `NEXT_PUBLIC_USE_MOCKS=true`

### Logs importantes
- Erros de API com contexto
- Tentativas de auth falhadas
- Violations de segurança

## 📊 Performance

### Otimizações aplicadas
- Tree shaking automático
- Code splitting por rota
- Image optimization (Next.js)
- Font optimization (Google Fonts)
- Bundle analysis disponível

### Métricas alvo
- FCP < 2s
- LCP < 3s
- TTI < 4s
- CLS < 0.1

## 🤝 Integração com Backend

### Contratos da API
- Base URL: `process.env.NEXT_PUBLIC_API_BASE_URL`
- Auth: Header `Authorization: Bearer <token>`
- Errors: Formato padronizado `{ error: { code, message, details } }`

### Expectativas
- Backend em `${NEXT_PUBLIC_API_URL}/v1`
- Cookies `Set-Cookie` para sessão de pai
- SSE para chat streaming
- Rate limiting em 60 req/min por IP

## 🔧 Troubleshooting

### Problemas comuns
1. **Middleware redirect loop**: Verificar tokens nos cookies
2. **API calls falhando**: Verificar `NEXT_PUBLIC_API_BASE_URL`
3. **Styles quebrados**: Verificar Tailwind build
4. **TypeScript errors**: Rodar `npm run type-check`

### Logs de debug
```bash
# Habilitar logs debug
NEXT_PUBLIC_DEBUG=true npm run dev
```

---

Desenvolvido com ❤️ para ensinar crianças sobre IA de forma segura e divertida.