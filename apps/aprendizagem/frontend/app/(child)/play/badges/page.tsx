'use client';

import { useMemo } from 'react';
import { useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import type { Route } from 'next';
import { ArrowLeft, Lock } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Mascot, MascotBubble } from '@/components/ui/mascot-bubble';
import { dashboardApi } from '@/lib/api/dashboard';
import useAppStore from '@/lib/store/app-store';
import { cn } from '@/lib/utils';

// Catalogo das 12 badges seedadas no backend (migrations/002_seed_data.sql).
// Como o backend ainda nao tem endpoint dedicado para listar badges, mantemos
// o catalogo em sincronia aqui. Quando o endpoint /v1/badges existir, trocar
// por uma chamada e remover esta lista.
const BADGE_CATALOG: Array<{
  code: string;
  name: string;
  description: string;
  icon: string;
}> = [
  { code: 'FIRST_STEPS', name: 'Primeiros Passos', description: 'Concluiu sua primeira licao', icon: '👣' },
  { code: 'CURIOUS_MIND', name: 'Mente Curiosa', description: 'Explorou 3 trilhas diferentes', icon: '🔭' },
  { code: 'STREAK_3', name: 'Sequencia de 3', description: '3 dias seguidos aprendendo', icon: '🔥' },
  { code: 'STREAK_7', name: 'Semana Inteira', description: '7 dias seguidos aprendendo', icon: '📅' },
  { code: 'CHALLENGE_ACE', name: 'As dos Desafios', description: 'Acertou 10 desafios na primeira tentativa', icon: '🎯' },
  { code: 'STORYTELLER', name: 'Contador de Historias', description: 'Criou 5 historias completas no chat', icon: '📚' },
  { code: 'POLITE_TALKER', name: 'Boa Educacao', description: 'Usou palavras magicas em 5 conversas', icon: '🤝' },
  { code: 'SAFETY_FIRST', name: 'Seguranca em Primeiro', description: 'Concluiu a licao de seguranca', icon: '🛡️' },
  { code: 'PROMPT_MASTER', name: 'Mestre dos Prompts', description: 'Usou todos os templates de uma licao', icon: '🪄' },
  { code: 'LEVEL_5', name: 'Nivel 5', description: 'Alcancou o nivel 5', icon: '⭐' },
  { code: 'LEVEL_10', name: 'Lendario', description: 'Alcancou o nivel 10', icon: '🌟' },
  { code: 'EARLY_BIRD', name: 'Madrugador', description: 'Aprendeu antes das 9h da manha', icon: '🌅' },
];

/**
 * Mural de conquistas. Sobrepoe as badges do catalogo com o que a crianca
 * desbloqueou (vindo do dashboard).
 */
export default function BadgesPage() {
  const router = useRouter();
  const { currentChild } = useAppStore();

  const { data: dashboard, isLoading } = useQuery({
    queryKey: ['parents-dashboard'],
    queryFn: dashboardApi.getDashboard,
    // Endpoint exige token de pai; em sessao de crianca pode falhar - tudo bem,
    // a UI degrada mostrando todas como bloqueadas.
    retry: false,
  });

  const unlockedCodes = useMemo(() => {
    if (!dashboard || !currentChild) return new Set<string>();
    const card = dashboard.children.find((c) => c.id === currentChild.id);
    return new Set((card?.recent_badges ?? []).map((b) => b.code));
  }, [dashboard, currentChild]);

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
          Voltar
        </Button>
        <h1 className="text-xl font-bold text-gray-800">Minhas conquistas</h1>
        <div className="text-sm font-medium text-grape-600">
          {unlockedCount} / {BADGE_CATALOG.length}
        </div>
      </Card>

      <Card className="flex items-center gap-4 p-4">
        <Mascot size="md" expression="happy" />
        <MascotBubble variant="encouraging" className="flex-1">
          {unlockedCount === 0
            ? 'Conclua licoes e desafios para ganhar conquistas!'
            : `Voce ja desbloqueou ${unlockedCount} conquistas! Continue assim!`}
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
                <p className="text-sm font-bold text-gray-800">{badge.name}</p>
                <p className="text-xs leading-tight text-gray-600">{badge.description}</p>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
