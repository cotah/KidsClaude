'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { Card } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { useToast } from '@/components/ui/toast';
import { childrenApi } from '@/lib/api/children';
import { getApiErrorMessage } from '@/lib/api/client';
import { config } from '@/lib/config';

interface DailyLimitEditorProps {
  childId: string;
  initial: number;
}

/**
 * Editor inline do daily_limit_minutes na pagina de perfil do filho.
 * Range 5-180 (mesmos limites do form de criacao), PATCH /v1/children/{id}.
 * Botao "Salvar" so' habilitado quando o valor mudou em relacao ao inicial.
 * Apos sucesso, router.refresh() pra que o Server Component releia o limite
 * do backend (e o card "Tempo hoje" mostre o novo limit no progress bar).
 */
export function DailyLimitEditor({ childId, initial }: DailyLimitEditorProps) {
  const t = useTranslations('children_detail');
  const router = useRouter();
  const { toast } = useToast();
  const [value, setValue] = useState(initial);
  const [saving, setSaving] = useState(false);

  const dirty = value !== initial;

  const handleSave = async () => {
    if (!dirty || saving) return;
    setSaving(true);
    try {
      await childrenApi.update(childId, { daily_limit_minutes: value });
      toast({
        type: 'success',
        title: t('limit_saved_title'),
        description: t('limit_saved_desc', { minutes: value }),
      });
      router.refresh();
    } catch (err) {
      toast({
        type: 'error',
        title: t('limit_error_title'),
        description: getApiErrorMessage(err),
      });
    } finally {
      setSaving(false);
    }
  };

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-4">
        <p className="text-sm font-medium text-gray-700">{t('limit_title')}</p>
        <span className="text-sm font-semibold text-gray-900">
          {t('limit_unit', { minutes: value })}
        </span>
      </div>
      <input
        type="range"
        min={config.limits.minDailyLimitMinutes}
        max={config.limits.maxDailyLimitMinutes}
        step={5}
        value={value}
        onChange={(e) => setValue(Number(e.target.value))}
        disabled={saving}
        className="w-full"
      />
      <div className="flex items-center justify-between mt-2 text-xs text-gray-500">
        <span>{config.limits.minDailyLimitMinutes} min</span>
        <span>{config.limits.maxDailyLimitMinutes} min</span>
      </div>
      <div className="mt-4 flex justify-end">
        <Button
          variant="sunny"
          size="sm"
          onClick={handleSave}
          disabled={!dirty || saving}
        >
          {saving ? t('limit_saving') : t('limit_save')}
        </Button>
      </div>
    </Card>
  );
}
