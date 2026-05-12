import { apiClient } from './client';
import type {
  Child,
  CreateChildRequest,
  UpdateChildRequest,
  LessonProgress,
  UsageRecord,
  SafetyEvent,
  ChatSession,
} from '@/types/api';

/**
 * API de gerenciamento de crianças - conforme spec seção 7.2
 */
export const childrenApi = {
  // CRUD básico de crianças
  async list(): Promise<Child[]> {
    return apiClient.get('children');
  },

  async create(data: CreateChildRequest): Promise<Child> {
    return apiClient.post('children', data);
  },

  async get(id: string): Promise<Child> {
    return apiClient.get(`children/${id}`);
  },

  async update(id: string, data: UpdateChildRequest): Promise<Child> {
    return apiClient.patch(`children/${id}`, data);
  },

  async delete(id: string): Promise<void> {
    return apiClient.delete(`children/${id}`);
  },

  // Progresso e estatísticas
  async getProgress(id: string): Promise<LessonProgress[]> {
    return apiClient.get(`children/${id}/progress`);
  },

  async getUsage(
    id: string,
    options?: { from?: string; to?: string }
  ): Promise<UsageRecord[]> {
    const params = new URLSearchParams();
    if (options?.from) params.set('from', options.from);
    if (options?.to) params.set('to', options.to);

    const query = params.toString();
    const url = `children/${id}/usage${query ? `?${query}` : ''}`;

    // Backend retorna envelope { usage: UsageRecord[] }; extraimos o array.
    const res = await apiClient.get<{ usage: UsageRecord[] }>(url);
    return res.usage ?? [];
  },

  // Sessoes de chat do filho
  async getSessions(
    id: string,
    options?: { limit?: number; offset?: number }
  ): Promise<ChatSession[]> {
    const params = new URLSearchParams();
    if (options?.limit) params.set('limit', options.limit.toString());
    if (options?.offset) params.set('offset', options.offset.toString());

    const query = params.toString();
    const url = `children/${id}/sessions${query ? `?${query}` : ''}`;

    // Backend retorna envelope { sessions, total, limit, offset }; extraimos o array.
    const res = await apiClient.get<{ sessions: ChatSession[] }>(url);
    return res.sessions ?? [];
  },

  // Eventos de seguranca
  async getSafetyEvents(id: string): Promise<SafetyEvent[]> {
    // Backend retorna envelope { events: SafetyEvent[] }; extraimos o array.
    const res = await apiClient.get<{ events: SafetyEvent[] }>(`children/${id}/safety-events`);
    return res.events ?? [];
  },
};