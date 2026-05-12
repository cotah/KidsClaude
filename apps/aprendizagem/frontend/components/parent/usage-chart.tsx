'use client';

import { Card } from '@/components/ui/card';
import type { DailyUsage } from '@/types/api';

interface UsageChartProps {
  usage: DailyUsage[];
  childName: string;
}

/**
 * Gráfico simples de uso diário da criança.
 * Mostra últimos 30 dias em barras.
 */
export function UsageChart({ usage, childName }: UsageChartProps) {
  // Preparar dados dos últimos 30 dias
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

  return (
    <Card className="p-6">
      <div className="flex items-center justify-between mb-4">
        <h3 className="text-lg font-semibold text-gray-900">Uso diário</h3>
        <div className="text-sm text-gray-600">
          Média: {avgMinutes}min/dia
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
              className="flex-1 flex flex-col items-center"
              title={`${new Date(day.date).toLocaleDateString('pt-BR')}: ${day.minutes}min`}
            >
              <div
                className={`
                  w-full rounded-t transition-all
                  ${day.minutes > 0
                    ? (isToday ? 'bg-blue-500' : 'bg-blue-300')
                    : 'bg-gray-100'
                  }
                `}
                style={{ height: `${Math.max(height, 2)}%` }}
              />
            </div>
          );
        })}
      </div>

      {/* Legenda */}
      <div className="flex items-center justify-between text-xs text-gray-500">
        <span>30 dias atrás</span>
        <span>Hoje</span>
      </div>

      {/* Estatísticas adicionais */}
      <div className="grid grid-cols-3 gap-4 mt-4 pt-4 border-t border-gray-200">
        <div className="text-center">
          <p className="text-lg font-semibold text-gray-900">{totalMinutes}</p>
          <p className="text-xs text-gray-600">Total (30d)</p>
        </div>
        <div className="text-center">
          <p className="text-lg font-semibold text-gray-900">{avgMinutes}</p>
          <p className="text-xs text-gray-600">Média diária</p>
        </div>
        <div className="text-center">
          <p className="text-lg font-semibold text-gray-900">
            {Math.max(...chartData.map(d => d.minutes))}
          </p>
          <p className="text-xs text-gray-600">Máximo</p>
        </div>
      </div>
    </Card>
  );
}