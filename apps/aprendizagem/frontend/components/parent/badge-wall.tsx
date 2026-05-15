'use client';

import { useLocale, useTranslations } from 'next-intl';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Award, Lock } from 'lucide-react';
import type { ChildBadge } from '@/types/api';

interface BadgeWallProps {
  badges: ChildBadge[];
  showTitle?: boolean;
  compact?: boolean;
}

// Catalogo dos 12 badges principais. Strings agora vem de
// messages/badges_catalog.<code>.{name,description}. Icone fica aqui
// porque nao varia por idioma.
const BADGE_CATALOG: Array<{ code: string; icon: string }> = [
  { code: 'FIRST_STEPS', icon: '🎯' },
  { code: 'QUICK_LEARNER', icon: '⚡' },
  { code: 'LESSON_MASTER', icon: '👑' },
  { code: 'PROMPT_PRO', icon: '🎨' },
  { code: 'STREAK_3', icon: '🔥' },
  { code: 'STREAK_7', icon: '🌟' },
  { code: 'STREAK_30', icon: '🏆' },
  { code: 'CHALLENGE_ACE', icon: '🎪' },
  { code: 'CURIOUS_MIND', icon: '🧠' },
  { code: 'STORYTELLER', icon: '📚' },
  { code: 'LEVEL_5', icon: '🚀' },
  { code: 'LEVEL_10', icon: '💎' },
];

export function BadgeWall({ badges, showTitle = false, compact = false }: BadgeWallProps) {
  const t = useTranslations('badge_wall');
  const tCat = useTranslations('badges_catalog');
  const locale = useLocale();
  const dateLocale = locale === 'en' ? 'en-US' : 'pt-BR';

  const unlockedBadgeIds = new Set(badges.map(b => b.badge_code));

  return (
    <Card className={compact ? 'p-4' : 'p-6'}>
      {showTitle && (
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold text-gray-900">{t('title')}</h3>
          <Badge variant="outline">
            {t('count', { n: badges.length, total: BADGE_CATALOG.length })}
          </Badge>
        </div>
      )}

      <div className={`grid grid-cols-3 ${compact ? 'gap-3' : 'gap-4'}`}>
        {BADGE_CATALOG.map((badge) => {
          const isUnlocked = unlockedBadgeIds.has(badge.code);
          const unlockedBadge = badges.find(b => b.badge_code === badge.code);
          const name = tCat(`${badge.code}.name`);
          const description = tCat(`${badge.code}.description`);

          return (
            <div
              key={badge.code}
              className={`relative p-3 rounded-lg border-2 transition-all ${
                isUnlocked
                  ? 'border-yellow-300 bg-gradient-to-br from-yellow-50 to-orange-50'
                  : 'border-gray-200 bg-gray-50'
              }`}
              title={description}
            >
              <div className="text-center mb-2">
                <div
                  className={`w-12 h-12 mx-auto rounded-full flex items-center justify-center text-xl ${
                    isUnlocked
                      ? 'bg-gradient-to-br from-yellow-400 to-orange-400 text-white'
                      : 'bg-gray-200 text-gray-400'
                  }`}
                >
                  {isUnlocked ? badge.icon : <Lock className="w-5 h-5" />}
                </div>
              </div>

              <div className="text-center">
                <p
                  className={`text-xs font-medium mb-1 ${
                    isUnlocked ? 'text-gray-900' : 'text-gray-500'
                  }`}
                >
                  {name}
                </p>

                {unlockedBadge && (
                  <p className="text-xs text-gray-500">
                    {new Date(unlockedBadge.awarded_at).toLocaleDateString(dateLocale)}
                  </p>
                )}
              </div>

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
