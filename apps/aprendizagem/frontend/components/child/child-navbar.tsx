'use client';

import { useEffect } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { useTranslations } from 'next-intl';
import { LogOut, Star, Award, Flame } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { Badge } from '@/components/ui/badge';
import { MascotBubble } from '@/components/ui/mascot-bubble';
import { apiClient } from '@/lib/api/client';
import { authApi } from '@/lib/api/auth';
import { config } from '@/lib/config';
import { calculateLevelInfo, getLevelFloor } from '@/lib/utils';
import useAppStore from '@/lib/store/app-store';
import { LanguageSwitcher } from '@/components/ui/language-switcher';
import type { Child } from '@/types/api';

/**
 * Navbar para crianças com mascote, XP, streak e saída.
 */
export function ChildNavbar() {
  const t = useTranslations('navbar_child');
  const router = useRouter();
  const { currentChild, setCurrentChild } = useAppStore();

  // Sync defensivo: busca o registro da crianca no backend e sincroniza
  // o zustand. GET /v1/children com auth de crianca devolve so' o proprio
  // registro (com xp/level/streak/badges_cleaned_at atualizados). Cobre o
  // caso onde o setCurrentChild do done page nao rodou (ex: chat crashou
  // e a crianca nunca chegou na tela de Parabens) - sem isso, navbar
  // mostra XP velho do zustand persist.
  const { data: freshChildren } = useQuery({
    queryKey: ['my-child', currentChild?.id],
    queryFn: async () => apiClient.get<Child[]>('children'),
    enabled: !!currentChild?.id,
    staleTime: 10_000,
  });

  useEffect(() => {
    if (!freshChildren || !currentChild?.id) return;
    const fresh = freshChildren.find((c) => c.id === currentChild.id);
    if (!fresh) return;
    // So' atualiza se algo mudou - evita re-render em loop.
    if (
      fresh.xp !== currentChild.xp ||
      fresh.level !== currentChild.level ||
      fresh.streak_days !== currentChild.streak_days
    ) {
      setCurrentChild({ ...(currentChild as Child), ...fresh });
    }
  }, [freshChildren, currentChild, setCurrentChild]);

  // Defensivo: se o login da crianca devolveu um objeto incompleto, garantimos
  // que xp/level/streak nao virem undefined (que estoura NaN na barra de XP e
  // 'Nivel undefined' no header).
  const childData = {
    id: currentChild?.id ?? 'mock',
    name: currentChild?.name ?? 'Criança',
    level: Number(currentChild?.level) || 1,
    xp: Number(currentChild?.xp) || 0,
    streak_days: Number(currentChild?.streak_days) || 0,
  };

  // Conta badges DESBLOQUEADAS (nao o catalogo todo). Endpoint devolve
  // envelope { badges: [...] } so com as ja conquistadas (JOIN child_badges).
  // Antes esse contador era hardcoded "5" - mostrava 5 mesmo pra crianca
  // sem nenhuma conquista.
  const { data: badgesData } = useQuery({
    queryKey: ['child-badges', currentChild?.id],
    queryFn: async () => {
      return apiClient.get<{ badges: Array<{ id: string }> }>(
        `children/${currentChild!.id}/badges`
      );
    },
    enabled: !!currentChild?.id,
    staleTime: 30_000,
  });
  const badgeCount = badgesData?.badges?.length ?? 0;

  // Recalcula nivel/progresso a partir do XP para evitar drift com o backend.
  const levelInfo = calculateLevelInfo(childData.xp);
  const progressToNextLevel = levelInfo.progress_percent;
  const nextLevelXp = getLevelFloor(levelInfo.current + 1);

  const handleLogout = async () => {
    // Limpa SO' o cookie de crianca - mantem pai logado se houver, pra
    // que /select funcione (middleware exige parent token). switch-profile
    // server-side decide entre /select (tem pai) ou /crianca (so child).
    await authApi.clearSession('child');
    router.push('/play/switch-profile');
  };

  return (
    <div className="bg-white shadow-lg border-b-4 border-purple-300">
      <div className="max-w-6xl mx-auto px-4 py-4">
        <div className="flex items-center justify-between">
          {/* Mascote e saudação */}
          <div className="flex items-center space-x-4">
            <div className="w-12 h-12 bg-gradient-to-br from-purple-400 to-pink-400 rounded-full flex items-center justify-center">
              <span className="text-white text-xl">🤖</span>
            </div>
            <div>
              <MascotBubble variant="cheerful">
                <span className="text-sm">{t('greeting', { name: childData.name })}</span>
              </MascotBubble>
            </div>
          </div>

          {/* Estatísticas centrais */}
          <div className="flex items-center space-x-6">
            {/* Nível e XP */}
            <div className="text-center">
              <div className="flex items-center space-x-2 mb-1">
                <Star className="w-4 h-4 text-yellow-500" />
                <span className="font-bold text-purple-700 text-lg">
                  {t('level_label', { level: childData.level })}
                </span>
              </div>
              <div className="w-32">
                <Progress value={progressToNextLevel} className="h-2" />
                <p className="text-xs text-gray-600 mt-1">
                  {t('xp_progress', { current: childData.xp, max: nextLevelXp })}
                </p>
              </div>
            </div>

            {/* Sequência: so' o numero + flame, sem palavra "dia"/"day"
                (decisao de design - o icone ja' indica streak). */}
            {childData.streak_days > 0 && (
              <div className="flex items-center space-x-2 bg-orange-100 px-3 py-2 rounded-lg">
                <Flame className="w-5 h-5 text-orange-500" />
                <p className="font-bold text-orange-700 text-lg">
                  {childData.streak_days}
                </p>
              </div>
            )}

            {/* Badge count - real (vem de GET /v1/children/{id}/badges). */}
            <div className="flex items-center space-x-2 bg-yellow-100 px-3 py-2 rounded-lg">
              <Award className="w-5 h-5 text-yellow-600" />
              <div className="text-center">
                <p className="font-bold text-yellow-700">{badgeCount}</p>
                <p className="text-xs text-yellow-600">
                  {badgeCount === 1 ? t('badges_one') : t('badges_other')}
                </p>
              </div>
            </div>
          </div>

          {/* Botão de saída */}
          <div className="flex items-center space-x-3">
            <LanguageSwitcher />
            <div className="text-right text-sm">
              <p className="font-medium text-gray-700">
                {childData.name}
              </p>
              <p className="text-xs text-gray-500">
                {config.gamification.levelNames[childData.level - 1] || `Nível ${childData.level}`}
              </p>
            </div>

            <Button
              variant="ghost"
              size="sm"
              onClick={handleLogout}
              className="text-gray-600 hover:text-gray-800"
            >
              <LogOut className="w-4 h-4 mr-1" />
              {t('logout')}
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}