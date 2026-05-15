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
  // STREAK_3 e STREAK_7: description vazio sinaliza pra render usar
  // t('badges_catalog.<code>.description') em vez do texto local.
  { code: 'STREAK_3', name: 'Sequencia de 3', description: '', icon: '🔥' },
  { code: 'STREAK_7', name: 'Semana Inteira', description: '', icon: '📅' },
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
 * Mural de conquistas. Mostra catalogo completo das 12 badges. A chamada
 * para dashboardApi.getDashboard foi removida porque ela exige token de
 * pai e era chamada em sessao de crianca, gerando 401 ruidoso. Quando o
 * backend tiver endpoint /v1/children/{id}/badges, plugar aqui.
 */
export default function BadgesPage() {
  const router = useRouter();
  const tCat = useTranslations('badges_catalog');
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
                <p className="text-xs leading-tight text-gray-600">
                  {badge.description || tCat(`${badge.code}.description`)}
                </p>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
