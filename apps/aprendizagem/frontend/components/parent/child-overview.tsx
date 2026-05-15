'use client';

import { useLocale, useTranslations } from 'next-intl';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { config } from '@/lib/config';
import type { Child } from '@/types/api';

interface ChildOverviewProps {
  child: Child;
}

export function ChildOverview({ child }: ChildOverviewProps) {
  const t = useTranslations('child_overview');
  const locale = useLocale();
  const currentLevelXp = config.gamification.xpPerLevel(child.level);
  const nextLevelXp = config.gamification.xpPerLevel(child.level + 1);
  const progressToNextLevel = ((child.xp - currentLevelXp) / (nextLevelXp - currentLevelXp)) * 100;

  return (
    <Card className="p-6">
      <h3 className="text-lg font-semibold text-gray-900 mb-4">{t('title')}</h3>

      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">{t('age_label')}</p>
            <p className="font-medium">{t('age_unit', { age: child.age })}</p>
          </div>
          <div className="text-right">
            <p className="text-sm text-gray-600">{t('avatar_label')}</p>
            <div className="w-8 h-8 bg-gradient-to-br from-blue-400 to-green-400 rounded-full flex items-center justify-center">
              <span className="text-white text-xs font-bold">
                {child.name.charAt(0).toUpperCase()}
              </span>
            </div>
          </div>
        </div>

        <div>
          <div className="flex items-center justify-between mb-2">
            <p className="text-sm text-gray-600">{t('level_label')}</p>
            <Badge variant="outline">
              {config.gamification.levelNames[child.level - 1] || t('level_n', { level: child.level })}
            </Badge>
          </div>
          <Progress value={progressToNextLevel} className="h-2 mb-1" />
          <div className="flex justify-between text-xs text-gray-500">
            <span>{child.xp} XP</span>
            <span>{nextLevelXp} XP</span>
          </div>
        </div>

        <div className="flex items-center justify-between">
          <div>
            <p className="text-sm text-gray-600">{t('streak_label')}</p>
            <p className="font-medium flex items-center space-x-1">
              {child.streak_days > 0 ? (
                <>
                  <span>🔥</span>
                  <span>{t('streak_active', { days: child.streak_days })}</span>
                </>
              ) : (
                <span>{t('streak_none')}</span>
              )}
            </p>
          </div>
        </div>

        <div>
          <p className="text-sm text-gray-600">{t('daily_limit_label')}</p>
          <p className="font-medium">{t('daily_limit_unit', { minutes: child.daily_limit_minutes })}</p>
        </div>

        <div>
          <p className="text-sm text-gray-600">{t('last_active_label')}</p>
          <p className="font-medium">
            {child.last_active_date
              ? new Date(child.last_active_date).toLocaleDateString(locale === 'en' ? 'en-US' : 'pt-BR')
              : t('never')}
          </p>
        </div>
      </div>
    </Card>
  );
}
