'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation, useQueryClient } from '@tanstack/react-query';
import { ArrowLeft, Save } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { AvatarPicker } from '@/components/avatar-picker';
import { childrenApi } from '@/lib/api/children';
import { getApiErrorMessage } from '@/lib/api/client';
import { config } from '@/lib/config';

const childSchema = z.object({
  name: z.string()
    .min(1, 'Nome obrigatório')
    .max(config.limits.childNameMaxLength, `Nome deve ter no máximo ${config.limits.childNameMaxLength} caracteres`),
  // username e' o login da crianca em /crianca. Lowercase + digitos + hifen,
  // 3-30 chars. Mesmo padrao validado no backend (schemas/children.py).
  username: z.string()
    .min(3, 'Mínimo 3 caracteres')
    .max(30, 'Máximo 30 caracteres')
    .regex(/^[a-z0-9-]+$/, 'Apenas letras minúsculas, números e hífens'),
  age: z.number()
    .min(6, 'Idade mínima: 6 anos')
    .max(12, 'Idade máxima: 12 anos'),
  avatar_id: z.string().min(1, 'Avatar obrigatório'),
  pin: z.string()
    .length(4, 'PIN deve ter 4 dígitos')
    .regex(/^\d{4}$/, 'PIN deve conter apenas números')
    .optional()
    .or(z.literal('')),
  daily_limit_minutes: z.number()
    .min(config.limits.minDailyLimitMinutes, `Mínimo: ${config.limits.minDailyLimitMinutes} min`)
    .max(config.limits.maxDailyLimitMinutes, `Máximo: ${config.limits.maxDailyLimitMinutes} min`),
});

type ChildFormData = z.infer<typeof childSchema>;

/**
 * Página para criar novo filho.
 * Form com validação + avatar picker + configuração de PIN e limite diário.
 */
export default function CreateChildPage() {
  const router = useRouter();
  const queryClient = useQueryClient();
  const [selectedAvatar, setSelectedAvatar] = useState<string>('');

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
            Voltar
          </Button>
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Adicionar filho</h1>
          <p className="text-gray-600">
            Configure o perfil do seu filho para ele usar o Aprendizagem
          </p>
        </div>
      </div>

      <form onSubmit={form.handleSubmit(handleSubmit)} className="space-y-6">
        {/* Card principal */}
        <Card className="p-6 space-y-6">
          {/* Nome */}
          <div>
            <label htmlFor="name" className="block text-sm font-medium text-gray-700 mb-2">
              Nome ou apelido *
            </label>
            <input
              {...form.register('name')}
              type="text"
              id="name"
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              placeholder="Como seu filho quer ser chamado?"
            />
            {form.formState.errors.name && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.name.message}
              </p>
            )}
            <p className="mt-1 text-xs text-gray-500">
              Use um apelido, não precisa ser o nome completo
            </p>
          </div>

          {/* Username (login direto) */}
          <div>
            <label htmlFor="username" className="block text-sm font-medium text-gray-700 mb-2">
              Nome de utilizador *
            </label>
            <input
              {...form.register('username')}
              type="text"
              id="username"
              autoCapitalize="none"
              autoCorrect="off"
              spellCheck={false}
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
              placeholder="ex: valentina2026"
            />
            {form.formState.errors.username && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.username.message}
              </p>
            )}
            <p className="mt-1 text-xs text-gray-500">
              Este será o nome de login da criança. Ex: valentina2026
            </p>
          </div>

          {/* Idade */}
          <div>
            <label htmlFor="age" className="block text-sm font-medium text-gray-700 mb-2">
              Idade *
            </label>
            <select
              {...form.register('age', { valueAsNumber: true })}
              id="age"
              className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent"
            >
              {Array.from({ length: 7 }, (_, i) => i + 6).map(age => (
                <option key={age} value={age}>
                  {age} anos
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
              Avatar *
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
              PIN de segurança (opcional)
            </label>
            <input
              {...form.register('pin')}
              type="password"
              id="pin"
              maxLength={4}
              className="w-32 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-2 focus:ring-purple-500 focus:border-transparent font-mono text-center text-lg"
              placeholder="••••"
            />
            {form.formState.errors.pin && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.pin.message}
              </p>
            )}
            <p className="mt-1 text-xs text-gray-500">
              4 dígitos para proteger o acesso. Deixe vazio se não quiser PIN.
            </p>
          </div>

          {/* Limite diário */}
          <div>
            <label htmlFor="daily_limit_minutes" className="block text-sm font-medium text-gray-700 mb-2">
              Tempo diário limite *
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
                {form.watch('daily_limit_minutes')} min
              </span>
            </div>
            {form.formState.errors.daily_limit_minutes && (
              <p className="mt-1 text-sm text-red-600">
                {form.formState.errors.daily_limit_minutes.message}
              </p>
            )}
            <p className="mt-1 text-xs text-gray-500">
              Tempo máximo por dia que seu filho pode usar o app
            </p>
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
              Cancelar
            </Button>
          </Link>
          <Button
            type="submit"
            disabled={createChildMutation.isPending}
            className="bg-purple-600 hover:bg-purple-700"
          >
            {createChildMutation.isPending ? (
              'Criando...'
            ) : (
              <>
                <Save className="w-4 h-4 mr-2" />
                Criar perfil
              </>
            )}
          </Button>
        </div>
      </form>
    </div>
  );
}