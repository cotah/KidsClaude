'use client';

import * as React from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
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

  if (!currentChild) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="text-6xl">🤔</div>
          <p className="text-kid-lg text-gray-600">
            Ops! Você precisa escolher seu perfil primeiro.
          </p>
          <Button variant="sunny" size="kid-lg" asChild>
            <Link href="/select">Escolher Perfil</Link>
          </Button>
        </div>
      </div>
    );
  }

  if (isNaN(stageId) || stageId < 1 || stageId > 4) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="text-6xl">🔍</div>
          <p className="text-kid-lg text-gray-600">
            Stage não encontrada.
          </p>
          <Button variant="sunny" size="kid-lg" asChild>
            <Link href="/play">Voltar ao Hub</Link>
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
                <span>Voltar ao Hub</span>
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
                    Stage {currentStage.stage}: {currentStage.name}
                  </h1>
                  <p className="text-kid-base text-gray-600">
                    {currentStage.description} • {currentStage.age_band_label}
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
                  <span className="text-gray-600">Progresso da Stage</span>
                  <span className="font-medium text-gray-800">
                    {currentStage.lessons_completed} / {currentStage.lessons_total} lições
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
            Lições da Stage {stageId}
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
}

/**
 * Item de lição na lista da stage
 */
function LessonListItem({ lesson, index, stageId }: LessonListItemProps) {
  const getStatusIcon = () => {
    if (lesson.is_locked) {
      return <LockIcon className="w-5 h-5 text-gray-400" />;
    }
    // TODO: Implementar lógica de status baseada no progresso real
    // Por enquanto, assume que não está completo
    return <div className="w-5 h-5 rounded-full border-2 border-gray-300" />;
  };

  const getStatusText = () => {
    if (lesson.is_locked) {
      return 'Bloqueado';
    }
    // TODO: Implementar lógica de status baseada no progresso real
    return 'Começar';
  };

  return (
    <KidCard
      colorScheme={lesson.is_locked ? 'sunny' : 'sunny'}
      className={cn(
        'transition-all duration-200',
        !lesson.is_locked && 'hover:scale-105',
        lesson.is_locked && 'opacity-60'
      )}
    >
      <div className="p-6">
        <div className="flex items-center space-x-4">
          {/* Número da lição */}
          <div className="w-10 h-10 bg-sunny-400 rounded-full flex items-center justify-center text-white font-bold text-kid-base">
            {stageId}.{index}
          </div>

          {/* Conteúdo da lição */}
          <div className="flex-1 space-y-1">
            <h3 className="text-kid-lg font-bold text-gray-800">
              {lesson.title}
            </h3>
            <p className="text-kid-base text-gray-600">
              {lesson.description}
            </p>
          </div>

          {/* XP e status */}
          <div className="text-right space-y-2">
            <div className="flex items-center space-x-2">
              <span className="text-kid-sm text-sunny-600 font-medium">
                +{lesson.xp_reward} XP
              </span>
              {getStatusIcon()}
            </div>
            <Button
              variant={lesson.is_locked ? 'ghost' : 'sunny'}
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