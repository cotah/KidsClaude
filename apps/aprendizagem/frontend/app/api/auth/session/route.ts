import { NextRequest, NextResponse } from 'next/server';
import { cookies } from 'next/headers';
import { config } from '@/lib/config';

/**
 * Route handler para gerenciar sessões de auth via httpOnly cookies.
 * POST: cria nova sessão (após login)
 * DELETE: remove sessão (logout)
 */

interface LoginRequestBody {
  access_token: string;
  token_type: 'parent' | 'child';
  expires_in?: number;
}

export async function POST(request: NextRequest) {
  try {
    const { access_token, token_type, expires_in = 7 * 24 * 60 * 60 }: LoginRequestBody = await request.json();

    if (!access_token || !token_type) {
      return NextResponse.json(
        { error: { code: 'INVALID_REQUEST', message: 'Token e tipo obrigatórios' } },
        { status: 400 }
      );
    }

    // Determinar nome do cookie e configurações
    const cookieName = token_type === 'parent'
      ? config.auth.parentCookieName
      : config.auth.childCookieName;

    // Cookie httpOnly seguro. Path '/' para ambos os tokens porque o BFF proxy
    // (/api/backend/...) precisa receber o cookie em qualquer rota. A separacao
    // pai vs crianca e' enforced em duas camadas:
    //   1) middleware.ts: redireciona crianca tentando acessar rotas de pai e
    //      vice-versa.
    //   2) backend: ChildAuth/ParentAuth verificam o JWT com segredos distintos.
    const cookieOptions = {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'lax' as const,
      path: '/',
      maxAge: expires_in,
    };

    const cookieStore = await cookies();
    cookieStore.set(cookieName, access_token, cookieOptions);

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Erro ao criar sessão:', error);
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: 'Erro interno' } },
      { status: 500 }
    );
  }
}

export async function DELETE() {
  try {
    const cookieStore = await cookies();

    // Remover ambos os cookies
    cookieStore.delete(config.auth.parentCookieName);
    cookieStore.delete(config.auth.childCookieName);

    return NextResponse.json({ success: true });
  } catch (error) {
    console.error('Erro ao remover sessão:', error);
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: 'Erro interno' } },
      { status: 500 }
    );
  }
}