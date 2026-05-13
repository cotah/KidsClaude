import { apiClient } from './client';
import { config } from '@/lib/config';
import { mockDelay, mockStagesResponse, mockLessons } from '@/lib/mock/data';
import type {
  Lesson,
  LessonProgress,
  LessonCompletionResponse,
  Challenge,
  ChallengeAttemptRequest,
  ChallengeAttemptResponse,
  StagesResponse,
  ExamSession,
  ExamMessageRequest,
  ExamMessageResponse,
  ExamSubmitResponse,
} from '@/types/api';

/**
 * API de stages - conforme spec curriculum redesign seção 5.1
 */
export const stagesApi = {
  async getStages(): Promise<StagesResponse> {
    if (config.features.useMocks) {
      await mockDelay();
      return mockStagesResponse;
    }
    return apiClient.get('stages');
  },
};

/**
 * API de lições e desafios - conforme spec seção 7.3 e 7.4
 */
export const lessonsApi = {
  // Lições
  async list(opts?: { ageBand?: '6-8' | '9-10' | '11-12' | '12+'; stage?: number }): Promise<Lesson[]> {
    if (config.features.useMocks) {
      await mockDelay();
      let filteredLessons = [...mockLessons];

      if (opts?.stage) {
        filteredLessons = filteredLessons.filter(lesson => lesson.stage === opts.stage);
      }
      if (opts?.ageBand) {
        filteredLessons = filteredLessons.filter(lesson => lesson.age_band === opts.ageBand);
      }

      return filteredLessons;
    }

    const params = new URLSearchParams();
    if (opts?.ageBand) params.set('age_band', opts.ageBand);
    if (opts?.stage) params.set('stage', opts.stage.toString());

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

/**
 * API do exame final - conforme spec curriculum redesign seção 5.3
 */
export const examApi = {
  async startExam(): Promise<ExamSession> {
    if (config.features.useMocks) {
      await mockDelay();
      return {
        session_id: 'mock-exam-session-' + Date.now(),
        started_at: new Date().toISOString(),
        lesson_id: 'lesson-final-exam',
      };
    }
    return apiClient.post('exam/start', {});
  },

  async sendExamMessage(sessionId: string, data: ExamMessageRequest): Promise<ExamMessageResponse> {
    if (config.features.useMocks) {
      await mockDelay(1500); // Simula tempo de resposta do Claude

      // Mock responses para os 5 passos do exame
      const mockResponses = [
        'Ótima ideia! Agora me conta: quem são as pessoas que teriam esse problema? Pensa na idade delas, onde elas estão quando isso acontece.',
        'Perfeito! Agora vamos focar no que o app vai fazer. Me lista as 3 funcionalidades mais importantes que resolvem esse problema.',
        'Muito bom! Agora imagina a primeira tela que a pessoa vai ver quando abrir o app. Me descreve 3 coisas que ela veria.',
        'Excelente! Última pergunta: se você tivesse 1 hora amanhã para começar a construir isso, qual seria o primeiro passo?',
        'Incrível! Você criou um plano super completo:\n\n**Problema:** Seu app resolve um problema real\n**Usuários:** Você definiu claramente quem vai usar\n**Funcionalidades:** As 3 principais estão bem pensadas\n**Tela inicial:** Visual claro e objetivo\n**Primeiro passo:** Um começo prático e realizável\n\nParabéns! Você agora tem todas as peças para construir seu app dos sonhos! 🎉'
      ];

      const step = Math.min(data.content.split(' ').length > 5 ? Math.floor(Math.random() * 5) + 1 : 1, 5);
      const responseIndex = Math.min(step - 1, mockResponses.length - 1);

      return {
        message_id: 'mock-msg-' + Date.now(),
        assistant_message: {
          content: mockResponses[responseIndex],
        },
        current_step: step,
        is_complete: step >= 5,
      };
    }
    return apiClient.post(`exam/sessions/${sessionId}/messages`, data);
  },

  async submitExam(sessionId: string): Promise<ExamSubmitResponse> {
    if (config.features.useMocks) {
      await mockDelay();
      return {
        xp_earned: 500,
        badges_unlocked: ['CAPSTONE_BUILDER'],
        summary: 'Projeto criado com sucesso! Você demonstrou criatividade e pensamento estratégico.',
        plan: {
          problem: 'App para resolver problemas do dia a dia',
          users: 'Pessoas de todas as idades',
          features: 'Interface simples, notificações úteis, sincronização',
          screen: 'Tela inicial limpa com menu principal',
          first_step: 'Criar mockup da tela inicial',
        },
      };
    }
    return apiClient.post(`exam/sessions/${sessionId}/submit`, {});
  },
};