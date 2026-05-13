import { apiClient } from './client';
import type {
  Lesson,
  LessonProgress,
  LessonCompletionResponse,
  Challenge,
  ChallengeAttemptRequest,
  ChallengeAttemptResponse,
} from '@/types/api';

/**
 * API de lições e desafios - conforme spec seção 7.3 e 7.4
 */
export const lessonsApi = {
  // Lições
  async list(ageBand?: '6-8' | '9-12'): Promise<Lesson[]> {
    const params = new URLSearchParams();
    if (ageBand) params.set('age_band', ageBand);

    const query = params.toString();
    const url = `lessons${query ? `?${query}` : ''}`;

    return apiClient.get(url);
  },

  async get(id: string): Promise<Lesson> {
    return apiClient.get(`lessons/${id}`);
  },

  async start(id: string): Promise<{ progress_id: string; status: 'in_progress' }> {
    return apiClient.post(`lessons/${id}/start`);
  },

  async complete(id: string): Promise<LessonCompletionResponse> {
    return apiClient.post(`lessons/${id}/complete`, {});
  },

  // Progresso de licoes - backend expoe em GET /v1/children/{id}/progress.
  // Backend retorna envelope { progress: [...] }; extraimos o array para
  // que o consumer possa fazer .find/.filter/.length sem .progress.find.
  async getProgress(childId: string): Promise<LessonProgress[]> {
    const res = await apiClient.get<{ progress?: LessonProgress[] }>(
      `children/${childId}/progress`
    );
    return res?.progress ?? [];
  },
};

/**
 * API de desafios
 */
export const challengesApi = {
  async attempt(
    id: string,
    data: ChallengeAttemptRequest
  ): Promise<ChallengeAttemptResponse> {
    return apiClient.post(`challenges/${id}/attempt`, data);
  },
};