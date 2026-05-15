import ky, { type KyInstance } from 'ky';
import type { ApiError } from '@/types/api';

/**
 * Cliente API para Client Components.
 *
 * Todas as chamadas vao para o BFF proxy em /api/backend/v1/* (ver
 * app/api/backend/[...path]/route.ts). O proxy roda server-side, le os
 * cookies httpOnly e injeta Authorization: Bearer <token> antes de
 * encaminhar ao FastAPI. JS no browser nao consegue ler cookies httpOnly,
 * por isso este apiClient nao tenta - delega tudo para o proxy.
 *
 * Server Components nao usam este cliente; para chamadas server-side veja
 * lib/api/server.ts (serverApiClient), que le o cookie diretamente.
 */
class ApiClient {
  private client: KyInstance;

  constructor() {
    this.client = ky.create({
      // URL relativa: requests do browser resolvem contra window.location.origin,
      // batendo no Next.js que faz o proxy. Mantemos o prefixo /v1 aqui para
      // que os modulos de API continuem chamando 'children', 'lessons/{id}', etc.
      prefixUrl: '/api/backend/v1',
      timeout: 30000,
      headers: {
        'Content-Type': 'application/json',
      },
      hooks: {
        beforeError: [
          async (error) => {
            const { response } = error;
            if (response) {
              // ky v1.x: HTTPError nao expoe .status na raiz, so em .response.
              // Espelhamos em .status pra simplificar callers (signup/login/crianca
              // ja' leem error?.status diretamente).
              (error as any).status = response.status;
              try {
                const errorData = (await response.json()) as ApiError;
                error.message = errorData.error?.message || getUnknownErrorMessage();
                (error as any).apiError = errorData;
              } catch {
                // Resposta nao-JSON, mantem mensagem original do ky.
              }
            }
            return error;
          },
        ],
        afterResponse: [
          async (request, _options, response) => {
            // 401: sessao expirada/invalida. Limpa cookies via route handler de
            // auth e redireciona o usuario para a tela apropriada. Passamos o
            // request URL pra distinguir 401 de "sessao expirada" (rotas
            // normais) vs 401 de "credencial errada" (endpoints de login).
            if (response.status === 401) {
              handleUnauthorized(request.url);
            }
            return response;
          },
        ],
      },
    });
  }

  async get<T>(url: string, options?: any): Promise<T> {
    const response = await this.client.get(url, options);
    return response.json();
  }

  async post<T>(url: string, data?: any, options?: any): Promise<T> {
    const response = await this.client.post(url, {
      json: data,
      ...options,
    });
    return response.json();
  }

  async patch<T>(url: string, data?: any, options?: any): Promise<T> {
    const response = await this.client.patch(url, {
      json: data,
      ...options,
    });
    return response.json();
  }

  async delete(url: string, options?: any): Promise<void> {
    await this.client.delete(url, options);
  }

  // SSE streaming - nao usado no MVP (backend nao expoe stream); mantido
  // como API publica para uso futuro quando o backend ganhar /messages/stream.
  async getStream(url: string): Promise<ReadableStream> {
    const response = await this.client.get(url, {
      headers: {
        Accept: 'text/event-stream',
        'Cache-Control': 'no-cache',
      },
    });
    if (!response.body) throw new Error('Response body is null');
    return response.body;
  }
}

// Endpoints de auth onde 401 significa "credencial errada", NAO "sessao
// expirada". Para esses, deixamos a UI mostrar o erro inline em vez de
// derrubar a sessao e redirecionar - se eu errar a senha do pai, nao
// quero que a tentativa anterior bem-sucedida da crianca seja apagada.
const AUTH_ENDPOINT_PATTERNS = [
  '/auth/parent/login',
  '/auth/parent/signup',
  '/auth/child/login', // pega login E login-direct
  '/auth/parent/password-reset',
];

function handleUnauthorized(requestUrl?: string): void {
  if (typeof window === 'undefined') return;

  // 401 vindo de endpoint de auth: deixa o caller (UI de login) tratar.
  if (requestUrl) {
    for (const pattern of AUTH_ENDPOINT_PATTERNS) {
      if (requestUrl.includes(pattern)) {
        console.warn('[apiClient] 401 em endpoint de auth — UI trata inline, sem clearSession.');
        return;
      }
    }
  }

  const currentPath = window.location.pathname;

  // Em rotas de crianca (/play/*, /crianca) NAO derruba sessao automaticamente
  // em 401. Um 401 isolado pode ser glitch transitorio ou um endpoint que
  // ainda nao aceita child auth. A crianca so' sai via logout explicito ou
  // quando o cookie expirar (middleware redireciona pra /select no proximo nav).
  if (currentPath.startsWith('/play') || currentPath === '/crianca') {
    console.warn('[apiClient] 401 em rota de crianca — sessao mantida, sem redirect.');
    return;
  }

  // Em rotas do pai: limpa sessao e manda pro login. JWT do Supabase pode
  // ter expirado; precisa novo login.
  fetch('/api/auth/session', { method: 'DELETE' }).catch(() => {
    // Logout deve sempre prosseguir mesmo se o servidor falhar.
  });
  window.location.href = '/login';
}

// Instancia singleton.
export const apiClient = new ApiClient();

// Utilitarios para inspecionar erros padronizados do backend.
export function isApiError(error: any): error is { apiError: ApiError } {
  return Boolean(error?.apiError?.error?.code);
}

export function getApiErrorCode(error: any): string | null {
  if (isApiError(error)) return error.apiError.error.code;
  return null;
}

export function getApiErrorMessage(error: any): string {
  if (isApiError(error)) return error.apiError.error.message;
  return error?.message || 'Erro inesperado';
}

// Espelha a chave i18n common.unknown_error (messages/{en,pt}.json).
// Usado pelo beforeError hook do ky, que roda fora do React e nao pode chamar
// useTranslations. Le o cookie 'locale' (mesmo cookie que i18n/request.ts).
const UNKNOWN_ERROR_BY_LOCALE: Record<string, string> = {
  en: 'Unknown error',
  pt: 'Erro desconhecido',
};

function readLocaleFromCookie(): 'en' | 'pt' {
  if (typeof document === 'undefined') return 'en';
  const match = document.cookie.match(/(?:^|;\s*)locale=(en|pt)\b/);
  return (match?.[1] as 'en' | 'pt') ?? 'en';
}

export function getUnknownErrorMessage(): string {
  return UNKNOWN_ERROR_BY_LOCALE[readLocaleFromCookie()];
}

// True se a mensagem e' o fallback localizado de "unknown error" - usado
// como sentinel por consumidores que querem decidir se cai no proprio t().
export function isUnknownErrorFallback(msg: string | undefined | null): boolean {
  if (!msg) return false;
  return Object.values(UNKNOWN_ERROR_BY_LOCALE).includes(msg);
}
