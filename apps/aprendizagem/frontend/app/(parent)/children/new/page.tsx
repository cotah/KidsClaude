'use client';

import * as React from 'react';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { useTranslations } from 'next-intl';
import { ArrowLeft, Save } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { AvatarPicker } from '@/components/avatar-picker';
import { childrenApi } from '@/lib/api/children';
import { getApiErrorMessage } from '@/lib/api/client';
import { config } from '@/lib/config';

/**
 * Página para criar novo filho.
 * Form com validação + avatar picker + configuração de PIN e limite diário.
 */
export default function CreateChildPage() {
  const t = useTranslations('children_new');
  const router = useRouter();
  const queryClient = useQueryClient();
  const [selectedAvatar, setSelectedAvatar] = useState<string>('');

  // Schema reconstroi com t no useMemo pra que validation messages mudem
  // com o locale. Antes era global com strings PT hardcoded.
  const childSchema = React.useMemo(
    () =>
      z.object({
        name: z
          .string()
          .min(1, t('name_required'))
          .max(config.limits.childNameMaxLength, t('name_max', { max: config.limits.childNameMaxLength })),
        username: z
          .string()
          .min(3, t('username_min'))
          .max(30, t('username_max'))
          .regex(/^[a-z0-9-]+$/, t('username_format')),
        age: z.number().min(6, t('age_min')).max(12, t('age_max')),
        avatar_id: z.string().min(1, t('avatar_required')),
        pin: z
          .string()
          .length(4, t('pin_length'))
          .regex(/^\d{4}$/, t('pin_digits'))
          .optional()
          .or(z.literal('')),
        daily_limit_minutes: z
          .number()
          .min(config.limits.minDailyLimitMinutes, t('daily_limit_min', { min: config.limits.minDailyLimitMinutes }))
          .max(config.limits.maxDailyLimitMinutes, t('daily_limit_max', { max: config.limits.maxDailyLimitMinutes })),
      }),
    [t]
  );

  type ChildFormData = z.infer<typeof childSchema>;

  const form = useForm<ChildFormData>({
    resolver: zodResolver(childSchema),
    defaultValues: {
      name: '',
      username: '',
      age: 6,
      avatar_id: '',
      pin: '',
      daily_limit_minutes: config.limits.defaultDailyLimitMinutes,
    },
  });

  // Mutação para criar criança
  const createChildMutation = useMutation({
    mutationFn: (data: ChildFormData) => {
      // Filtrar PIN vazio
      const payload = {
        ...data,
        pin: data.pin || undefined,
      };
      return childrenApi.create(payload);
    },
    onSuccess: (newChild) => {
      // Invalida ambos os caches: 'children' (lista usada em /select) e
      // 'parent-dashboard' (cards do /dashboard). Sem invalidar o segundo,
      // o dashboard fica stale e o pai precisa recarregar a pagina pra
      // ver o filho novo.
      queryClient.invalidateQueries({ queryKey: ['children'] });
      queryClient.invalidateQueries({ queryKey: ['parent-dashboard'] });
      router.push(`/children/${newChild.id}`);
    },
    onError: (error) => {
      console.error('Erro ao criar filho:', getApiErrorMessage(error));
    },
  });

  const handleSubmit = async (data: ChildFormData) => {
    if (!selectedAvatar) {
      form.setError('avatar_id', { message: 'Selecione um avatar' });
      return;
    }

    createChildMutation.mutate({
      ...data,
      avatar_id: selectedAvatar,
    });
  };

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center space-x-4">
        <Link href="/dashboard">
          <Button variant="ghost" size="sm">
            <ArrowLeft className="w-4 h-4 mr-2" />
            {t('back')}
          </Button>
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">{t('title')}</h1>
          <p className="text-gray-600">{t('subtitle')}</p>
        </div>
      </div>

      <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-6">
        {/* Card principal */}
        <Card className="p-6 space-y-6">
          {/* Nome */}
          <div>
            <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
              {t('name_label')}
            </label>
            <input
              {...form.register('name')}
              type="text"
              id="name"
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              placeholder={t('name_placeholder')}
            />
            {form.formState.errors.name && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.name.message}
              </p>
            )}
            <p className="mt-1 text-xs text-gray-500">{t('name_hint')}</p>
          </div>

          {/* Username (login direto) */}
          <div>
            <label htmlFor="username" className="block text-sm font-medium text-gray-700 mb-2">
              {t('username_label')}
            </label>
            <input
              {...form.register('username')}
              type="text"
              id="username"
              autoCapitalize="none"
              autoCorrect="off"
              spellCheck={false}
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              placeholder={t('username_placeholder')}
            />
            {form.formState.errors.username && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.username.message}
              </p>
            )}
            <p className="mt-1 text-xs text-gray-500">{t('username_hint')}</p>
          </div>

          {/* Idade */}
          <div>
            <label htmlFor="age" className="block text-sm font-medium text-gray-700 mb-2">
              {t('age_label')}
            </label>
            <select
              {...form.register('age', { valueAsNumber: true })}
              id="age"
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            >
              {Array.from({ length: 7 }, (_, i) => i + 6).map(age => (
                <option key={age} value={age}>
                  {t('age_unit', { age })}
                </option>
              ))}
            </select>
            {form.formState.errors.age && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.age.message}
              </p>
            )}
          </div>

          {/* Avatar */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-3">
              {t('avatar_label')}
            </label>
            <AvatarPicker
              selectedId={selectedAvatar}
              onSelect={(avatarId: string) => {
                setSelectedAvatar(avatarId);
                form.setValue('avatar_id', avatarId);
                form.clearErrors('avatar_id');
              }}
            />
            {form.formState.errors.avatar_id && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.avatar_id.message}
              </p>
            )}
          </div>

          {/* PIN */}
          <div>
            <label htmlFor="pin" className="block text-sm font-medium text-gray-700 mb-2">
              {t('pin_label')}
            </label>
            <input
              {...form.register('pin')}
              type="password"
              id="pin"
              maxLength={4}
              className="w-32 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent font-mono text-center text-lg"
              placeholder={t('pin_placeholder')}
            />
            {form.formState.errors.pin && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.pin.message}
              </p>
            )}
            <p className="mt-1 text-xs text-gray-500">{t('pin_hint')}</p>
          </div>

          {/* Limite diário */}
          <div>
            <label htmlFor="daily_limit_minutes" className="block text-sm font-medium text-gray-700 mb-2">
              {t('daily_limit_label')}
            </label>
            <div className="flex items-center space-x-3">
              <input
                {...form.register('daily_limit_minutes', { valueAsNumber: true })}
                type="range"
                id="daily_limit_minutes"
                min={config.limits.minDailyLimitMinutes}
                max={config.limits.maxDailyLimitMinutes}
                step={5}
                className="flex-1"
              />
              <span className="text-sm text-gray-600 w-20">
                {t('daily_limit_unit', { minutes: form.watch('daily_limit_minutes') })}
              </span>
            </div>
            {form.formState.errors.daily_limit_minutes && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.daily_limit_minutes.message}
              </p>
            )}
            <p className="mt-1 text-xs text-gray-500">{t('daily_limit_hint')}</p>
          </div>
        </Card>

        {/* Erro geral */}
        {createChildMutation.error && (
          <Card className="p-4 bg-red-50 border-red-200">
            <p className="text-sm text-red-600">
              {getApiErrorMessage(createChildMutation.error)}
            </p>
          </Card>
        )}

        {/* Botões de ação */}
        <div className="flex justify-end space-x-3">
          <Link href="/dashboard">
            <Button type="button" variant="outline">
              {t('cancel')}
            </Button>
          </Link>
          <Button
            type="submit"
            disabled={createChildMutation.isPending}
            className="bg-purple-600 hover:bg-purple-700"
          >
            {createChildMutation.isPending ? (
              t('submitting')
            ) : (
              <>
                <Save className="w-4 h-4 mr-2" />
                {t('submit')}
              </>
            )}
          </Button>
        </div>
      </form>
    </div>
  );
}