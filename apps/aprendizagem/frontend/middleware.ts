import { NextRequest, NextResponse } from 'next/server';
import { config as appConfig } from './lib/config';

/**
 * Middleware para controle de rotas baseado em autenticação
 * Conforme spec seção 8 - separa acesso de pais e crianças
 */
export function middleware(request: NextRequest) {
  const { pathname } = request.nextUrl;

  // Obter tokens dos cookies
  const parentToken = request.cookies.get(appConfig.auth.parentCookieName)?.value;
  const childToken = request.cookies.get(appConfig.auth.childCookieName)?.value;

  // Rotas públicas (não precisam de auth). /crianca permite que a crianca
  // faca login direto (username + PIN) sem precisar do device do pai.
  const publicRoutes = ['/', '/signup', '/login', '/forgot-password', '/crianca'];
  const isPublicRoute = publicRoutes.includes(pathname);

  // Rotas que exigem auth de pai
  const parentRoutes = ['/dashboard', '/children', '/account'];
  const isParentRoute = parentRoutes.some(route => pathname.startsWith(route));

  // Rotas que exigem auth de criança
  const childRoutes = ['/play'];
  const isChildRoute = childRoutes.some(route => pathname.startsWith(route));

  // Rota de seleção de criança (precisa de pai logado)
  const isSelectRoute = pathname === '/select';

  // Se é rota pública, permitir acesso
  if (isPublicRoute) {
    return NextResponse.next();
  }

  // Se é rota de seleção, verificar se pai está logado
  if (isSelectRoute) {
    if (!parentToken) {
      return NextResponse.redirect(new URL('/login', request.url));
    }
    return NextResponse.next();
  }

  // Se é rota de pai, verificar token de pai. Cookies de pai e crianca
  // sao independentes e podem coexistir (ex: pai supervisionando o /play
  // do filho noutra aba). NAO mexemos no cookie da crianca aqui - o BFF
  // proxy escolhe o token certo por path/referer (ver
  // app/api/backend/[...path]/route.ts).
  if (isParentRoute) {
    if (!parentToken) {
      return NextResponse.redirect(new URL('/login', request.url));
    }
    return NextResponse.next();
  }

  // Se é rota de criança, verificar token de criança
  if (isChildRoute) {
    if (!childToken) {
      return NextResponse.redirect(new URL('/select', request.url));
    }
    return NextResponse.next();
  }

  // Fallback: se não é rota conhecida, permitir
  return NextResponse.next();
}

export const config = {
  // Aplicar middleware apenas nas rotas que precisamos controlar
  matcher: [
    /*
     * Match all request paths except for the ones starting with:
     * - api (API routes)
     * - _next/static (static files)
     * - _next/image (image optimization files)
     * - favicon.ico (favicon file)
     * - public folder
     */
    '/((?!api|_next/static|_next/image|favicon.ico|.*\\.(?:svg|png|jpg|jpeg|gif|webp)$).*)',
  ],
};