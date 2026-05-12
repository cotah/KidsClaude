import { apiClient } from './client';
import type {
  DashboardData,
  HeartbeatRequest,
  HeartbeatResponse,
  HealthResponse,
} from '@/types/api';

/**
 * API do painel dos pais e heartbeat - conforme spec seção 7.6 e 7.7
 */
export const dashboardApi = {
  // Dashboard dos pais
  async getDashboard(): Promise<DashboardData> {
    return apiClient.get('parents/dashboard');
  },
};

/**
 * API de controle de uso e heartbeat
 */
export const usageApi = {
  async sendHeartbeat(data: HeartbeatRequest): Promise<HeartbeatResponse> {
    return apiClient.post('usage/heartbeat', data);
  },
};

/**
 * API de health check
 */
export const healthApi = {
  async getHealth(): Promise<HealthResponse> {
    return apiClient.get('health');
  },
};