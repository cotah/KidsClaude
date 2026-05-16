'use client';

import { useLocale, useTranslations } from 'next-intl';
import { Card } from '@/components/ui/card';
import type { DailyUsage } from '@/types/api';

interface UsageChartProps {
  usage: DailyUsage[];
  childName: string;
}

export function UsageChart({ usage, childName }: UsageChartProps) {
  const t = useTranslations('usage_chart');
  const locale = useLocale();
  const dateLocale = locale === 'en' ? 'en-US' : 'pt-BR';

  const last30Days = Array.from({ length: 30 }, (_, i) => {
    const date = new Date();
    date.setDate(date.getDate() - (29 - i));
    return date.toISOString().split('T')[0];
  });

  const chartData = last30Days.map(date => {
    const dayUsage = usage.find(u => u.usage_date === date);
    return {
      date,
      minutes: dayUsage?.minutes_used || 0,
    };
  });

  const maxMinutes = Math.max(...chartData.map(d => d.minutes), 1);
  const totalMinutes = chartData.reduce((sum, d) => sum + d.minutes, 0);
  const avgMinutes = Math.round(totalMinutes / 30);
  const hasData = totalMinutes > 0;

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900">{t('title')}</h3>
        <div className="text-sm text-gray-600">
          {t('average_short', { minutes: avgMinutes })}
        </div>
      </div>

      {/* Chart */}
      <div className="h-32 flex items-end justify-between space-x-1 mb-4">
        {chartData.map((day, index) => {
          const height = maxMinutes > 0 ? (day.minutes / maxMinutes) * 100 : 0;
          const isToday = index === chartData.length - 1;

          return (
            <div
              key={day.date}
              className="flex-1 h-full flex flex-col items-center justify-end"
              title={t('tooltip', {
                date: new Date(day.date).toLocaleDateString(dateLocale),
                minutes: day.minutes,
              })}
            >
              <div
                className={`w-full rounded-t transition-all ${
                  day.minutes > 0
                    ? isToday ? 'bg-blue-500' : 'bg-blue-300'
                    : 'bg-gray-100'
                }`}
                style={{ height: `${Math.max(height, 2)}%` }}
              />
            </div>
          );
        })}
      </div>

      <div className="flex items-center justify-between text-xs text-gray-500">
        <span>{t('days_ago')}</span>
        <span>{t('today')}</span>
      </div>

      {/* Hint quando nao ha dados (causa: heartbeat nao implementado no
          frontend; sem POST /v1/chat/usage/heartbeat, daily_usage fica
          vazio. Mostra mensagem em vez de barras vazias mudas). */}
      {!hasData && (
        <p className="mt-3 text-center text-xs text-gray-500">{t('empty_hint')}</p>
      )}

      <div className="grid grid-cols-3 gap-4 mt-4 pt-4 border-t border-gray-200">
        <div className="text-center">
          <p className="text-lg font-semibold text-gray-900">{totalMinutes}</p>
          <p className="text-xs text-gray-600">{t('total_30d')}</p>
        </div>
        <div className="text-center">
          <p className="text-lg font-semibold text-gray-900">{avgMinutes}</p>
          <p className="text-xs text-gray-600">{t('average_label')}</p>
        </div>
        <div className="text-center">
          <p className="text-lg font-semibold text-gray-900">
            {Math.max(...chartData.map(d => d.minutes))}
          </p>
          <p className="text-xs text-gray-600">{t('max_label')}</p>
        </div>
      </div>
    </Card>
  );
}
