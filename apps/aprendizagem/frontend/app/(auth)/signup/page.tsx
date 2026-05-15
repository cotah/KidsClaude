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
 * Página de cadastro do responsável.
 * Strings via next-intl (cookie-based locale, default 'en').
 *
 * Schema zod construido com t no useMemo - validation messages reagem
 * ao locale switch sem reload (mesmo padrao do /login).
 */
export default function SignupPage() {
  const t = useTranslations('signup');
  const router = useRouter();
  const { toast } = useToast();
  const [isLoading, setIsLoading] = React.useState(false);

  const signupSchema = React.useMemo(
    () =>
      z
        .object({
          displayName: z.string().min(2, t('name_min')),
          email: z.string().email(t('email_invalid')).min(1, t('email_required')),
          password: z
            .string()
            .min(8, t('password_min'))
            .regex(/[a-zA-Z]/, t('password_letter'))
            .regex(/\d/, t('password_number')),
          confirmPassword: z.string().min(1, t('confirm_password_required')),
          termsAccepted: z.boolean().refine((v) => v === true, {
            message: t('terms_required'),
          }),
          consentAccepted: z.boolean().refine((v) => v === true, {
            message: t('consent_required'),
          }),
        })
        .refine((d) => d.password === d.confirmPassword, {
          message: t('passwords_dont_match'),
          path: ['confirmPassword'],
        }),
    [t]
  );

  type SignupFormData = z.infer<typeof signupSchema>;

  const form = useForm<SignupFormData>({
    resolver: zodResolver(signupSchema),
    defaultValues: {
      displayName: '',
      email: '',
      password: '',
      confirmPassword: '',
      termsAccepted: false,
      consentAccepted: false,
    },
  });

  const onSubmit = async (data: SignupFormData) => {
    setIsLoading(true);

    try {
      // parentSignup ja' persiste a sessao via route handler (cookie httpOnly)
      await authApi.parentSignup({
        email: data.email,
        password: data.password,
        display_name: data.displayName,
      });

      toast({
        type: 'success',
        title: t('toast_success_title'),
        description: t('toast_success_desc'),
      });

      router.push('/dashboard');
    } catch (error: any) {
      console.error('Signup error:', error);

      let message = t('toast_generic_error');
      if (error?.status === 409) {
        message = t('toast_email_exists');
      } else if (error?.status === 422) {
        message = t('toast_invalid_data');
      } else if (error?.status === 429) {
        message = t('toast_rate_limited');
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

  return (
    <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center p-4">
      <Card className="w-full max-w-lg">
        <CardHeader className="space-y-1">
          <div className="flex justify-end">
            <LanguageSwitcher />
          </div>
          <CardTitle className="text-2xl font-bold text-center">{t('title')}</CardTitle>
          <p className="text-center text-gray-600">{t('subtitle')}</p>
        </CardHeader>
        <CardContent>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            {/* Nome completo */}
            <div className="space-y-2">
              <label htmlFor="displayName" className="text-sm font-medium">
                {t('name_label')}
              </label>
              <input
                id="displayName"
                type="text"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
                placeholder={t('name_placeholder')}
                {...form.register('displayName')}
              />
              {form.formState.errors.displayName && (
                <p className="text-sm text-red-600">
                  {form.formState.errors.displayName.message}
                </p>
              )}
            </div>

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

            {/* Confirmar Senha */}
            <div className="space-y-2">
              <label htmlFor="confirmPassword" className="text-sm font-medium">
                {t('confirm_password_label')}
              </label>
              <input
                id="confirmPassword"
                type="password"
                className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus:outline-none focus:ring-2 focus:ring-ring"
                placeholder={t('confirm_password_placeholder')}
                {...form.register('confirmPassword')}
              />
              {form.formState.errors.confirmPassword && (
                <p className="text-sm text-red-600">
                  {form.formState.errors.confirmPassword.message}
                </p>
              )}
            </div>

            {/* Termos + consentimento (legal compliance LGPD/COPPA) */}
            <div className="space-y-3 pt-4">
              <div className="flex items-start space-x-2">
                <input
                  id="termsAccepted"
                  type="checkbox"
                  className="mt-1 h-4 w-4 rounded border-gray-300"
                  {...form.register('termsAccepted')}
                />
                <label
                  htmlFor="termsAccepted"
                  className="text-xs text-gray-700 leading-tight"
                >
                  {t('terms_label')}
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
                <label
                  htmlFor="consentAccepted"
                  className="text-xs text-gray-700 leading-tight"
                >
                  {t('consent_label')}
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
              {isLoading ? t('submitting') : t('submit')}
            </Button>
          </form>

          <div className="mt-6 text-center">
            <p className="text-sm text-gray-600">
              {t('have_account')}{' '}
              <Link
                href="/login"
                className="text-sunny-600 hover:underline font-medium"
              >
                {t('login_link')}
              </Link>
            </p>
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
