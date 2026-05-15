'use client';

import * as React from 'react';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { ArrowLeft } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { LanguageSwitcher } from '@/components/ui/language-switcher';
import { useToast } from '@/components/ui/toast';
import { authApi } from '@/lib/api';

/**
 * Pagina dedicada de recuperacao de senha. Backend
 * POST /v1/auth/parent/password-reset/request envia email via Supabase.
 *
 * Toast de erro generico independente do status code (defesa anti-
 * enumeration: nao revela se o email existe ou nao). Tela de "enviado"
 * sempre aparece em sucesso, mesmo que email nao exista no DB - msg
 * comeca com "Se existir uma conta...".
 */
export default function ForgotPasswordPage() {
  const t = useTranslations('forgot_password');
  const { toast } = useToast();
  const [isLoading, setIsLoading] = React.useState(false);
  const [sent, setSent] = React.useState(false);

  const schema = React.useMemo(
    () =>
      z.object({
        email: z.string().email(t('email_invalid')).min(1, t('email_required')),
      }),
    [t]
  );

  type FormData = z.infer<typeof schema>;

  const form = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: { email: '' },
  });

  const onSubmit = async (data: FormData) => {
    setIsLoading(true);
    try {
      await authApi.requestPasswordReset(data.email);
      setSent(true);
    } catch {
      // Backend ja' devolve sempre 200 (anti-enumeration), entao chegar
      // aqui significa erro de rede ou servidor down.
      toast({
        type: 'error',
        title: t('toast_error_title'),
        description: t('toast_error_desc'),
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-ocean-100 to-grape-100 flex items-center justify-center p-4">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <div className="flex justify-end">
            <LanguageSwitcher />
          </div>
          <CardTitle className="text-2xl font-bold text-center">{t('title')}</CardTitle>
          <p className="text-center text-gray-600">{t('subtitle')}</p>
        </CardHeader>
        <CardContent>
          {sent ? (
            <div className="text-center space-y-4">
              <div className="text-6xl">📧</div>
              <h3 className="text-lg font-semibold">{t('sent_title')}</h3>
              <p className="text-sm text-gray-600">{t('sent_body')}</p>
              <Button variant="outline" asChild>
                <Link href="/login" className="inline-flex items-center">
                  <ArrowLeft className="mr-2 h-4 w-4" />
                  {t('sent_back')}
                </Link>
              </Button>
            </div>
          ) : (
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
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

              <Button
                type="submit"
                variant="ocean"
                size="lg"
                className="w-full"
                disabled={isLoading}
              >
                {isLoading ? t('submitting') : t('submit')}
              </Button>

              <div className="text-center pt-2">
                <Link
                  href="/login"
                  className="inline-flex items-center text-sm text-gray-600 hover:text-gray-900 hover:underline"
                >
                  <ArrowLeft className="mr-1 h-4 w-4" />
                  {t('back_to_login')}
                </Link>
              </div>
            </form>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
