import { apiClient } from './client';
import ky from 'ky';
import type {
  ParentSignupRequest,
  ParentSignupResponse,
  ParentLoginRequest,
  ParentLoginResponse,
  ParentProfile,
  ChildLoginRequest,
  ChildLoginResponse,
} from '@/types/api';

/**
 * API de autenticação - conforme spec seção 7.1
 * Atualizada para usar Bearer tokens via httpOnly cookies gerenciados por route handlers
 */
export const authApi = {
  // Parent auth
  async parentSignup(data: ParentSignupRequest): Promise<ParentSignupResponse> {
    const response = await apiClient.post<ParentSignupResponse>('auth/parent/signup', data);

    // Armazenar token em cookie httpOnly via route handler
    await this.setSession(response.access_token, 'parent');

    return response;
  },

  async parentLogin(data: ParentLoginRequest): Promise<ParentLoginResponse> {
    const response = await apiClient.post<ParentLoginResponse>('auth/parent/login', data);

    // Armazenar token em cookie httpOnly via route handler
    await this.setSession(response.access_token, 'parent', response.expires_in);

    return response;
  },

  async parentLogout(): Promise<void> {
    try {
      await apiClient.post('auth/parent/logout');
    } catch {
      // Se falhar no backend, ainda fazer logout local
    }
    await this.clearSession();
  },

  async requestPasswordReset(email: string): Promise<{ ok: boolean }> {
    return apiClient.post('auth/parent/password-reset/request', { email });
  },

  async confirmPasswordReset(token: string, newPassword: string): Promise<void> {
    return apiClient.post('auth/parent/password-reset/confirm', {
      token,
      new_password: newPassword,
    });
  },

  async getParentProfile(): Promise<ParentProfile> {
    return apiClient.get('auth/parent/me');
  },

  // Child auth
  async childLogin(data: ChildLoginRequest): Promise<ChildLoginResponse> {
    const response = await apiClient.post<ChildLoginResponse>('auth/child/login', data);

    // Armazenar token de criança em cookie httpOnly
    await this.setSession(response.access_token, 'child', response.expires_in);

    return response;
  },

  // Session management via Next.js route handlers
  async setSession(
    access_token: string,
    token_type: 'parent' | 'child',
    expires_in?: number
  ): Promise<void> {
    const sessionClient = ky.create({
      prefixUrl: typeof window !== 'undefined' ? window.location.origin : '',
    });

    await sessionClient.post('api/auth/session', {
      json: { access_token, token_type, expires_in }
    });
  },

  async clearSession(): Promise<void> {
    const sessionClient = ky.create({
      prefixUrl: typeof window !== 'undefined' ? window.location.origin : '',
    });

    try {
      await sessionClient.delete('api/auth/session');
    } catch {
      // Falhar silenciosamente - logout sempre deve funcionar
    }
  },

  // Legacy methods for backward compatibility (now use httpOnly cookies)
  getStoredToken(type: 'parent' | 'child'): string | null {
    // httpOnly cookies não são acessíveis via JS
    return null;
  },

  isAuthenticated(type: 'parent' | 'child'): boolean {
    // Para Client Components, verificar via middleware redirect
    // Para Server Components, usar getAuthTokens()
    return false;
  },
};