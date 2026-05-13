'use client';

import * as React from 'react';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import { lessonsApi } from '@/lib/api';
import { KidCard } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { XPProgress, StreakProgress } from '@/components/ui/progress';
import { Mascot, MascotBubble } from '@/components/ui/mascot-bubble';
import useAppStore from '@/lib/store/app-store';
import { calculateLevelInfo, getAgeGroup, formatTimeForKids } from '@/lib/utils';
import type { Lesson } from '@/types/api';

/**
 * Hub principal da criança - conforme spec seção 8.3
 */
export default function PlayPage() {
  const { currentChild } = useAppStore();
  const [greeting, setGreeting] = React.useState('');

  // Buscar lições disponíveis para a faixa etária
  const { data: lessons, isLoading: isLoadingLessons } = useQuery({
    queryKey: ['lessons', currentChild?.age],
    queryFn: () => {
      if (!currentChild) return [];
      const ageGroup = getAgeGroup(currentChild.age);
      return lessonsApi.list(ageGroup);
    },
    enabled: !!currentChild,
  });

  // Buscar progresso da crianca usando o id da sessao corrente
  const { data: progress } = useQuery({
    queryKey: ['child-progress', currentChild?.id],
    queryFn: () => lessonsApi.getProgress(currentChild!.id),
    enabled: !!currentChild,
  });

  React.useEffect(() => {
    if (currentChild) {
      const hour = new Date().getHours();
      if (hour < 12) {
        setGreeting('Bom dia');
      } else if (hour < 18) {
        setGreeting('Boa tarde');
      } else {
        setGreeting('Boa noite');
      }
    }
  }, [currentChild]);

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

  const levelInfo = calculateLevelInfo(currentChild.xp);
  const ageGroup = getAgeGroup(currentChild.age);

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
              <Link href="/play/switch-profile">Trocar Perfil</Link>
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
                Que legal ter você aqui! Você está no nível{' '}
                <strong>{levelInfo.current} - {levelInfo.name}</strong>.
              </p>
              {currentChild.streak_days > 0 ? (
                <p>
                  Continue assim! Você tem uma sequência incrível de{' '}
                  <strong>{currentChild.streak_days} dias</strong> aprendendo! 🔥
                </p>
              ) : (
                <p>
                  Vamos começar uma nova aventura de aprendizado! Que tal fazer uma lição?
                </p>
              )}
            </div>
          </MascotBubble>
        </section>

        {/* Lições disponíveis */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-kid-2xl font-bold text-gray-800 mb-2">
              Suas Lições
            </h2>
            <p className="text-kid-base text-gray-600">
              Escolha uma lição para continuar aprendendo!
            </p>
          </div>

          {isLoadingLessons ? (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {Array.from({ length: 4 }).map((_, index) => (
                <div
                  key={index}
                  className="h-48 rounded-kid-lg bg-gray-200 animate-pulse"
                />
              ))}
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
              {lessons?.map((lesson) => (
                <LessonCard
                  key={lesson.id}
                  lesson={lesson}
                  progress={progress?.find(p => p.lesson_id === lesson.id)}
                  ageGroup={ageGroup}
                />
              ))}
            </div>
          )}
        </section>

        {/* Seção de conquistas */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-kid-2xl font-bold text-gray-800 mb-2">
              Suas Conquistas
            </h2>
          </div>
          <div className="flex justify-center">
            <Button variant="mint" size="kid-lg" asChild>
              <Link href="/play/badges">
                Ver Todas as Conquistas 🏆
              </Link>
            </Button>
          </div>
        </section>
      </main>
    </div>
  );
}

interface LessonCardProps {
  lesson: Lesson;
  progress?: any;
  ageGroup: '6-8' | '9-12';
}

function LessonCard({ lesson, progress, ageGroup }: LessonCardProps) {
  const getStatusInfo = () => {
    if (!progress) {
      return {
        status: 'not_started',
        badge: 'Novo',
        color: 'secondary',
        action: 'Começar',
        variant: 'sunny',
      };
    }

    switch (progress.status) {
      case 'in_progress':
        return {
          status: 'in_progress',
          badge: 'Começou',
          color: 'warning',
          action: 'Continuar',
          variant: 'ocean',
        };
      case 'completed':
        return {
          status: 'completed',
          badge: 'Concluído',
          color: 'success',
          action: 'Revisar',
          variant: 'mint',
        };
      default:
        return {
          status: 'not_started',
          badge: 'Novo',
          color: 'secondary',
          action: 'Começar',
          variant: 'sunny',
        };
    }
  };

  const statusInfo = getStatusInfo();

  return (
    <KidCard
      colorScheme={statusInfo.variant as any}
      className={cn(
        'relative overflow-hidden transition-all duration-200 hover:scale-105',
        lesson.is_locked && 'opacity-50 cursor-not-allowed'
      )}
    >
      <div className="p-6 space-y-4">
        {/* Badge de status */}
        <div className="flex justify-between items-start">
          <Badge variant={statusInfo.color as any} size="kid">
            {statusInfo.badge}
          </Badge>
          {lesson.is_locked && (
            <div className="text-2xl">🔒</div>
          )}
        </div>

        {/* Conteúdo da lição */}
        <div className="space-y-2">
          <h3 className={cn(
            'font-bold text-gray-800 line-clamp-2',
            ageGroup === '6-8' ? 'text-kid-lg' : 'text-kid-base'
          )}>
            {lesson.title}
          </h3>
          <p className={cn(
            'text-gray-600 line-clamp-3',
            ageGroup === '6-8' ? 'text-kid-base' : 'text-kid-sm'
          )}>
            {lesson.description}
          </p>
        </div>

        {/* Info de XP */}
        <div className="flex items-center justify-between">
          <div className="flex items-center space-x-1 text-sunny-600">
            <span>⭐</span>
            <span className="text-kid-sm font-medium">
              +{lesson.xp_reward} XP
            </span>
          </div>
          <div className="text-kid-sm text-gray-500">
            {/* O endpoint /lessons (lista) nao traz content_blocks; */}
            {/* so' o /lessons/:id (detalhe) traz. Defensivo com ?. */}
            {lesson.content_blocks?.length ?? 0} partes
          </div>
        </div>

        {/* Botão de ação */}
        <Button
          variant={statusInfo.variant as any}
          size={ageGroup === '6-8' ? 'kid-lg' : 'kid-default'}
          className="w-full"
          asChild
          disabled={lesson.is_locked}
        >
          <Link href={`/play/lesson/${lesson.id}`}>
            {lesson.is_locked ? 'Bloqueado' : statusInfo.action}
          </Link>
        </Button>
      </div>
    </KidCard>
  );
}

import { cn } from '@/lib/utils';