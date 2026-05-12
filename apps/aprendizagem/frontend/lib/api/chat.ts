import { apiClient } from './client';
import type {
  ChatSession,
  CreateChatSessionRequest,
  CreateChatSessionResponse,
  SendMessageRequest,
  SendMessageResponse,
} from '@/types/api';

/**
 * API de chat com Claude - conforme spec seção 7.5
 */
export const chatApi = {
  // Gerenciar sessões
  async createSession(data: CreateChatSessionRequest): Promise<CreateChatSessionResponse> {
    return apiClient.post('chat/sessions', data);
  },

  async getSession(id: string): Promise<ChatSession> {
    return apiClient.get(`chat/sessions/${id}`);
  },

  async endSession(id: string): Promise<{ summary: string; safety_status: string }> {
    return apiClient.post(`chat/sessions/${id}/end`);
  },

  // Enviar mensagens
  async sendMessage(sessionId: string, data: SendMessageRequest): Promise<SendMessageResponse> {
    return apiClient.post(`chat/sessions/${sessionId}/messages`, data);
  },

  // Stream de mensagens para chat em tempo real
  async streamMessage(
    sessionId: string,
    data: SendMessageRequest
  ): Promise<ReadableStream> {
    // Nota: Esta implementação assume que o backend suporta streaming via SSE
    // Se necessário, pode ser adaptada para WebSockets
    return apiClient.getStream(`chat/sessions/${sessionId}/messages/stream`);
  },

  // Parser para SSE (Server-Sent Events). content e' tipado como unknown porque o
  // payload depende do tipo de evento (string para "token", objeto para "complete").
  parseSSEMessage(data: string): { type: string; content: unknown } | null {
    try {
      const lines = data.split('\n');
      let type = '';
      let content = '';

      for (const line of lines) {
        if (line.startsWith('event:')) {
          type = line.substring(6).trim();
        } else if (line.startsWith('data:')) {
          content += line.substring(5).trim();
        }
      }

      if (type && content) {
        return { type, content: JSON.parse(content) };
      }
    } catch (error) {
      console.error('Failed to parse SSE message:', error);
    }
    return null;
  },

  // Helper para processar stream de chat
  async processMessageStream(
    sessionId: string,
    data: SendMessageRequest,
    onToken: (token: string) => void,
    onComplete: (message: SendMessageResponse) => void,
    onError: (error: any) => void
  ): Promise<void> {
    try {
      const stream = await this.streamMessage(sessionId, data);
      const reader = stream.getReader();
      const decoder = new TextDecoder();

      let buffer = '';

      while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        buffer += decoder.decode(value, { stream: true });
        const messages = buffer.split('\n\n');
        buffer = messages.pop() || '';

        for (const message of messages) {
          if (message.trim()) {
            const parsed = this.parseSSEMessage(message);
            if (parsed) {
              switch (parsed.type) {
                case 'token':
                  onToken(parsed.content as string);
                  break;
                case 'complete':
                  onComplete(parsed.content as SendMessageResponse);
                  break;
                case 'error':
                  onError(parsed.content);
                  return;
              }
            }
          }
        }
      }
    } catch (error) {
      onError(error);
    }
  },
};