'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { authApi } from '@/lib/api/auth';
import { getApiErrorMessage } from '@/lib/api/client';

const resetSchema = z.object({
  email: z.string().email('Email inválido'),
});

const confirmSchema = z.object({
  token: z.string().min(1, 'Token obrigatório'),
  newPassword: z.string()
    .min(8, 'Senha deve ter pelo menos 8 caracteres')
    .regex(/^(?=.*[a-zA-Z])(?=.*[0-9])/, 'Senha deve ter pelo menos 1 letra e 1 número'),
});

type ResetFormData = z.infer<typeof resetSchema>;
type ConfirmFormData = z.infer<typeof confirmSchema>;

/**
 * Página de reset de senha - duas etapas:
 * 1. Solicitar reset por email
 * 2. Confirmar com token + nova senha
 */
export default function ForgotPasswordPage() {
  const router = useRouter();
  const [step, setStep] = useState<'request' | 'confirm'>('request');
  const [email, setEmail] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [message, setMessage] = useState('');

  // Formulário de solicitação
  const requestForm = useForm<ResetFormData>({
    resolver: zodResolver(resetSchema),
  });

  // Formulário de confirmação
  const confirmForm = useForm<ConfirmFormData>({
    resolver: zodResolver(confirmSchema),
  });

  const handleRequestReset = async (data: ResetFormData) => {
    setIsLoading(true);
    setError('');

    try {
      await authApi.requestPasswordReset(data.email);
      setEmail(data.email);
      setMessage('Se o email existe em nossa base, você receberá instruções para redefinir sua senha.');
      setStep('confirm');
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  const handleConfirmReset = async (data: ConfirmFormData) => {
    setIsLoading(true);
    setError('');

    try {
      await authApi.confirmPasswordReset(data.token, data.newPassword);
      setMessage('Senha redefinida com sucesso! Redirecionando...');
      setTimeout(() => router.push('/login'), 2000);
    } catch (err) {
      setError(getApiErrorMessage(err));
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-purple-50 to-pink-50 p-4">
      <Card className="w-full max-w-md p-8 shadow-lg">
        {step === 'request' ? (
          // Etapa 1: Solicitar reset
          <>
            <div className="text-center mb-8">
              <h1 className="text-2xl font-bold text-gray-900 mb-2">
                Esqueceu sua senha?
              </h1>
              <p className="text-gray-600">
                Digite seu email para receber instruções de reset.
              </p>
            </div>

            <form onSubmit={requestForm.handleSubmit(handleRequestReset)} className="space-y-6">
              <div>
                <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                  Email
                </label>
                <input
                  {...requestForm.register('email')}
                  type="email"
                  id="email"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="seu@email.com"
                />
                {requestForm.formState.errors.email && (
                  <p className="mt-1 text-sm text-red-600">
                    {requestForm.formState.errors.email.message}
                  </p>
                )}
              </div>

              {error && (
                <div className="p-3 bg-red-50 border border-red-200 rounded-md">
                  <p className="text-sm text-red-600">{error}</p>
                </div>
              )}

              {message && (
                <div className="p-3 bg-green-50 border border-green-200 rounded-md">
                  <p className="text-sm text-green-600">{message}</p>
                </div>
              )}

              <Button
                type="submit"
                disabled={isLoading}
                className="w-full bg-purple-600 hover:bg-purple-700"
              >
                {isLoading ? 'Enviando...' : 'Enviar instruções'}
              </Button>
            </form>
          </>
        ) : (
          // Etapa 2: Confirmar com token
          <>
            <div className="text-center mb-8">
              <h1 className="text-2xl font-bold text-gray-900 mb-2">
                Redefinir senha
              </h1>
              <p className="text-gray-600">
                Digite o código recebido por email e sua nova senha.
              </p>
              <p className="text-sm text-gray-500 mt-2">
                Email: {email}
              </p>
            </div>

            <form onSubmit={confirmForm.handleSubmit(handleConfirmReset)} className="space-y-6">
              <div>
                <label htmlFor="token" className="block text-sm font-medium text-gray-700 mb-2">
                  Código de verificação
                </label>
                <input
                  {...confirmForm.register('token')}
                  type="text"
                  id="token"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Código recebido por email"
                />
                {confirmForm.formState.errors.token && (
                  <p className="mt-1 text-sm text-red-600">
                    {confirmForm.formState.errors.token.message}
                  </p>
                )}
              </div>

              <div>
                <label htmlFor="newPassword" className="block text-sm font-medium text-gray-700 mb-2">
                  Nova senha
                </label>
                <input
                  {...confirmForm.register('newPassword')}
                  type="password"
                  id="newPassword"
                  className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
                  placeholder="Nova senha"
                />
                {confirmForm.formState.errors.newPassword && (
                  <p className="mt-1 text-sm text-red-600">
                    {confirmForm.formState.errors.newPassword.message}
                  </p>
                )}
              </div>

              {error && (
                <div className="p-3 bg-red-50 border border-red-200 rounded-md">
                  <p className="text-sm text-red-600">{error}</p>
                </div>
              )}

              {message && (
                <div className="p-3 bg-green-50 border border-green-200 rounded-md">
                  <p className="text-sm text-green-600">{message}</p>
                </div>
              )}

              <div className="flex space-x-3">
                <Button
                  type="button"
                  variant="outline"
                  onClick={() => setStep('request')}
                  className="flex-1"
                >
                  Voltar
                </Button>
                <Button
                  type="submit"
                  disabled={isLoading}
                  className="flex-1 bg-purple-600 hover:bg-purple-700"
                >
                  {isLoading ? 'Redefinindo...' : 'Redefinir senha'}
                </Button>
              </div>
            </form>
          </>
        )}

        <div className="mt-6 text-center">
          <Link
            href="/login"
            className="text-sm text-purple-600 hover:text-purple-500"
          >
            Voltar ao login
          </Link>
        </div>
      </Card>
    </div>
  );
}