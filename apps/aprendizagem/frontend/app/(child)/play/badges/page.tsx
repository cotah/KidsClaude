'use client';

import { useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { useQuery } from '@tanstack/react-query';
import type { Route } from 'next';
import { ArrowLeft, Lock } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Mascot, MascotBubble } from '@/components/ui/mascot-bubble';
import { apiClient } from '@/lib/api/client';
import useAppStore from '@/lib/store/app-store';
import { cn } from '@/lib/utils';

// Catalogo das 12 badges seedadas no backend (migrations/002_seed_data.sql).
// So' code + icon ficam aqui (icone nao traduz). name/description vem de
// badges_page.<code>.{name,description} no JSON pra suportar EN/PT.
// Codes batem 1:1 com o seed - mudancas aqui exigem mudanca tambem em
// badges_page no en/pt.json. Quando o backend tiver endpoint /v1/badges,
// trocar por chamada e remover esta lista.
const BADGE_CATALOG: Array<{ code: string; icon: string }> = [
  { code: 'FIRST_STEPS', icon: '👣' },
  { code: 'QUICK_LEARNER', icon: '⚡' },
  { code: 'LESSON_MASTER', icon: '🎓' },
  { code: 'CURIOUS_MIND', icon: '🔭' },
  { code: 'PROMPT_PRO', icon: '🪄' },
  { code: 'STREAK_3', icon: '🔥' },
  { code: 'STREAK_7', icon: '📅' },
  { code: 'STREAK_30', icon: '📆' },
  { code: 'CHALLENGE_ACE', icon: '🎯' },
  { code: 'STORYTELLER', icon: '📚' },
  { code: 'LEVEL_5', icon: '⭐' },
  { code: 'LEVEL_10', icon: '🌟' },
];

/**
 * Mural de conquistas. Mostra catalogo completo das 12 badges com lock
 * overlay nas nao-desbloqueadas. Le badges reais via
 * GET /v1/children/{id}/badges (AnyAuth - crianca so ve as proprias).
 */
export default function BadgesPage() {
  const router = useRouter();
  const t = useTranslations('badges_page');
  const { currentChild } = useAppStore();

  // Endpoint devolve envelope { badges: [{code, ...}] }. Constroi Set
  // de codes pra lookup O(1) ao montar cada card do catalogo.
  const { data: badgesData, isLoading } = useQuery({
    queryKey: ['child-badges', currentChild?.id],
    queryFn: () =>
      apiClient.get<{ badges: Array<{ code: string }> }>(
        `children/${currentChild!.id}/badges`
      ),
    enabled: !!currentChild?.id,
  });

  const unlockedCodes = useMemo(
    () => new Set((badgesData?.badges ?? []).map((b) => b.code)),
    [badgesData]
  );
  const unlockedCount = unlockedCodes.size;

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
