import { Suspense } from 'react';
import Link from 'next/link';
import { getTranslations } from 'next-intl/server';
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
import { calculateLevelInfo, getLevelFloor } from '@/lib/utils';
import type { Child, LessonProgress, ChildBadge, DailyUsage } from '@/types/api';

// Shapes brutos vindos do backend FastAPI (envelopes + nomes de campo).
interface ProgressEnvelope {
  progress?: LessonProgress[];
}
interface BadgesEnvelope {
  badges?: Array<{
    id: string;
    code: string;
    name: string;
    description: string;
    icon: string;
    awarded_at: string | null;
  }>;
}
interface UsageEnvelope {
  usage?: Array<{
    date: string;
    minutes_used: number;
  }>;
}

interface PageProps {
  params: Promise<{ id: string }>;
}

/**
 * Página de detalhes de um filho.
 * Mostra overview, progresso, badges e gráficos de uso.
 *
 * Server Component: chama o backend FastAPI direto via serverApiClient,
 * desempacota envelopes ({progress|badges|usage}) e adapta os nomes de
 * campo ao formato esperado pelos componentes filho (ChildBadge, DailyUsage).
 */
export default async function ChildDetailPage({ params }: PageProps) {
  const { id } = await params;
  const t = await getTranslations('children_detail');
  const tOverview = await getTranslations('child_overview');

  // Buscar dados em paralelo
  const [child, progressRaw, badgesRaw, usageRaw] = await Promise.all([
    serverApiClient.get<Child>(`children/${id}`),
    serverApiClient.get<ProgressEnvelope>(`children/${id}/progress`),
    serverApiClient.get<BadgesEnvelope>(`children/${id}/badges`),
    serverApiClient.get<UsageEnvelope>(`children/${id}/usage?days=30`),
  ]);

  // Desempacota e adapta para os tipos que os componentes consomem.
  const progress: LessonProgress[] = progressRaw?.progress ?? [];

  const badges: ChildBadge[] = (badgesRaw?.badges ?? []).map((b) => ({
    id: b.id,
    child_id: id,
    badge_id: b.id,
    badge_code: b.code,
    badge_name: b.name,
    badge_description: b.description,
    badge_icon: b.icon,
    awarded_at: b.awarded_at ?? '',
  }));

  const usage: DailyUsage[] = (usageRaw?.usage ?? []).map((u) => ({
    child_id: id,
    usage_date: u.date,
    minutes_used: u.minutes_used,
  }));

  // Estatisticas - matematica de nivel via helper (xpPerLevel direto da config
  // gera floors errados para nivel 1; calculateLevelInfo respeita o backend).
  const completedLessons = progress.filter((p) => p.status === 'completed').length;
  const totalXp = child.xp;
  const currentLevel = child.level;
  const levelInfo = calculateLevelInfo(totalXp);
  const progressToNextLevel = levelInfo.progress_percent;
  const nextLevelXp = getLevelFloor(currentLevel + 1);

  const todayIso = new Date().toISOString().split('T')[0];
  const todayUsage =
    usage.find((u) => u.usage_date === todayIso)?.minutes_used ?? 0;

  return (
    <div className="max-w-6xl mx-auto space-y-6">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center space-x-4">
          <Link href="/dashboard">
            <Button variant="ghost" size="sm">
              <ArrowLeft className="w-4 h-4 mr-2" />
              {t('back')}
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
                <span className="text-orange-500" title={tOverview('streak_active', { days: child.streak_days })}>
                  🔥{child.streak_days}
                </span>
              )}
            </h1>
            <p className="text-gray-600">
              {t('age_with_level', {
                age: child.age,
                level_name: config.gamification.levelNames[currentLevel - 1] || t('level_n', { level: currentLevel }),
              })}
            </p>
          </div>
        </div>

        <div className="flex space-x-3">
          <Link href={`/children/${child.id}/sessions`}>
            <Button variant="outline" size="sm">
              <MessageSquare className="w-4 h-4 mr-2" />
              {t('conversations')}
            </Button>
          </Link>
          <Link href={`/children/${child.id}/safety`}>
            <Button variant="outline" size="sm">
              <Shield className="w-4 h-4 mr-2" />
              {t('safety')}
            </Button>
          </Link>
          <Link href={`/children/${child.id}/edit`}>
            <Button variant="outline" size="sm">
              <Edit className="w-4 h-4 mr-2" />
              {t('edit')}
            </Button>
          </Link>
        </div>
      </div>

      {/* Cards de estatísticas principais */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">{t('current_level')}</p>
              <p className="text-2xl font-bold text-gray-900">{currentLevel}</p>
            </div>
            <BarChart3 className="w-8 h-8 text-purple-500" />
          </div>
          <div className="mt-4">
            <Progress value={progressToNextLevel} className="h-2" />
            <p className="text-xs text-gray-500 mt-1">
              {t('xp_to_next', { current: totalXp, next: nextLevelXp })}
            </p>
          </div>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">{t('lessons_completed')}</p>
              <p className="text-2xl font-bold text-gray-900">{completedLessons}</p>
            </div>
            <Award className="w-8 h-8 text-green-500" />
          </div>
          <p className="text-xs text-gray-500 mt-4">
            {t('in_progress', { count: progress.length - completedLessons })}
          </p>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">{t('badges_unlocked')}</p>
              <p className="text-2xl font-bold text-gray-900">{badges.length}</p>
            </div>
            <Badge className="w-8 h-8 text-yellow-500" />
          </div>
        </Card>

        <Card className="p-6">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">{t('today_time')}</p>
              <p className="text-2xl font-bold text-gray-900">{t('minutes_short', { n: todayUsage })}</p>
            </div>
            <div className="text-right">
              <p className="text-xs text-gray-500">
                {t('of_limit', { limit: child.daily_limit_minutes })}
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