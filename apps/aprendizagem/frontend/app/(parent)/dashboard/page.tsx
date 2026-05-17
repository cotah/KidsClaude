'use client';

import * as React from 'react';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import { useTranslations } from 'next-intl';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { AvatarDisplay } from '@/components/avatar-picker';
import { dashboardApi } from '@/lib/api';
import { formatTimeForKids, calculateLevelInfo } from '@/lib/utils';

export default function DashboardPage() {
  const t = useTranslations('dashboard');
  const { data: dashboardData, isLoading } = useQuery({
    queryKey: ['parent-dashboard'],
    queryFn: dashboardApi.getDashboard,
  });

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 p-4">
        <div className="container mx-auto max-w-6xl">
          <div className="space-y-6">
            <div className="h-8 bg-gray-200 rounded animate-pulse" />
            <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
              {Array.from({ length: 3 }).map((_, i) => (
                <div key={i} className="h-48 bg-gray-200 rounded animate-pulse" />
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      <header className="bg-white border-b border-gray-200 px-4 py-6">
        <div className="container mx-auto max-w-6xl">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-900">{t('title')}</h1>
            <div className="flex space-x-4">
              <Button variant="outline" asChild>
                <Link href="/children/new">{t('add_child')}</Link>
              </Button>
              <Button variant="outline" asChild>
                <Link href="/select">{t('child_mode')}</Link>
              </Button>
            </div>
          </div>
        </div>
      </header>

      <main className="container mx-auto max-w-6xl p-6">
        {!dashboardData?.children || dashboardData.children.length === 0 ? (
          <EmptyState />
        ) : (
          <div className="space-y-8">
            <section>
              <h2 className="text-xl font-semibold text-gray-900 mb-4">
                {t('your_children')}
              </h2>
              <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
                {dashboardData.children.map((child) => (
                  <ChildCard key={child.id} child={child} />
                ))}
              </div>
            </section>
          </div>
        )}
      </main>
    </div>
  );
}

function EmptyState() {
  const t = useTranslations('dashboard');
  return (
    <div className="text-center space-y-6 py-12">
      <div className="text-6xl">👨‍👩‍👧‍👦</div>
      <div className="space-y-2">
        <h2 className="text-2xl font-semibold text-gray-900">{t('empty_title')}</h2>
        <p className="text-gray-600 max-w-lg mx-auto">{t('empty_body')}</p>
      </div>
      <Button variant="default" size="lg" asChild>
        <Link href="/children/new">{t('empty_cta')}</Link>
      </Button>
    </div>
  );
}

interface ChildCardProps {
  child: {
    id: string;
    name: string;
    xp: number;
    level: number;
    streak_days: number;
    today_minutes: number;
    recent_badges: any[];
    badges_count: number;
    alerts_count: number;
  };
}

function ChildCard({ child }: ChildCardProps) {
  const t = useTranslations('dashboard');
  const levelInfo = calculateLevelInfo(child.xp);

  return (
    <Card className="relative hover:shadow-lg transition-shadow">
      <CardHeader className="pb-4">
        <div className="flex items-center justify-between">
          <CardTitle className="text-lg">{child.name}</CardTitle>
          {child.alerts_count > 0 && (
            <Badge variant="destructive" className="text-xs">
              {t('alerts_count', { count: child.alerts_count })}
            </Badge>
          )}
        </div>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex items-center space-x-3">
          <AvatarDisplay avatarId="cat" size="md" />
          <div className="flex-1">
            <div className="text-sm font-medium">
              {t('level_with_name', { level: child.level, name: levelInfo.name })}
            </div>
            <div className="text-xs text-gray-500">{t('xp_total', { xp: child.xp })}</div>
          </div>
        </div>

        <div className="space-y-2">
          <div className="flex justify-between text-sm">
            <span>{t('today')}</span>
            <span>{formatTimeForKids(child.today_minutes)}</span>
          </div>
          {child.streak_days > 0 && (
            <div className="flex justify-between text-sm">
              <span>{t('streak')}</span>
              <span className="text-orange-600 font-medium">
                {t('streak_days', { days: child.streak_days })}
              </span>
            </div>
          )}
          <div className="flex justify-between text-sm">
            <span>{t('achievements')}</span>
            <span>{t('badges_count', { count: child.badges_count })}</span>
          </div>
        </div>

        <div className="pt-2 border-t">
          <Button variant="outline" size="sm" className="w-full" asChild>
            <Link href={`/children/${child.id}`}>{t('view_details')}</Link>
          </Button>
        </div>
      </CardContent>
    </Card>
  );
}
