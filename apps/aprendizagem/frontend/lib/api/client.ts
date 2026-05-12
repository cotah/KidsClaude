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
              try {
                const errorData = (await response.json()) as ApiError;
                error.message = errorData.error?.message || 'Erro desconhecido';
                (error as any).apiError = errorData;
              } catch {
                // Resposta nao-JSON, mantem mensagem original do ky.
              }
            }
            return error;
          },
        ],
        afterResponse: [
          async (_request, _options, response) => {
            // 401: sessao expirada/invalida. Limpa cookies via route handler de
            // auth e redireciona o usuario para a tela apropriada.
            if (response.status === 401) {
              handleUnauthorized();
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

function handleUnauthorized(): void {
  if (typeof window === 'undefined') return;
  // Limpa cookies via route handler (cookies httpOnly so somem por server side).
  fetch('/api/auth/session', { method: 'DELETE' }).catch(() => {
    // Logout deve sempre prosseguir mesmo se o servidor falhar.
  });
  const currentPath = window.location.pathname;
  if (currentPath.startsWith('/play')) {
    window.location.href = '/select';
  } else {
    window.location.href = '/login';
  }
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
