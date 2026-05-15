'use client';

import { useLocale, useTranslations } from 'next-intl';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { Progress } from '@/components/ui/progress';
import { CheckCircle, Circle, PlayCircle } from 'lucide-react';
import type { LessonProgress } from '@/types/api';

interface ProgressListProps {
  progress: LessonProgress[];
}

export function ProgressList({ progress }: ProgressListProps) {
  const t = useTranslations('progress_list');
  const locale = useLocale();
  const dateLocale = locale === 'en' ? 'en-US' : 'pt-BR';

  const getStatusIcon = (status: LessonProgress['status']) => {
    switch (status) {
      case 'completed':
        return <CheckCircle className="w-4 h-4 text-green-500" />;
      case 'in_progress':
        return <PlayCircle className="w-4 h-4 text-blue-500" />;
      default:
        return <Circle className="w-4 h-4 text-gray-400" />;
    }
  };

  const getStatusLabel = (status: LessonProgress['status']) => {
    switch (status) {
      case 'completed':
        return t('status_completed');
      case 'in_progress':
        return t('status_in_progress');
      default:
        return t('status_not_started');
    }
  };

  const getStatusColor = (status: LessonProgress['status']) => {
    switch (status) {
      case 'completed':
        return 'bg-green-100 text-green-800';
      case 'in_progress':
        return 'bg-blue-100 text-blue-800';
      default:
        return 'bg-gray-100 text-gray-600';
    }
  };

  const completedCount = progress.filter(p => p.status === 'completed').length;
  const totalCount = progress.length;
  const completionPercentage = totalCount > 0 ? (completedCount / totalCount) * 100 : 0;

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900">{t('title')}</h3>
        <Badge variant="outline">
          {completedCount} / {totalCount}
        </Badge>
      </div>

      <div className="mb-6">
        <div className="flex justify-between text-sm text-gray-600 mb-2">
          <span>{t('overall')}</span>
          <span>{Math.round(completionPercentage)}%</span>
        </div>
        <Progress value={completionPercentage} className="h-2" />
      </div>

      <div className="space-y-3 max-h-64 overflow-y-auto">
        {progress.length === 0 ? (
          <div className="text-center text-gray-500 py-8">
            <p>{t('empty')}</p>
          </div>
        ) : (
          progress.map((item) => (
            <div
              key={item.lesson_id}
              className="flex items-center justify-between p-3 bg-gray-50 rounded-lg"
            >
              <div className="flex items-center space-x-3">
                {getStatusIcon(item.status)}
                <div>
                  <p className="font-medium text-gray-900">
                    {item.lesson_title || t('lesson_fallback', { short: item.lesson_id.slice(0, 8) })}
                  </p>
                  {item.completed_at && (
                    <p className="text-xs text-gray-500">
                      {t('completed_at', { date: new Date(item.completed_at).toLocaleDateString(dateLocale) })}
                    </p>
                  )}
                </div>
              </div>

              <div className="flex items-center space-x-2">
                {item.xp_earned > 0 && (
                  <Badge variant="outline" className="text-xs">
                    +{item.xp_earned} XP
                  </Badge>
                )}
                <Badge className={`text-xs ${getStatusColor(item.status)}`}>
                  {getStatusLabel(item.status)}
                </Badge>
              </div>
            </div>
          ))
        )}
      </div>
    </Card>
  );
}
