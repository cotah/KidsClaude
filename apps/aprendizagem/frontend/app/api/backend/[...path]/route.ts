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

// Escolhe qual token enviar. Preferencia para o token de crianca quando
// ambos existem (sessao ativa de play e' mais especifica que sessao do pai).
async function pickToken(): Promise<string | null> {
  const store = await cookies();
  const child = store.get(config.auth.childCookieName)?.value;
  if (child) return child;
  const parent = store.get(config.auth.parentCookieName)?.value;
  return parent ?? null;
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

  const token = await pickToken();
  if (token) headers.set('authorization', `Bearer ${token}`);

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
