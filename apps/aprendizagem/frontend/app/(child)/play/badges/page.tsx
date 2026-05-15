'use client';

import { useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import type { Route } from 'next';
import { ArrowLeft, Lock } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Mascot, MascotBubble } from '@/components/ui/mascot-bubble';
import useAppStore from '@/lib/store/app-store';
import { cn } from '@/lib/utils';

// Catalogo das 12 badges seedadas no backend (migrations/002_seed_data.sql).
// So' code + icon ficam aqui (icone nao traduz). name/description vem de
// badges_page.<code>.{name,description} no JSON pra suportar EN/PT.
// Quando o backend tiver endpoint /v1/badges, trocar por chamada e
// remover esta lista.
const BADGE_CATALOG: Array<{ code: string; icon: string }> = [
  { code: 'FIRST_STEPS', icon: '👣' },
  { code: 'CURIOUS_MIND', icon: '🔭' },
  { code: 'STREAK_3', icon: '🔥' },
  { code: 'STREAK_7', icon: '📅' },
  { code: 'CHALLENGE_ACE', icon: '🎯' },
  { code: 'STORYTELLER', icon: '📚' },
  { code: 'POLITE_TALKER', icon: '🤝' },
  { code: 'SAFETY_FIRST', icon: '🛡️' },
  { code: 'PROMPT_MASTER', icon: '🪄' },
  { code: 'LEVEL_5', icon: '⭐' },
  { code: 'LEVEL_10', icon: '🌟' },
  { code: 'EARLY_BIRD', icon: '🌅' },
];

/**
 * Mural de conquistas. Mostra catalogo completo das 12 badges. A chamada
 * para dashboardApi.getDashboard foi removida porque ela exige token de
 * pai e era chamada em sessao de crianca, gerando 401 ruidoso. Quando o
 * backend tiver endpoint /v1/children/{id}/badges, plugar aqui.
 */
export default function BadgesPage() {
  const router = useRouter();
  const t = useTranslations('badges_page');
  const { currentChild: _currentChild } = useAppStore();

  // Sem dashboard call em modo crianca - todas aparecem como bloqueadas
  // ate' termos endpoint child-aware.
  const unlockedCodes = useMemo(() => new Set<string>(), []);
  const unlockedCount = unlockedCodes.size;
  const isLoading = false;

  return (
    <div className="mx-auto max-w-4xl space-y-6 p-4">
      <Card className="flex items-center justify-between p-4">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => router.push('/play' as Route)}
        >
          <ArrowLeft className="mr-1 h-4 w-4" />
          {t('back')}
        </Button>
        <h1 className="text-xl font-bold text-gray-800">{t('title')}</h1>
        <div className="text-sm font-medium text-grape-600">
          {t('count', { n: unlockedCount, total: BADGE_CATALOG.length })}
        </div>
      </Card>

      <Card className="flex items-center gap-4 p-4">
        <Mascot size="md" expression="happy" />
        <MascotBubble variant="encouraging" className="flex-1">
          {unlockedCount === 0
            ? t('mascot_empty')
            : t('mascot_has', { n: unlockedCount })}
        </MascotBubble>
      </Card>

      {isLoading ? (
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4">
          {Array.from({ length: 8 }).map((_, i) => (
            <div key={i} className="h-32 animate-pulse rounded-xl bg-gray-200" />
          ))}
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-3 sm:grid-cols-3 md:grid-cols-4">
          {BADGE_CATALOG.map((badge) => {
            const unlocked = unlockedCodes.has(badge.code);
            const name = t(`${badge.code}.name`);
            const description = t(`${badge.code}.description`);
            return (
              <div
                key={badge.code}
                className={cn(
                  'flex flex-col items-center gap-2 rounded-xl border-2 p-4 text-center transition-all',
                  unlocked
                    ? 'border-sunny-300 bg-sunny-50'
                    : 'border-gray-200 bg-gray-50 opacity-70 grayscale'
                )}
              >
                <div className="relative text-4xl">
                  {badge.icon}
                  {!unlocked && (
                    <span className="absolute -bottom-1 -right-1 rounded-full bg-gray-300 p-1">
                      <Lock className="h-3 w-3 text-gray-600" />
                    </span>
                  )}
                </div>
                <p className="text-sm font-bold text-gray-800">{name}</p>
                <p className="text-xs leading-tight text-gray-600">{description}</p>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
