import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Award, Lock } from 'lucide-react';
import type { ChildBadge } from '@/types/api';

interface BadgeWallProps {
  badges: ChildBadge[];
  showTitle?: boolean;
  compact?: boolean;
}

/**
 * Mural de badges da criança.
 * Mostra badges desbloqueados e bloqueados.
 */
export function BadgeWall({ badges, showTitle = false, compact = false }: BadgeWallProps) {
  // Mock de badges disponíveis (em produção viria da API)
  const allBadges = [
    { id: 'FIRST_STEPS', name: 'Primeiros Passos', description: 'Completou sua primeira lição', icon: '🎯' },
    { id: 'QUICK_LEARNER', name: 'Aprendiz Rápido', description: 'Completou 5 lições', icon: '⚡' },
    { id: 'LESSON_MASTER', name: 'Mestre das Lições', description: 'Completou todas as lições da sua trilha', icon: '👑' },
    { id: 'PROMPT_PRO', name: 'Mestre dos Prompts', description: 'Usou 20 prompts guiados', icon: '🎨' },
    { id: 'STREAK_3', name: 'Trio Vencedor', description: 'Sequência de 3 dias', icon: '🔥' },
    { id: 'STREAK_7', name: 'Semana Brilhante', description: 'Sequência de 7 dias', icon: '🌟' },
    { id: 'STREAK_30', name: 'Mês de Ouro', description: 'Sequência de 30 dias', icon: '🏆' },
    { id: 'CHALLENGE_ACE', name: 'Ás dos Desafios', description: 'Acertou 10 desafios na primeira tentativa', icon: '🎪' },
    { id: 'CURIOUS_MIND', name: 'Mente Curiosa', description: 'Explorou 3 trilhas diferentes', icon: '🧠' },
    { id: 'STORYTELLER', name: 'Contador de Histórias', description: 'Criou 5 histórias completas no chat', icon: '📚' },
    { id: 'LEVEL_5', name: 'Nível 5', description: 'Alcançou o nível 5', icon: '🚀' },
    { id: 'LEVEL_10', name: 'Lendário', description: 'Alcançou o nível 10', icon: '💎' },
  ];

  const unlockedBadgeIds = new Set(badges.map(b => b.badge_code));

  return (
    <Card className={compact ? "p-4" : "p-6"}>
      {showTitle && (
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">Badges</h3>
          <Badge variant="outline">
            {badges.length} / {allBadges.length}
          </Badge>
        </div>
      )}

      <div className={`grid grid-cols-3 ${compact ? 'gap-3' : 'gap-4'}`}>
        {allBadges.map((badge) => {
          const isUnlocked = unlockedBadgeIds.has(badge.id);
          const unlockedBadge = badges.find(b => b.badge_code === badge.id);

          return (
            <div
              key={badge.id}
              className={`
                relative p-3 rounded-lg border-2 transition-all
                ${isUnlocked
                  ? 'border-yellow-300 bg-gradient-to-br from-yellow-50 to-orange-50'
                  : 'border-gray-200 bg-gray-50'
                }
              `}
              title={badge.description}
            >
              {/* Badge icon */}
              <div className="text-center mb-2">
                <div className={`
                  w-12 h-12 mx-auto rounded-full flex items-center justify-center text-xl
                  ${isUnlocked
                    ? 'bg-gradient-to-br from-yellow-400 to-orange-400 text-white'
                    : 'bg-gray-200 text-gray-400'
                  }
                `}>
                  {isUnlocked ? badge.icon : <Lock className="w-5 h-5" />}
                </div>
              </div>

              {/* Badge info */}
              <div className="text-center">
                <p className={`
                  text-xs font-medium mb-1
                  ${isUnlocked ? 'text-gray-900' : 'text-gray-500'}
                `}>
                  {badge.name}
                </p>

                {unlockedBadge && (
                  <p className="text-xs text-gray-500">
                    {new Date(unlockedBadge.awarded_at).toLocaleDateString('pt-BR')}
                  </p>
                )}
              </div>

              {/* Unlock indicator */}
              {isUnlocked && (
                <div className="absolute -top-1 -right-1">
                  <Award className="w-4 h-4 text-yellow-500" />
                </div>
              )}
            </div>
          );
        })}
      </div>
    </Card>
  );
}