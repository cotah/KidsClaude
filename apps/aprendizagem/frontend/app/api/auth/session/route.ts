import { NextRequest, NextResponse } from 'next/server';
import { config } from '@/lib/config';

/**
 * Route handler para gerenciar sessoes de auth via httpOnly cookies.
 *   POST   - cria nova sessao (apos login)
 *   DELETE - remove sessao (logout)
 *
 * IMPORTANTE: setamos os cookies via `response.cookies.set(...)` no proprio
 * NextResponse retornado, em vez de `cookies().set(...)` do `next/headers`.
 * O segundo padrao depende do Next.js juntar magicamente o Set-Cookie no
 * response em construcao; em Next 16 + Turbopack essa magia falha silenciosa
 * e o response volta 200 sem Set-Cookie header. Usar response.cookies.set
 * e' o caminho recomendado e a' prova de regressao.
 */

interface LoginRequestBody {
  access_token: string;
  token_type: 'parent' | 'child';
  expires_in?: number;
}

export async function POST(request: NextRequest) {
  try {
    const {
      access_token,
      token_type,
      expires_in = 7 * 24 * 60 * 60,
    }: LoginRequestBody = await request.json();

    if (!access_token || !token_type) {
      return NextResponse.json(
        { error: { code: 'INVALID_REQUEST', message: 'Token e tipo obrigatorios' } },
        { status: 400 }
      );
    }

    const cookieName =
      token_type === 'parent'
        ? config.auth.parentCookieName
        : config.auth.childCookieName;

    // Cookie httpOnly seguro. Path '/' para ambos os tokens porque o BFF
    // proxy (/api/backend/...) precisa receber o cookie em qualquer rota.
    // A separacao pai vs crianca e' enforced em duas camadas:
    //   1) middleware.ts redireciona crianca tentando acessar rotas de pai
    //      e vice-versa.
    //   2) backend ChildAuth/ParentAuth verificam o JWT com segredos distintos.
    const response = NextResponse.json({ success: true });
    response.cookies.set({
      name: cookieName,
      value: access_token,
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: expires_in,
    });

    return response;
  } catch (error) {
    console.error('Erro ao criar sessao:', error);
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: 'Erro interno' } },
      { status: 500 }
    );
  }
}

export async function DELETE() {
  // Logout: zera ambos os cookies via maxAge=0 (browser remove na hora).
  const response = NextResponse.json({ success: true });
  for (const name of [
    config.auth.parentCookieName,
    config.auth.childCookieName,
  ]) {
    response.cookies.set({
      name,
      value: '',
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax',
      path: '/',
      maxAge: 0,
    });
  }
  return response;
}
