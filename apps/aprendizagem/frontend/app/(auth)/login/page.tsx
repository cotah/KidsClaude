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

// Schema de validação conforme spec seção 4 (US-02)
const loginSchema = z.object({
  email: z
    .string()
    .email('Email inválido')
    .min(1, 'Email é obrigatório'),
  password: z
    .string()
    .min(1, 'Senha é obrigatória'),
});

type LoginFormData = z.infer<typeof loginSchema>;

/**
 * Página de login de responsável - conforme spec seção 8.1
 */
export default function LoginPage() {
  const router = useRouter();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = React.useState(false);
  const [showForgotPassword, setShowForgotPassword] = React.useState(false);

  const form = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: {
      email: '',
      password: '',
    },
  });

  const onSubmit = async (data: LoginFormData) => {
    setIsLoading(true);

    try {
      // parentLogin ja persiste a sessao via route handler (cookie httpOnly)
      await authApi.parentLogin({
        email: data.email,
        password: data.password,
      });

      toast({
        type: 'success',
        title: 'Login realizado!',
        description: 'Bem-vindo de volta ao Aprendizagem.',
      });

      router.push('/dashboard');
    } catch (error: any) {
      console.error('Login error:', error);

      let message = 'Email ou senha incorretos.';
      if (error?.status === 429) {
        message = 'Muitas tentativas. Tente novamente em alguns minutos.';
      } else if (error?.status >= 500) {
        message = 'Erro no servidor. Tente novamente em instantes.';
      }

      toast({
        type: 'error',
        title: 'Erro no login',
        description: message,
      });
    } finally {
      setIsLoading(false);
    }
  };

  const handleForgotPassword = async () => {
    const email = form.getValues('email');

    if (!email) {
      toast({
        type: 'warning',
        title: 'Email necessário',
        description: 'Digite seu email primeiro para redefinir a senha.',
      });
      return;
    }

    try {
      await authApi.requestPasswordReset(email);
      setShowForgotPassword(true);
      toast({
        type: 'success',
        title: 'Email enviado!',
        description: 'Verifique sua caixa de entrada para redefinir a senha.',
      });
    } catch (error) {
      toast({
        type: 'error',
        title: 'Erro ao enviar email',
        description: 'Tente novamente em alguns instantes.',
      });
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-ocean-100 to-grape-100 flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <CardTitle className="text-2xl font-bold text-center">
            Entrar
          </CardTitle>
          <p className="text-center text-gray-600">
            Acesse sua conta do Aprendizagem
          </p>
        </CardHeader>
        <CardContent>
          {showForgotPassword ? (
            <div className="text-center space-y-4">
              <div className="text-6xl">📧</div>
              <h3 className="text-lg font-semibold">Email enviado!</h3>
              <p className="text-sm text-gray-600">
                Enviamos um link para redefinir sua senha. Verifique sua caixa de entrada
                e pasta de spam.
              </p>
              <Button
                variant="outline"
                onClick={() => setShowForgotPassword(false)}
              >
                Voltar ao login
              </Button>
            </div>
          ) : (
            <>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                {/* Email */}
                <div className="space-y-2">
                  <label htmlFor="email" className="text-sm font-medium">
                    Email
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

                {/* Senha */}
                <div className="space-y-2">
                  <label htmlFor="password" className="text-sm font-medium">
                    Senha
                  </label>
                  <input
                    id="password"
                    type="password"
                    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
                    placeholder="Sua senha"
                    {...form.register('password')}
                  />
                  {form.formState.errors.password && (
                    <p className="text-sm text-red-600">
                      {form.formState.errors.password.message}
                    </p>
                  )}
                </div>

                <div className="text-right">
                  <button
                    type="button"
                    onClick={handleForgotPassword}
                    className="text-xs text-ocean-600 hover:underline"
                  >
                    Esqueci minha senha
                  </button>
                </div>

                <Button
                  type="submit"
                  variant="ocean"
                  size="lg"
                  className="w-full"
                  disabled={isLoading}
                >
                  {isLoading ? 'Entrando...' : 'Entrar'}
                </Button>
              </form>

              <div className="mt-6 text-center">
                <p className="text-sm text-gray-600">
                  Não tem uma conta?{' '}
                  <Link href="/signup" className="text-ocean-600 hover:underline font-medium">
                    Cadastre-se grátis
                  </Link>
                </p>
              </div>
            </>
          )}
        </CardContent>
      </Card>
    </div>
  );
}