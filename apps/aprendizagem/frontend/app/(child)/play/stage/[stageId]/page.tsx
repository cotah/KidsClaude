'use client';

import * as React from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import { useLocale, useTranslations } from 'next-intl';
import { ArrowLeft, CheckCircleIcon, LockIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { KidCard } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { lessonsApi, stagesApi } from '@/lib/api';
import useAppStore from '@/lib/store/app-store';
import { cn } from '@/lib/utils';
import type { Lesson } from '@/types/api';

/**
 * Página de uma stage específica - lista as 4 lições da stage
 * Conforme spec curriculum redesign seção 7.2
 */
export default function StagePage() {
  const t = useTranslations('stage_page');
  // tInfo expoe nome/descricao/age_band traduzidos por numero de stage,
  // sobrescrevendo o que o backend devolve hardcoded em PT.
  const tInfo = useTranslations('stage_info');
  const params = useParams();
  const router = useRouter();
  const { currentChild } = useAppStore();
  const stageId = parseInt(params.stageId as string, 10);

  // Buscar dados da stage
  const { data: stagesData } = useQuery({
    queryKey: ['stages', currentChild?.id],
    queryFn: () => stagesApi.getStages(),
    enabled: !!currentChild,
  });

  // Buscar lições da stage
  const { data: lessons, isLoading: isLoadingLessons } = useQuery({
    queryKey: ['lessons', 'stage', stageId],
    queryFn: () => lessonsApi.list({ stage: stageId }),
    enabled: !!currentChild && !isNaN(stageId),
  });

  // Buscar progresso de licoes pra marcar quais ja foram concluidas.
  // Backend devolve envelope { progress: LessonProgress[] }; o helper
  // lessonsApi.getProgress ja desempacota.
  const { data: progress } = useQuery({
    queryKey: ['lesson-progress', currentChild?.id],
    queryFn: () => lessonsApi.getProgress(currentChild!.id),
    enabled: !!currentChild,
    staleTime: 30_000,
  });

  // Set de lesson_ids concluidos pra lookup O(1) no LessonListItem.
  const completedLessonIds = React.useMemo(
    () => new Set((progress ?? []).filter(p => p.status === 'completed').map(p => p.lesson_id)),
    [progress]
  );

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

  // Guarda apenas valores invalidos (NaN, negativos, zero). Limite superior
  // removido pra nao precisar atualizar esse arquivo a cada nova stage; se
  // a stage nao existir, o backend devolve lista vazia de lessons e o que
  // ja' temos abaixo renderiza naturalmente como "nenhuma licao".
  if (isNaN(stageId) || stageId < 1) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="text-6xl">🔍</div>
          <p className="text-kid-lg text-gray-600">{t('stage_not_found')}</p>
          <Button variant="sunny" size="kid-lg" asChild>
            <Link href="/play">{t('back_to_hub')}</Link>
          </Button>
        </div>
      </div>
    );
  }

  const currentStage = stagesData?.stages.find(s => s.stage === stageId);
  const progressPercentage = currentStage ? (currentStage.lessons_completed / currentStage.lessons_total) * 100 : 0;

  return (
    <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100">
      {/* Header da stage */}
      <header className="bg-white/80 backdrop-blur-sm border-b border-sunny-200 p-4">
        <div className="container mx-auto max-w-4xl">
          <div className="flex items-center space-x-4 mb-4">
            <Button
              variant="ghost"
              size="kid-sm"
              asChild
              className="text-gray-600 hover:text-gray-800"
            >
              <Link href="/play" className="flex items-center space-x-2">
                <ArrowLeft className="w-4 h-4" />
                <span>{t('back_to_hub')}</span>
              </Link>
            </Button>
          </div>

          {currentStage && (
            <>
              <div className="flex items-center space-x-4 mb-4">
                <div className="w-12 h-12 bg-sunny-400 rounded-full flex items-center justify-center border-2 border-white shadow-lg">
                  <span className="text-2xl font-bold text-white">{currentStage.stage}</span>
                </div>
                <div>
                  <h1 className="text-kid-2xl font-bold text-gray-800">
                    {t('stage_label', {
                      n: currentStage.stage,
                      name: tInfo(`${currentStage.stage}.name`),
                    })}
                  </h1>
                  <p className="text-kid-base text-gray-600">
                    {t('stage_subtitle', {
                      description: tInfo(`${currentStage.stage}.description`),
                      age_band: tInfo(`${currentStage.stage}.age_band_label`),
                    })}
                  </p>
                </div>
                <Badge
                  variant="secondary"
                  className={cn(
                    'ml-auto',
                    currentStage.difficulty === 'easy' && 'bg-green-100 text-green-700',
                    currentStage.difficulty === 'medium' && 'bg-yellow-100 text-yellow-700',
                    currentStage.difficulty === 'hard' && 'bg-orange-100 text-orange-700',
                    currentStage.difficulty === 'advanced' && 'bg-red-100 text-red-700'
                  )}
                >
                  {currentStage.difficulty}
                </Badge>
              </div>

              {/* Barra de progresso da stage */}
              <div className="space-y-2">
                <div className="flex justify-between items-center text-kid-sm">
                  <span className="text-gray-600">{t('stage_progress')}</span>
                  <span className="font-medium text-gray-800">
                    {t('lessons_count', { completed: currentStage.lessons_completed, total: currentStage.lessons_total })}
                  </span>
                </div>
                <Progress value={progressPercentage} className="h-3" />
              </div>
            </>
          )}
        </div>
      </header>

      <main className="container mx-auto max-w-4xl p-6 space-y-6">
        {/* Lista de lições */}
        <section className="space-y-4">
          <h2 className="text-kid-xl font-bold text-gray-800 text-center">
            {t('lessons_section', { n: stageId })}
          </h2>

          {isLoadingLessons ? (
            <div className="space-y-4">
              {Array.from({ length: 4 }).map((_, index) => (
                <div
                  key={index}
                  className="h-32 rounded-kid-lg bg-gray-200 animate-pulse"
                />
              ))}
            </div>
          ) : (
            <div className="space-y-4">
              {lessons?.map((lesson, index) => (
                <LessonListItem
                  key={lesson.id}
                  lesson={lesson}
                  index={index + 1}
                  stageId={stageId}
                  isCompleted={completedLessonIds.has(lesson.id)}
                />
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}

interface LessonListItemProps {
  lesson: Lesson;
  index: number;
  stageId: number;
  isCompleted: boolean;
}

/**
 * Item de lição na lista da stage. 3 estados visuais:
 *  - bloqueada: cinza, opacity, lock icon, botao desabilitado
 *  - concluida: borda verde, checkmark verde, "Concluida" badge, botao "Rever"
 *  - disponivel: padrao sunny, circulo vazio, botao "Comecar"
 */
function LessonListItem({ lesson, index, stageId, isCompleted }: LessonListItemProps) {
  const t = useTranslations('stage_page');
  const tLesson = useTranslations('lesson');
  const locale = useLocale();

  // Diagnostico: mostra o que o backend mandou pra esta licao. Se
  // title_en/description_en virem null|undefined, o fallback cai pra PT
  // (causa raiz mais provavel). Abrir F12 -> Console pra ver.
  console.log('[LessonListItem]', {
    slug: lesson.slug,
    locale,
    title: lesson.title,
    title_en: lesson.title_en,
    description: lesson.description,
    description_en: lesson.description_en,
  });

  // Locale-aware: usa title_en/description_en quando locale='en' e o
  // backend tem traducao (migrations 010+012). Fallback PT pra licoes
  // antigas que nao foram traduzidas.
  const useEnglish = locale === 'en';
  const displayTitle = useEnglish && lesson.title_en ? lesson.title_en : lesson.title;
  const displayDescription =
    useEnglish && lesson.description_en ? lesson.description_en : lesson.description;

  const getStatusIcon = () => {
    if (lesson.is_locked) {
      return <LockIcon className="w-5 h-5 text-gray-400" />;
    }
    if (isCompleted) {
      return <CheckCircleIcon className="w-5 h-5 text-green-600" />;
    }
    return <div className="w-5 h-5 rounded-full border-2 border-gray-300" />;
  };

  const getStatusText = () => {
    if (lesson.is_locked) return tLesson('button_locked');
    if (isCompleted) return tLesson('button_review');
    return tLesson('button_start');
  };

  return (
    <KidCard
      colorScheme={isCompleted ? 'mint' : 'sunny'}
      className={cn(
        'transition-all duration-200',
        !lesson.is_locked && 'hover:scale-105',
        lesson.is_locked && 'opacity-60',
        isCompleted && 'border-green-400 ring-2 ring-green-200'
      )}
    >
      {/* Indicador de conclusao agora vive na area de XP/status (checkmark
          verde) + no botao ("Rever" em variant mint). Removido o badge
          "Concluida" absoluto que duplicava o sinal e ficava ilegivel
          sobre o fundo mint. */}
      <div className="p-6">
        <div className="flex items-center space-x-4">
          {/* Número da lição - verde quando concluida */}
          <div className={cn(
            'w-10 h-10 rounded-full flex items-center justify-center text-white font-bold text-kid-base',
            isCompleted ? 'bg-green-500' : 'bg-sunny-400'
          )}>
            {stageId}.{index}
          </div>

          {/* Conteúdo da lição (title/description localizados) */}
          <div className="flex-1 space-y-1">
            <h3 className="text-kid-lg font-bold text-gray-800">
              {displayTitle}
            </h3>
            <p className="text-kid-base text-gray-600">
              {displayDescription}
            </p>
          </div>

          {/* XP e status. Esconde "+XP" quando concluida pra nao competir
              visualmente com a badge "Concluida" no canto superior direito. */}
          <div className="text-right space-y-2">
            <div className="flex items-center space-x-2">
              {!isCompleted && (
                <span className="text-kid-sm text-sunny-600 font-medium">
                  {t('xp_label', { xp: lesson.xp_reward })}
                </span>
              )}
              {getStatusIcon()}
            </div>
            <Button
              variant={lesson.is_locked ? 'ghost' : isCompleted ? 'mint' : 'sunny'}
              size="kid-sm"
              asChild
              disabled={lesson.is_locked}
              className="min-w-[100px]"
            >
              {lesson.is_locked ? (
                <span>{getStatusText()}</span>
              ) : (
                <Link href={`/play/lesson/${lesson.id}`}>
                  {getStatusText()}
                </Link>
              )}
            </Button>
          </div>
        </div>
      </div>
    </KidCard>
  );
}