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
 * Obtém token ativo (criança tem prioridade se ambos existem).
 * Para uso em API calls no servidor.
 */
export async function getActiveToken(): Promise<string | null> {
  const { parentToken, childToken } = await getAuthTokens();
  return childToken || parentToken || null;
}