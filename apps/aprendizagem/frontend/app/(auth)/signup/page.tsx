'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { useToast } from '@/components/ui/toast';
import { authApi } from '@/lib/api';
import { getPasswordValidationErrors } from '@/lib/utils';

// Schema de validação conforme spec seção 4 (US-01)
const signupSchema = z.object({
  email: z
    .string()
    .email('Email inválido')
    .min(1, 'Email é obrigatório'),
  password: z
    .string()
    .min(8, 'Mínimo 8 caracteres')
    .regex(/[a-zA-Z]/, 'Deve conter pelo menos uma letra')
    .regex(/\d/, 'Deve conter pelo menos um número'),
  confirmPassword: z.string().min(1, 'Confirmação é obrigatória'),
  displayName: z.string().optional(),
  termsAccepted: z.boolean().refine(val => val === true, {
    message: 'Você deve aceitar os termos',
  }),
  consentAccepted: z.boolean().refine(val => val === true, {
    message: 'Consentimento para uso de IA é obrigatório',
  }),
}).refine(data => data.password === data.confirmPassword, {
  message: 'Senhas não conferem',
  path: ['confirmPassword'],
});

type SignupFormData = z.infer<typeof signupSchema>;

/**
 * Página de cadastro de responsável - conforme spec seção 8.1
 */
export default function SignupPage() {
  const router = useRouter();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = React.useState(false);

  const form = useForm<SignupFormData>({
    resolver: zodResolver(signupSchema),
    defaultValues: {
      email: '',
      password: '',
      confirmPassword: '',
      displayName: '',
      termsAccepted: false,
      consentAccepted: false,
    },
  });

  const onSubmit = async (data: SignupFormData) => {
    setIsLoading(true);

    try {
      // parentSignup ja persiste a sessao via route handler (cookie httpOnly)
      await authApi.parentSignup({
        email: data.email,
        password: data.password,
        display_name: data.displayName || undefined,
      });

      toast({
        type: 'success',
        title: 'Conta criada com sucesso!',
        description: 'Bem-vindo ao Aprendizagem. Vamos configurar o perfil do seu filho.',
      });

      router.push('/children/new');
    } catch (error: any) {
      console.error('Signup error:', error);

      let message = 'Erro ao criar conta. Tente novamente.';
      if (error?.status === 409) {
        message = 'Este email já está cadastrado. Tente fazer login.';
      } else if (error?.status === 422) {
        message = 'Dados inválidos. Verifique as informações digitadas.';
      }

      toast({
        type: 'error',
        title: 'Erro no cadastro',
        description: message,
      });
    } finally {
      setIsLoading(false);
    }
  };

  // Validação da senha em tempo real
  const passwordValue = form.watch('password');
  const passwordErrors = passwordValue ? getPasswordValidationErrors(passwordValue) : [];

  return (
    <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center p-4">
      <Card className="w-full max-w-lg">
        <CardHeader className="space-y-1">
          <CardTitle className="text-2xl font-bold text-center">
            Crie sua conta
          </CardTitle>
          <p className="text-center text-gray-600">
            Para começar a aventura digital dos seus filhos
          </p>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            {/* Email */}
            <div className="space-y-2">
              <label htmlFor="email" className="text-sm font-medium">
                Email *
              </label>
              <input
                id="email"
                type="email"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
                placeholder="seu.email@exemplo.com"
                {...form.register('email')}
              />
              {form.formState.errors.email && (
                <p className="text-sm text-red-600">
                  {form.formState.errors.email.message}
                </p>
              )}
            </div>

            {/* Nome (opcional) */}
            <div className="space-y-2">
              <label htmlFor="displayName" className="text-sm font-medium">
                Seu nome (opcional)
              </label>
              <input
                id="displayName"
                type="text"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
                placeholder="Como prefere ser chamado?"
                {...form.register('displayName')}
              />
            </div>

            {/* Senha */}
            <div className="space-y-2">
              <label htmlFor="password" className="text-sm font-medium">
                Senha *
              </label>
              <input
                id="password"
                type="password"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
                placeholder="Mínimo 8 caracteres"
                {...form.register('password')}
              />
              {form.formState.errors.password && (
                <p className="text-sm text-red-600">
                  {form.formState.errors.password.message}
                </p>
              )}
              {passwordErrors.length > 0 && (
                <div className="text-xs text-gray-600">
                  <p>Sua senha precisa de:</p>
                  <ul className="list-disc list-inside ml-2">
                    {passwordErrors.map((error, index) => (
                      <li key={index}>{error}</li>
                    ))}
                  </ul>
                </div>
              )}
            </div>

            {/* Confirmar Senha */}
            <div className="space-y-2">
              <label htmlFor="confirmPassword" className="text-sm font-medium">
                Confirmar Senha *
              </label>
              <input
                id="confirmPassword"
                type="password"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
                placeholder="Digite a senha novamente"
                {...form.register('confirmPassword')}
              />
              {form.formState.errors.confirmPassword && (
                <p className="text-sm text-red-600">
                  {form.formState.errors.confirmPassword.message}
                </p>
              )}
            </div>

            {/* Termos e Consentimento - conforme spec seção 10.2 */}
            <div className="space-y-3 pt-4">
              <div className="flex items-start space-x-2">
                <input
                  id="termsAccepted"
                  type="checkbox"
                  className="mt-1 h-4 w-4 rounded border-gray-300"
                  {...form.register('termsAccepted')}
                />
                <label htmlFor="termsAccepted" className="text-xs text-gray-700 leading-tight">
                  Li e aceito os termos de uso e a politica de privacidade.
                  Confirmo que sou maior de idade e responsavel legal pela(s) crianca(s).
                </label>
              </div>
              {form.formState.errors.termsAccepted && (
                <p className="text-sm text-red-600">
                  {form.formState.errors.termsAccepted.message}
                </p>
              )}

              <div className="flex items-start space-x-2">
                <input
                  id="consentAccepted"
                  type="checkbox"
                  className="mt-1 h-4 w-4 rounded border-gray-300"
                  {...form.register('consentAccepted')}
                />
                <label htmlFor="consentAccepted" className="text-xs text-gray-700 leading-tight">
                  Autorizo o uso de inteligência artificial (Claude) para interação educativa
                  com meu(s) filho(s), ciente de que todas as conversas são moderadas e
                  podem ser revisadas por mim.
                </label>
              </div>
              {form.formState.errors.consentAccepted && (
                <p className="text-sm text-red-600">
                  {form.formState.errors.consentAccepted.message}
                </p>
              )}
            </div>

            <Button
              type="submit"
              variant="sunny"
              size="lg"
              className="w-full"
              disabled={isLoading}
            >
              {isLoading ? 'Criando conta...' : 'Criar Conta'}
            </Button>
          </form>

          <div className="mt-6 text-center">
            <p className="text-sm text-gray-600">
              Já tem uma conta?{' '}
              <Link href="/login" className="text-sunny-600 hover:underline font-medium">
                Faça login
              </Link>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}