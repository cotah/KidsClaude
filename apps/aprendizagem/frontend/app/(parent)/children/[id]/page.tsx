import { Suspense } from 'react';
import Link from 'next/link';
import { ArrowLeft, Edit, MessageSquare, Shield, BarChart3, Award } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { ChildOverview } from '@/components/parent/child-overview';
import { ProgressList } from '@/components/parent/progress-list';
import { BadgeWall } from '@/components/parent/badge-wall';
import { UsageChart } from '@/components/parent/usage-chart';
import { serverApiClient } from '@/lib/api/server';
import { config } from '@/lib/config';
import type { Child, LessonProgress, ChildBadge, DailyUsage } from '@/types/api';

interface PageProps {
  params: Promise<{ id: string }>;
}

/**
 * Página de detalhes de um filho.
 * Mostra overview, progresso, badges e gráficos de uso.
 */
export default async function ChildDetailPage({ params }: PageProps) {
  const { id } = await params;

  // Buscar dados em paralelo
  const [child, progress, badges, usage] = await Promise.all([
    serverApiClient.get<Child>(`children/${id}`),
    serverApiClient.get<LessonProgress[]>(`children/${id}/progress`),
    serverApiClient.get<ChildBadge[]>(`children/${id}/badges`),
    serverApiClient.get<DailyUsage[]>(`children/${id}/usage?days=30`),
  ]);

  // Calcular estatísticas
  const completedLessons = progress.filter(p => p.status === 'completed').length;
  const totalXp = child.xp;
  const currentLevel = child.level;
  const nextLevelXp = config.gamification.xpPerLevel(currentLevel + 1);
  const currentLevelXp = config.gamification.xpPerLevel(currentLevel);
  const progressToNextLevel = ((totalXp - currentLevelXp) / (nextLevelXp - currentLevelXp)) * 100;

  const todayUsage = usage.find(u =>
    new Date(u.usage_date).toDateString() === new Date().toDateString()
  )?.minutes_used || 0;

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <Link href="/dashboard">
            <Button variant="ghost" size="sm">
              <ArrowLeft className="w-4 h-4 mr-2" />
              Dashboard
            </Button>
          </Link>
          <div>
            <h1 className="text-2xl font-bold text-gray-900 flex items-center space-x-3">
              <div className="w-10 h-10 bg-gradient-to-br from-blue-400 to-green-400 rounded-full flex items-center justify-center">
                <span className="text-white font-bold">
                  {child.name.charAt(0).toUpperCase()}
                </span>
              </div>
              <span>{child.name}</span>
              {child.streak_days > 0 && (
                <span className="text-orange-500" title={`Sequência de ${child.streak_days} dias`}>
                  🔥{child.streak_days}
                </span>
              )}
            </h1>
            <p className="text-gray-600">
              {child.age} anos • {config.gamification.levelNames[currentLevel - 1] || `Nível ${currentLevel}`}
            </p>
          </div>
        </div>

        <div className="flex space-x-3">
          <Link href={`/children/${child.id}/sessions`}>
            <Button variant="outline" size="sm">
              <MessageSquare className="w-4 h-4 mr-2" />
              Conversas
            </Button>
          </Link>
          <Link href={`/children/${child.id}/safety`}>
            <Button variant="outline" size="sm">
              <Shield className="w-4 h-4 mr-2" />
              Segurança
            </Button>
          </Link>
          <Link href={`/children/${child.id}/edit`}>
            <Button variant="outline" size="sm">
              <Edit className="w-4 h-4 mr-2" />
              Editar
            </Button>
          </Link>
        </div>
      </div>

      {/* Cards de estatísticas principais */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Nível atual</p>
              <p className="text-2xl font-bold text-gray-900">{currentLevel}</p>
            </div>
            <BarChart3 className="w-8 h-8 text-purple-500" />
          </div>
          <div className="mt-4">
            <Progress value={progressToNextLevel} className="h-2" />
            <p className="text-xs text-gray-500 mt-1">
              {totalXp} / {nextLevelXp} XP para o próximo nível
            </p>
          </div>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Lições concluídas</p>
              <p className="text-2xl font-bold text-gray-900">{completedLessons}</p>
            </div>
            <Award className="w-8 h-8 text-green-500" />
          </div>
          <p className="text-xs text-gray-500 mt-4">
            {progress.length - completedLessons} em andamento
          </p>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Badges desbloqueados</p>
              <p className="text-2xl font-bold text-gray-900">{badges.length}</p>
            </div>
            <Badge className="w-8 h-8 text-yellow-500" />
          </div>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Tempo hoje</p>
              <p className="text-2xl font-bold text-gray-900">{todayUsage}min</p>
            </div>
            <div className="text-right">
              <p className="text-xs text-gray-500">
                de {child.daily_limit_minutes}min
              </p>
              <div className="w-12 h-1 bg-gray-200 rounded-full mt-1">
                <div
                  className="h-full bg-blue-500 rounded-full"
                  style={{
                    width: `${Math.min((todayUsage / child.daily_limit_minutes) * 100, 100)}%`
                  }}
                />
              </div>
            </div>
          </div>
        </Card>
      </div>

      {/* Conteúdo principal em grid */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Overview e progresso */}
        <div className="space-y-6">
          <Suspense fallback={<Card className="p-6 animate-pulse h-48" />}>
            <ChildOverview child={child} />
          </Suspense>

          <Suspense fallback={<Card className="p-6 animate-pulse h-64" />}>
            <ProgressList progress={progress} />
          </Suspense>
        </div>

        {/* Badges e gráficos */}
        <div className="space-y-6">
          <Suspense fallback={<Card className="p-6 animate-pulse h-48" />}>
            <BadgeWall badges={badges} showTitle />
          </Suspense>

          <Suspense fallback={<Card className="p-6 animate-pulse h-64" />}>
            <UsageChart usage={usage} childName={child.name} />
          </Suspense>
        </div>
      </div>
    </div>
  );
}