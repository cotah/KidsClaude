import ky from 'ky';
import { config } from '../config';
import { getActiveToken } from '../auth/server';
import type { ApiError } from '@/types/api';

/**
 * Cliente API para Server Components.
 * Usa tokens de cookies httpOnly para autenticação.
 */
class ServerApiClient {
  private async createClient() {
    const token = await getActiveToken();

    return ky.create({
      prefixUrl: config.api.baseUrl,
      timeout: config.api.timeout,
      headers: {
        'Content-Type': 'application/json',
        ...(token && { 'Authorization': `Bearer ${token}` }),
      },
    });
  }

  async get<T>(url: string, options?: any): Promise<T> {
    const client = await this.createClient();
    const response = await client.get(url, options);
    return response.json();
  }

  async post<T>(url: string, data?: any, options?: any): Promise<T> {
    const client = await this.createClient();
    const response = await client.post(url, {
      json: data,
      ...options,
    });
    return response.json();
  }

  async patch<T>(url: string, data?: any, options?: any): Promise<T> {
    const client = await this.createClient();
    const response = await client.patch(url, {
      json: data,
      ...options,
    });
    return response.json();
  }

  async delete(url: string, options?: any): Promise<void> {
    const client = await this.createClient();
    await client.delete(url, options);
  }
}

// Instância singleton do cliente servidor
export const serverApiClient = new ServerApiClient();