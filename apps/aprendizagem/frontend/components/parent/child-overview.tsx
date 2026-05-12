import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { config } from '@/lib/config';
import type { Child } from '@/types/api';

interface ChildOverviewProps {
  child: Child;
}

/**
 * Componente de overview básico do filho.
 * Mostra informações essenciais e progresso geral.
 */
export function ChildOverview({ child }: ChildOverviewProps) {
  const currentLevelXp = config.gamification.xpPerLevel(child.level);
  const nextLevelXp = config.gamification.xpPerLevel(child.level + 1);
  const progressToNextLevel = ((child.xp - currentLevelXp) / (nextLevelXp - currentLevelXp)) * 100;

  return (
    <Card className="p-6">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">Informações gerais</h3>

      <div className="space-y-4">
        {/* Idade e avatar */}
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Idade</p>
            <p className="font-medium">{child.age} anos</p>
          </div>
          <div className="text-right">
            <p className="text-sm text-gray-600">Avatar</p>
            <div className="w-8 h-8 bg-gradient-to-br from-blue-400 to-green-400 rounded-full flex items-center justify-center">
              <span className="text-white text-xs font-bold">
                {child.name.charAt(0).toUpperCase()}
              </span>
            </div>
          </div>
        </div>

        {/* Nível e XP */}
        <div>
          <div className="flex items-center justify-between mb-2">
            <p className="text-sm text-gray-600">Nível</p>
            <Badge variant="outline">
              {config.gamification.levelNames[child.level - 1] || `Nível ${child.level}`}
            </Badge>
          </div>
          <Progress value={progressToNextLevel} className="h-2 mb-1" />
          <div className="flex justify-between text-xs text-gray-500">
            <span>{child.xp} XP</span>
            <span>{nextLevelXp} XP</span>
          </div>
        </div>

        {/* Sequência */}
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">Sequência</p>
            <p className="font-medium flex items-center space-x-1">
              {child.streak_days > 0 ? (
                <>
                  <span>🔥</span>
                  <span>{child.streak_days} dias</span>
                </>
              ) : (
                <span>Nenhuma sequência ativa</span>
              )}
            </p>
          </div>
        </div>

        {/* Limite diário */}
        <div>
          <p className="text-sm text-gray-600">Limite diário</p>
          <p className="font-medium">{child.daily_limit_minutes} minutos</p>
        </div>

        {/* Última atividade */}
        <div>
          <p className="text-sm text-gray-600">Última atividade</p>
          <p className="font-medium">
            {child.last_active_date
              ? new Date(child.last_active_date).toLocaleDateString('pt-BR')
              : 'Nunca'
            }
          </p>
        </div>
      </div>
    </Card>
  );
}