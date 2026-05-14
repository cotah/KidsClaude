'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { useMutation, useQuery, useQueryClient } from '@tanstack/react-query';
import { ArrowLeft, Save, Trash2 } from 'lucide-react';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { AvatarPicker } from '@/components/avatar-picker';
import { useToast } from '@/components/ui/toast';
import { childrenApi } from '@/lib/api/children';
import { getApiErrorMessage } from '@/lib/api/client';
import { config } from '@/lib/config';

const editSchema = z.object({
  name: z
    .string()
    .min(1, 'Nome obrigatorio')
    .max(config.limits.childNameMaxLength, `Maximo ${config.limits.childNameMaxLength} caracteres`),
  username: z
    .string()
    .min(3, 'Mínimo 3 caracteres')
    .max(30, 'Máximo 30 caracteres')
    .regex(/^[a-z0-9-]+$/, 'Apenas letras minúsculas, números e hífens'),
  age: z.number().min(6).max(12),
  avatar_id: z.string().min(1, 'Avatar obrigatorio'),
  // PIN deixado vazio = nao alterar; "0000" = remover (tratado no submit).
  pin: z
    .string()
    .regex(/^(\d{4})?$/, 'PIN deve ter 4 digitos')
    .optional()
    .or(z.literal('')),
  daily_limit_minutes: z
    .number()
    .min(config.limits.minDailyLimitMinutes)
    .max(config.limits.maxDailyLimitMinutes),
});

type EditFormData = z.infer<typeof editSchema>;

export default function EditChildPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const queryClient = useQueryClient();
  const { toast } = useToast();
  const childId = params.id;

  const [selectedAvatar, setSelectedAvatar] = useState('');
  const [confirmingDelete, setConfirmingDelete] = useState(false);

  const { data: child, isLoading } = useQuery({
    queryKey: ['child', childId],
    queryFn: () => childrenApi.get(childId),
    enabled: !!childId,
  });

  const form = useForm<EditFormData>({
    resolver: zodResolver(editSchema),
    defaultValues: {
      name: '',
      username: '',
      age: 6,
      avatar_id: '',
      pin: '',
      daily_limit_minutes: config.limits.defaultDailyLimitMinutes,
    },
  });

  // Preenche o formulario quando os dados chegam.
  useEffect(() => {
    if (child) {
      form.reset({
        name: child.name,
        // child.username pode vir undefined em registros antigos (pre-006);
        // o pai e' forcado a definir um aqui para passar a validacao.
        username: child.username ?? '',
        age: child.age,
        avatar_id: child.avatar_id,
        pin: '',
        daily_limit_minutes: child.daily_limit_minutes,
      });
      setSelectedAvatar(child.avatar_id);
    }
  }, [child, form]);

  const updateMutation = useMutation({
    mutationFn: (data: EditFormData) => {
      const payload: Record<string, unknown> = {
        name: data.name,
        username: data.username,
        age: data.age,
        avatar_id: data.avatar_id,
        daily_limit_minutes: data.daily_limit_minutes,
      };
      if (data.pin) payload.pin = data.pin;
      return childrenApi.update(childId, payload);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['children'] });
      queryClient.invalidateQueries({ queryKey: ['child', childId] });
      // Cards do /dashboard tambem ficam stale quando se edita nome/avatar.
      queryClient.invalidateQueries({ queryKey: ['parent-dashboard'] });
      toast({ type: 'success', title: 'Alteracoes salvas' });
      router.push(`/children/${childId}` as any);
    },
    onError: (err) => {
      toast({
        type: 'error',
        title: 'Nao consegui salvar',
        description: getApiErrorMessage(err),
      });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: () => childrenApi.delete(childId),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['children'] });
      queryClient.invalidateQueries({ queryKey: ['parent-dashboard'] });
      toast({ type: 'success', title: 'Perfil removido' });
      router.push('/dashboard');
    },
    onError: (err) => {
      toast({
        type: 'error',
        title: 'Nao consegui remover',
        description: getApiErrorMessage(err),
      });
      setConfirmingDelete(false);
    },
  });

  if (isLoading || !child) {
    return (
      <Card className="animate-pulse p-8">
        <div className="mb-4 h-4 w-64 rounded bg-gray-200" />
        <div className="h-4 w-48 rounded bg-gray-200" />
      </Card>
    );
  }

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div className="flex items-center space-x-4">
        <Link href={`/children/${childId}` as any}>
          <Button variant="ghost" size="sm">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Voltar
          </Button>
        </Link>
        <div>
          <h1 className="text-2xl font-bold text-gray-900">Editar perfil</h1>
          <p className="text-gray-600">Atualize informacoes ou remova este perfil.</p>
        </div>
      </div>

      <form
        onSubmit={form.handleSubmit((data) =>
          updateMutation.mutate({ ...data, avatar_id: selectedAvatar })
        )}
        className="space-y-6"
      >
        <Card className="space-y-6 p-6">
          <div>
            <label htmlFor="name" className="mb-2 block text-sm font-medium text-gray-700">
              Nome ou apelido
            </label>
            <input
              {...form.register('name')}
              type="text"
              id="name"
              className="w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-transparent focus:outline-none focus:ring-2 focus:ring-purple-500"
            />
            {form.formState.errors.name && (
              <p className="mt-1 text-sm text-red-600">{form.formState.errors.name.message}</p>
            )}
          </div>

          <div>
            <label htmlFor="username" className="mb-2 block text-sm font-medium text-gray-700">
              Nome de utilizador
            </label>
            <input
              {...form.register('username')}
              type="text"
              id="username"
              autoCapitalize="none"
              autoCorrect="off"
              spellCheck={false}
              className="w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-transparent focus:outline-none focus:ring-2 focus:ring-purple-500"
            />
            {form.formState.errors.username && (
              <p className="mt-1 text-sm text-red-600">{form.formState.errors.username.message}</p>
            )}
            <p className="mt-1 text-xs text-gray-500">
              Usado para login direto em /crianca. Letras minúsculas, números e hífens.
            </p>
          </div>

          <div>
            <label htmlFor="age" className="mb-2 block text-sm font-medium text-gray-700">
              Idade
            </label>
            <select
              {...form.register('age', { valueAsNumber: true })}
              id="age"
              className="w-full rounded-md border border-gray-300 px-3 py-2 shadow-sm focus:border-transparent focus:outline-none focus:ring-2 focus:ring-purple-500"
            >
              {Array.from({ length: 7 }, (_, i) => i + 6).map((age) => (
                <option key={age} value={age}>
                  {age} anos
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="mb-3 block text-sm font-medium text-gray-700">Avatar</label>
            <AvatarPicker
              selectedId={selectedAvatar}
              onSelect={(avatarId: string) => {
                setSelectedAvatar(avatarId);
                form.setValue('avatar_id', avatarId);
              }}
            />
          </div>

          <div>
            <label htmlFor="pin" className="mb-2 block text-sm font-medium text-gray-700">
              Novo PIN (opcional)
            </label>
            <input
              {...form.register('pin')}
              type="password"
              id="pin"
              maxLength={4}
              placeholder={child.pin_set ? '••••' : 'Sem PIN configurado'}
              className="w-32 rounded-md border border-gray-300 px-3 py-2 text-center font-mono text-lg shadow-sm focus:border-transparent focus:outline-none focus:ring-2 focus:ring-purple-500"
            />
            {form.formState.errors.pin && (
              <p className="mt-1 text-sm text-red-600">{form.formState.errors.pin.message}</p>
            )}
            <p className="mt-1 text-xs text-gray-500">
              Deixe vazio para manter o PIN atual.
            </p>
          </div>

          <div>
            <label
              htmlFor="daily_limit_minutes"
              className="mb-2 block text-sm font-medium text-gray-700"
            >
              Tempo diario limite
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
              <span className="w-20 text-sm text-gray-600">
                {form.watch('daily_limit_minutes')} min
              </span>
            </div>
          </div>
        </Card>

        <div className="flex justify-between">
          <Button
            type="button"
            variant="outline"
            onClick={() => setConfirmingDelete(true)}
            className="border-red-300 text-red-600 hover:bg-red-50"
          >
            <Trash2 className="mr-2 h-4 w-4" />
            Remover perfil
          </Button>
          <Button
            type="submit"
            disabled={updateMutation.isPending}
            className="bg-purple-600 hover:bg-purple-700"
          >
            {updateMutation.isPending ? (
              'Salvando...'
            ) : (
              <>
                <Save className="mr-2 h-4 w-4" />
                Salvar
              </>
            )}
          </Button>
        </div>
      </form>

      {confirmingDelete && (
        <Card className="space-y-4 border-red-300 bg-red-50 p-6">
          <h2 className="text-lg font-bold text-red-900">Remover {child.name}?</h2>
          <p className="text-sm text-red-800">
            Esta acao apaga todo o progresso e historico de conversa deste perfil.
            Nao da pra desfazer.
          </p>
          <div className="flex justify-end gap-2">
            <Button
              variant="outline"
              onClick={() => setConfirmingDelete(false)}
              disabled={deleteMutation.isPending}
            >
              Cancelar
            </Button>
            <Button
              variant="ghost"
              onClick={() => deleteMutation.mutate()}
              disabled={deleteMutation.isPending}
              className="bg-red-600 text-white hover:bg-red-700"
            >
              {deleteMutation.isPending ? 'Removendo...' : 'Sim, remover'}
            </Button>
          </div>
        </Card>
      )}
    </div>
  );
}
