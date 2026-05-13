'use client';

import * as React from 'react';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
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
  const { currentChild } = useAppStore();
  const [greeting, setGreeting] = React.useState('');

  // Buscar stages e progresso
  const { data: stagesData, isLoading: isLoadingStages } = useQuery({
    queryKey: ['stages', currentChild?.id],
    queryFn: () => stagesApi.getStages(),
    enabled: !!currentChild,
    staleTime: 30000, // 30s cache para refletir progresso
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

        {/* Stages Grid */}
        <section className="space-y-6">
          <div className="text-center">
            <h2 className="text-kid-2xl font-bold text-gray-800 mb-2">
              Seu Caminho de Aprendizado
            </h2>
            <p className="text-kid-base text-gray-600">
              Complete as 4 stages e desbloqueie o projeto final!
            </p>
          </div>

          {isLoadingStages ? (
            <div className="space-y-8">
              {/* Mock das 4 stages + final exam */}
              <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
                {Array.from({ length: 4 }).map((_, index) => (
                  <div
                    key={index}
                    className="h-56 rounded-kid-lg bg-gray-200 animate-pulse"
                  />
                ))}
              </div>
              <div className="flex justify-center">
                <div className="w-full max-w-md h-48 rounded-kid-lg bg-gradient-to-br from-purple-200 to-yellow-200 animate-pulse" />
              </div>
            </div>
          ) : stagesData ? (
            <StageGrid stagesData={stagesData} />
          ) : (
            <div className="text-center text-gray-500">
              <p>Não foi possível carregar as stages. Tente novamente.</p>
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

