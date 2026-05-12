import { describe, it, expect } from 'vitest';
import { isApiError, getApiErrorCode, getApiErrorMessage } from './client';

// Testes dos utilitarios de erro do client. Nao testamos token-attachment
// porque o apiClient delega auth ao BFF proxy (app/api/backend/[...path]/route.ts)
// que injeta o Bearer server-side a partir do cookie httpOnly. Esse fluxo e'
// melhor coberto por teste end-to-end (Playwright) com cookie real.

describe('isApiError', () => {
  it('retorna true para o shape padrao do backend', () => {
    const error = {
      apiError: {
        error: { code: 'INVALID_CREDENTIALS', message: 'Email ou senha incorretos' },
      },
    };
    expect(isApiError(error)).toBe(true);
  });

  it('retorna false para Error normal do JS', () => {
    expect(isApiError(new Error('Network error'))).toBe(false);
  });

  it('retorna false para objeto vazio', () => {
    expect(isApiError({})).toBe(false);
  });

  it('retorna false para null e undefined', () => {
    expect(isApiError(null)).toBe(false);
    expect(isApiError(undefined)).toBe(false);
  });

  it('retorna false quando o code esta vazio (string falsy)', () => {
    expect(isApiError({ apiError: { error: { code: '', message: 'x' } } })).toBe(false);
  });
});

describe('getApiErrorCode', () => {
  it('extrai o codigo do erro padrao', () => {
    const error = {
      apiError: { error: { code: 'VALIDATION_ERROR', message: 'Invalid' } },
    };
    expect(getApiErrorCode(error)).toBe('VALIDATION_ERROR');
  });

  it('retorna null para erros nao-API', () => {
    expect(getApiErrorCode({})).toBe(null);
    expect(getApiErrorCode(null)).toBe(null);
    expect(getApiErrorCode(new Error('x'))).toBe(null);
  });
});

describe('getApiErrorMessage', () => {
  it('extrai a mensagem do erro padrao do backend', () => {
    const error = {
      apiError: { error: { code: 'X', message: 'Mensagem do backend' } },
    };
    expect(getApiErrorMessage(error)).toBe('Mensagem do backend');
  });

  it('cai no Error.message para erros nao-API com message', () => {
    expect(getApiErrorMessage({ message: 'Erro de rede' })).toBe('Erro de rede');
    expect(getApiErrorMessage(new Error('boom'))).toBe('boom');
  });

  it('mensagem padrao quando nao ha info disponivel', () => {
    expect(getApiErrorMessage({})).toBe('Erro inesperado');
    expect(getApiErrorMessage(null)).toBe('Erro inesperado');
  });
});
