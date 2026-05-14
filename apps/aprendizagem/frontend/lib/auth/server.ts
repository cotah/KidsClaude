import { cookies } from 'next/headers';
import { config } from '@/lib/config';

/**
 * Utilitários de auth para Server Components e Route Handlers.
 * Permite ler tokens de cookies httpOnly no servidor.
 */

export interface AuthTokens {
  parentToken?: string;
  childToken?: string;
}

/**
 * Lê tokens de auth dos cookies httpOnly.
 * Disponível apenas em Server Components e Route Handlers.
 */
export async function getAuthTokens(): Promise<AuthTokens> {
  const cookieStore = await cookies();

  const parentToken = cookieStore.get(config.auth.parentCookieName)?.value;
  const childToken = cookieStore.get(config.auth.childCookieName)?.value;

  return {
    parentToken,
    childToken,
  };
}

/**
 * Verifica se pai está autenticado.
 */
export async function isParentAuthenticated(): Promise<boolean> {
  const { parentToken } = await getAuthTokens();
  return !!parentToken;
}

/**
 * Verifica se criança está autenticada.
 */
export async function isChildAuthenticated(): Promise<boolean> {
  const { childToken } = await getAuthTokens();
  return !!childToken;
}

/**
 * Obtém token ativo. PARENT tem prioridade sobre CHILD quando ambos existem
 * porque a unica server-component que usa este helper hoje vive em rotas
 * (parent)/* (children/[id]/page.tsx). Antes preferia child, o que causava
 * 401 silencioso quando o pai navegava com cookie de crianca residual.
 *
 * Pra escolher explicitamente, use getParentToken / getChildToken abaixo.
 */
export async function getActiveToken(): Promise<string | null> {
  const { parentToken, childToken } = await getAuthTokens();
  return parentToken || childToken || null;
}

/**
 * Token do pai apenas. Use em Server Components dentro de (parent)/*.
 */
export async function getParentToken(): Promise<string | null> {
  const { parentToken } = await getAuthTokens();
  return parentToken ?? null;
}

/**
 * Token da crianca apenas. Use em Server Components dentro de (child)/*.
 */
export async function getChildToken(): Promise<string | null> {
  const { childToken } = await getAuthTokens();
  return childToken ?? null;
}