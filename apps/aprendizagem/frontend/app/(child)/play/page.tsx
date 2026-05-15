'use client';

import * as React from 'react';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { stagesApi } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { XPProgress, StreakProgress } from '@/components/ui/progress';
import { Mascot, MascotBubble } from '@/components/ui/mascot-bubble';
import { StageGrid } from '@/components/ui/stage-grid';
import useAppStore from '@/lib/store/app-store';
import { calculateLevelInfo } from '@/lib/utils';

/**
 * Hub principal da criança - agora com 4-stage curriculum conforme spec redesign seção 7.1
 */
export default function PlayPage() {
  const t = useTranslations('play');
  const { currentChild } = useAppStore();
  const [greeting, setGreeting] = React.useState('');

  // Buscar stages e progresso. TanStack Query v5: isPending = sem dados +
  // ainda buscando; isError + error = falha na request. isLoading e' alias
  // legado e fica false enquanto enabled=false (currentChild nao hidratou
  // ainda do Zustand persist), o que deixava o componente cair no else
  // mostrando branco no primeiro render.
  const {
    data: stagesData,
    isPending: isStagesPending,
    isError: isStagesError,
    error: stagesError,
  } = useQuery({
    queryKey: ['stages', currentChild?.id],
    queryFn: () => stagesApi.getStages(),
    enabled: !!currentChild,
    staleTime: 30000, // 30s cache para refletir progresso
  });

  React.useEffect(() => {
    if (currentChild) {
      const hour = new Date().getHours();
      if (hour < 12) {
        setGreeting(t('good_morning'));
      } else if (hour < 18) {
        setGreeting(t('good_afternoon'));
      } else {
        setGreeting(t('good_evening'));
      }
    }
  }, [currentChild, t]);

  if (!currentChild) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="text-6xl">🤔</div>
          <p className="text-kid-lg text-gray-600">{t('guard_pick_profile')}</p>
          <Button variant="sunny" size="kid-lg" asChild>
            <Link href="/select">{t('guard_pick_button')}</Link>
          </Button>
        </div>
      </div>
    );
  }

  // currentChild pode chegar com xp/level undefined quando o login devolve
  // o shape incompleto. Number(undefined) e' NaN, que estoura na barra de XP
  // e nos textos do header - coage explicitamente.
  const levelInfo = calculateLevelInfo(Number(currentChild.xp) || 0);

  return (
    <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100">
      {/* Header com informações da criança */}
      <header className="bg-white/80 backdrop-blur-sm border-b border-sunny-200 p-4">
        <div className="container mx-auto max-w-4xl">
          <div className="flex items-center justify-between">
            <div className="flex items-center space-x-4">
              <div className="text-kid-2xl font-bold text-gray-800">
                {greeting}, {currentChild.name}!
              </div>
              {currentChild.streak_days > 0 && (
                <div className="flex items-center space-x-2">
                  <StreakProgress days={currentChild.streak_days} />
                  <span className="text-kid-sm font-medium text-sunset-600">
                    {currentChild.streak_days} dias
                  </span>
                </div>
              )}
            </div>
            <Button
              variant="ghost"
              size="kid-sm"
              asChild
              className="text-gray-600 hover:text-gray-800"
            >
              <Link href="/play/switch-profile">{t('switch_profile')}</Link>
            </Button>
          </div>

          {/* Barra de XP */}
          <div className="mt-4">
            <XPProgress
              current={levelInfo.xp_current}
              max={levelInfo.xp_required}
              level={levelInfo.current}
              colorScheme="sunny"
            />
          </div>
        </div>
      </header>

      <main className="container mx-auto max-w-4xl p-6 space-y-8">
        {/* Mascote com saudação */}
        <section className="flex flex-col lg:flex-row items-center gap-8">
          <Mascot size="lg" expression="happy" />
          <MascotBubble variant="encouraging" className="flex-1">
            <div className="space-y-2">
              <p>
                {t.rich('mascot_level_intro', {
                  level: levelInfo.current,
                  name: levelInfo.name,
                  b: (chunks) => <strong>{chunks}</strong>,
                })}
              </p>
              {currentChild.streak_days > 0 ? (
                <p>
                  {t.rich('mascot_streak', {
                    days: currentChild.streak_days,
                    b: (chunks) => <strong>{chunks}</strong>,
                  })}
                </p>
              ) : (
                <p>{t('mascot_no_streak')}</p>
              )}
            </div>
          </MascotBubble>
        </section>

        {/* Stages Grid */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-kid-2xl font-bold text-gray-800 mb-2">
              {t('section_path_title')}
            </h2>
            <p className="text-kid-base text-gray-600">{t('section_path_subtitle')}</p>
          </div>

          {/* Ordem do branch: error > pending > sem dados/sem stages > grid.
              isPending pega tanto o "ainda nao buscou" (enabled=false durante
              hidratacao do Zustand) quanto o "buscando agora", evitando o
              flash de branco entre o primeiro render e a chegada dos dados. */}
          {isStagesError ? (
            <div className="text-center text-red-600 bg-white/80 rounded-kid-lg p-6">
              <p className="text-kid-base font-medium mb-2">{t('stages_load_error_title')}</p>
              <p className="text-kid-sm text-red-500">
                {stagesError instanceof Error ? stagesError.message : t('stages_load_error_unknown')}
              </p>
            </div>
          ) : isStagesPending || !stagesData ? (
            <div className="space-y-8">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {Array.from({ length: 4 }).map((_, index) => (
                  <div key={index} className="h-56 rounded-kid-lg bg-gray-200 animate-pulse" />
                ))}
              </div>
              <div className="flex justify-center">
                <div className="w-full max-w-md h-48 rounded-kid-lg bg-gradient-to-br from-purple-200 to-yellow-200 animate-pulse" />
              </div>
              <p className="text-center text-kid-sm text-gray-500">{t('loading')}</p>
            </div>
          ) : !stagesData.stages || stagesData.stages.length === 0 ? (
            <div className="text-center text-gray-600 bg-white/60 rounded-kid-lg p-6">
              <p className="text-kid-base font-medium">{t('no_stages')}</p>
            </div>
          ) : (
            <StageGrid stagesData={stagesData} />
          )}
        </section>

        {/* Seção de conquistas */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-kid-2xl font-bold text-gray-800 mb-2">
              {t('section_achievements')}
            </h2>
          </div>
          <div className="flex justify-center">
            <Button variant="mint" size="kid-lg" asChild>
              <Link href="/play/badges">{t('view_all_badges')}</Link>
            </Button>
          </div>
        </section>
      </main>
    </div>
  );
}

