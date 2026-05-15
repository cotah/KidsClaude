'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LanguageSwitcher } from '@/components/ui/language-switcher';
import { useToast } from '@/components/ui/toast';
import { authApi } from '@/lib/api';

/**
 * Página de login de responsável.
 * Strings via next-intl (cookie-based locale, default 'en').
 *
 * Schema zod usa `t` capturado no render via useTranslations - precisa
 * ser construido dentro do componente. Antes era global (Portuguese
 * hardcoded); agora reconstroi quando o locale muda.
 */
export default function LoginPage() {
  const t = useTranslations('login');
  const router = useRouter();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = React.useState(false);
  const [showForgotPassword, setShowForgotPassword] = React.useState(false);

  const loginSchema = React.useMemo(
    () =>
      z.object({
        email: z
          .string()
          .email(t('email_invalid'))
          .min(1, t('email_required')),
        password: z.string().min(1, t('password_required')),
      }),
    [t]
  );

  type LoginFormData = z.infer<typeof loginSchema>;

  const form = useForm<LoginFormData>({
    resolver: zodResolver(loginSchema),
    defaultValues: { email: '', password: '' },
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
        title: t('toast_success_title'),
        description: t('toast_success_desc'),
      });

      router.push('/dashboard');
    } catch (error: any) {
      console.error('Login error:', error);

      let message = t('toast_invalid_credentials');
      if (error?.status === 429) {
        message = t('toast_rate_limited');
      } else if (error?.status >= 500) {
        message = t('toast_server_error');
      }

      toast({
        type: 'error',
        title: t('toast_error_title'),
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
        title: t('forgot_email_required_title'),
        description: t('forgot_email_required_desc'),
      });
      return;
    }

    try {
      await authApi.requestPasswordReset(email);
      setShowForgotPassword(true);
      toast({
        type: 'success',
        title: t('forgot_sent_title'),
        description: t('forgot_sent_desc'),
      });
    } catch (error) {
      toast({
        type: 'error',
        title: t('forgot_error_title'),
        description: t('forgot_error_desc'),
      });
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-ocean-100 to-grape-100 flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <div className="flex justify-end">
            <LanguageSwitcher />
          </div>
          <CardTitle className="text-2xl font-bold text-center">
            {t('title')}
          </CardTitle>
          <p className="text-center text-gray-600">{t('subtitle')}</p>
        </CardHeader>
        <CardContent>
          {showForgotPassword ? (
            <div className="text-center space-y-4">
              <div className="text-6xl">📧</div>
              <h3 className="text-lg font-semibold">{t('forgot_screen_title')}</h3>
              <p className="text-sm text-gray-600">{t('forgot_screen_body')}</p>
              <Button
                variant="outline"
                onClick={() => setShowForgotPassword(false)}
              >
                {t('forgot_screen_back')}
              </Button>
            </div>
          ) : (
            <>
              <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
                {/* Email */}
                <div className="space-y-2">
                  <label htmlFor="email" className="text-sm font-medium">
                    {t('email_label')}
                  </label>
                  <input
                    id="email"
                    type="email"
                    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
                    placeholder={t('email_placeholder')}
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
                    {t('password_label')}
                  </label>
                  <input
                    id="password"
                    type="password"
                    className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
                    placeholder={t('password_placeholder')}
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
                    {t('forgot_password')}
                  </button>
                </div>

                <Button
                  type="submit"
                  variant="ocean"
                  size="lg"
                  className="w-full"
                  disabled={isLoading}
                >
                  {isLoading ? t('submitting') : t('submit')}
                </Button>
              </form>

              <div className="mt-6 text-center">
                <p className="text-sm text-gray-600">
                  {t('no_account')}{' '}
                  <Link
                    href="/signup"
                    className="text-ocean-600 hover:underline font-medium"
                  >
                    {t('signup_link')}
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
