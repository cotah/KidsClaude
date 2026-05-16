import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { config } from '@/lib/config';

/**
 * BFF proxy: encaminha chamadas client-side para o backend FastAPI.
 * Le os cookies httpOnly (que JS no browser nao consegue ler) e injeta
 * o header Authorization: Bearer <token>. Necessario porque o apiClient
 * roda em Client Components e nao consegue acessar cookies httpOnly.
 *
 * URL no cliente: /api/backend/v1/<endpoint>
 * Encaminha para: ${BACKEND_URL ou config.api.baseUrl-sem-/v1}/v1/<endpoint>
 */

// Esta rota nunca deve ser cacheada - cada request precisa ler cookies frescos.
export const dynamic = 'force-dynamic';

// Base do backend sem o sufixo /v1 (que vai vir do path do cliente).
function getBackendBase(): string {
  const explicit = process.env.BACKEND_URL;
  if (explicit) return explicit.replace(/\/+$/, '');
  // Fallback: deriva da config publica removendo o /v1 final.
  const fromPublic = config.api.baseUrl.replace(/\/v1\/?$/, '');
  return fromPublic.replace(/\/+$/, '');
}

// Endpoints publicos: NUNCA mandam token (mesmo que cookies existam).
// Evita interferencia entre sessoes em fluxos de signup/login/reset.
const PUBLIC_ENDPOINTS = new Set<string>([
  'v1/auth/parent/login',
  'v1/auth/parent/signup',
  'v1/auth/parent/password-reset/request',
  'v1/auth/parent/password-reset/confirm',
  'v1/auth/child/login-direct',
  'v1/health',
]);

// Endpoints que SEMPRE exigem token de pai. Se enviar child token,
// o backend rejeita 401 e o handleUnauthorized derruba a sessao toda.
function isParentOnlyPath(path: string): boolean {
  return (
    path.startsWith('v1/auth/parent/') ||
    path.startsWith('v1/parents/') ||
    path === 'v1/auth/child/login' // crianca via /select: pai autoriza
  );
}

// Endpoints que SEMPRE sao de crianca (chat, heartbeat, exam).
function isChildOnlyPath(path: string): boolean {
  return (
    path.startsWith('v1/chat/') ||
    path.startsWith('v1/exam/') ||
    path === 'v1/heartbeat'
  );
}

// Para endpoints AnyAuth (children/*, lessons/*, stages, etc.) usamos
// o Referer pra desempate. Pai navegando em /dashboard manda token de
// pai; crianca em /play manda token de crianca. Sem referer claro,
// preferimos PARENT (era child antes - causava bug onde pai com cookie
// residual de crianca recebia 401 em endpoints de pai).
function tokenFromReferer(referer: string | null, parent: string | null, child: string | null): string | null {
  if (!referer) return parent ?? child ?? null;

  let refererPath = '';
  try {
    refererPath = new URL(referer).pathname;
  } catch {
    return parent ?? child ?? null;
  }

  const isParentContext =
    refererPath.startsWith('/dashboard') ||
    refererPath.startsWith('/children') ||
    refererPath.startsWith('/account') ||
    refererPath === '/select' ||
    refererPath.startsWith('/login') ||
    refererPath.startsWith('/signup');

  const isChildContext =
    refererPath.startsWith('/play') ||
    refererPath === '/crianca';

  if (isParentContext) return parent ?? child ?? null;
  if (isChildContext) return child ?? parent ?? null;
  return parent ?? child ?? null;
}

async function pickToken(req: NextRequest, pathSegments: string[]): Promise<string | null> {
  const store = await cookies();
  const child = store.get(config.auth.childCookieName)?.value ?? null;
  const parent = store.get(config.auth.parentCookieName)?.value ?? null;

  const path = pathSegments.join('/');

  if (PUBLIC_ENDPOINTS.has(path)) return null;
  if (isParentOnlyPath(path)) return parent;
  if (isChildOnlyPath(path)) return child;

  // AnyAuth: decide pelo contexto da pagina que fez a request.
  return tokenFromReferer(req.headers.get('referer'), parent, child);
}

async function forward(req: NextRequest, pathSegments: string[]) {
  const backend = getBackendBase();
  const targetPath = pathSegments.map(encodeURIComponent).join('/');
  const search = req.nextUrl.search ?? '';
  const target = `${backend}/${targetPath}${search}`;

  const headers = new Headers();
  const contentType = req.headers.get('content-type');
  if (contentType) headers.set('content-type', contentType);
  const accept = req.headers.get('accept');
  if (accept) headers.set('accept', accept);

  const token = await pickToken(req, pathSegments);
  if (token) headers.set('authorization', `Bearer ${token}`);

  // Propaga locale do cookie pro backend via Accept-Language padrao HTTP.
  // Backend usa pra escolher idioma das respostas do Claude no chat.
  // Default 'en' mirrors i18n/request.ts (decisao de produto).
  const store = await cookies();
  const locale = store.get('locale')?.value === 'pt' ? 'pt' : 'en';
  headers.set('accept-language', locale);

  // Propaga timezone do cookie pro backend via X-Timezone (header
  // custom). Setado pelo TimezoneInit no client-side com Intl. Backend
  // usa pra computar "hoje" no fuso do usuario - sem isso, daily_usage
  // e last_active_date saiam errados pra qualquer usuario fora de
  // America/Sao_Paulo (fallback hardcoded). Sem cookie, backend cai
  // no fallback de settings.timezone.
  const tz = store.get('tz')?.value;
  if (tz) headers.set('x-timezone', tz);

  // Body so para metodos que aceitam payload.
  const init: RequestInit = { method: req.method, headers };
  if (req.method !== 'GET' && req.method !== 'HEAD' && req.method !== 'DELETE') {
    init.body = await req.arrayBuffer();
  }

  let upstream: Response;
  try {
    upstream = await fetch(target, init);
  } catch (err) {
    return NextResponse.json(
      {
        error: {
          code: 'BACKEND_UNREACHABLE',
          message: 'Nao foi possivel conectar ao backend',
        },
      },
      { status: 502 }
    );
  }

  // Repassa corpo + status. Filtra apenas o content-type para evitar problemas
  // com encoding/transfer headers que o Node fetch ja resolveu.
  const body = await upstream.arrayBuffer();
  const respHeaders = new Headers();
  const upstreamCt = upstream.headers.get('content-type');
  if (upstreamCt) respHeaders.set('content-type', upstreamCt);

  return new NextResponse(body, {
    status: upstream.status,
    statusText: upstream.statusText,
    headers: respHeaders,
  });
}

type RouteContext = { params: Promise<{ path: string[] }> };

export async function GET(req: NextRequest, ctx: RouteContext) {
  const { path } = await ctx.params;
  return forward(req, path);
}

export async function POST(req: NextRequest, ctx: RouteContext) {
  const { path } = await ctx.params;
  return forward(req, path);
}

export async function PATCH(req: NextRequest, ctx: RouteContext) {
  const { path } = await ctx.params;
  return forward(req, path);
}

export async function DELETE(req: NextRequest, ctx: RouteContext) {
  const { path } = await ctx.params;
  return forward(req, path);
}

export async function PUT(req: NextRequest, ctx: RouteContext) {
  const { path } = await ctx.params;
  return forward(req, path);
}
