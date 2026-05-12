'use client';

import { useQuery } from '@tanstack/react-query';
import { useRouter } from 'next/navigation';
import { LogOut, Star, Award, Flame } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Progress } from '@/components/ui/progress';
import { Badge } from '@/components/ui/badge';
import { MascotBubble } from '@/components/ui/mascot-bubble';
import { authApi } from '@/lib/api/auth';
import { config } from '@/lib/config';
import { calculateLevelInfo, getLevelFloor } from '@/lib/utils';
import useAppStore from '@/lib/store/app-store';

/**
 * Navbar para crianças com mascote, XP, streak e saída.
 */
export function ChildNavbar() {
  const router = useRouter();
  const { currentChild } = useAppStore();

  // Simulando dados da criança logada
  const childData = currentChild || {
    id: 'mock',
    name: 'Criança',
    level: 1,
    xp: 50,
    streak_days: 0,
  };

  // Recalcula nivel/progresso a partir do XP para evitar drift com o backend.
  const levelInfo = calculateLevelInfo(childData.xp);
  const progressToNextLevel = levelInfo.progress_percent;
  const nextLevelXp = getLevelFloor(levelInfo.current + 1);

  const handleLogout = async () => {
    await authApi.clearSession();
    router.push('/select');
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
                <span className="text-sm">
                  Oi, {childData.name}! Pronto para aprender?
                </span>
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
                  Nível {childData.level}
                </span>
              </div>
              <div className="w-32">
                <Progress value={progressToNextLevel} className="h-2" />
                <p className="text-xs text-gray-600 mt-1">
                  {childData.xp} / {nextLevelXp} XP
                </p>
              </div>
            </div>

            {/* Sequência */}
            {childData.streak_days > 0 && (
              <div className="flex items-center space-x-2 bg-orange-100 px-3 py-2 rounded-lg">
                <Flame className="w-5 h-5 text-orange-500" />
                <div className="text-center">
                  <p className="font-bold text-orange-700">{childData.streak_days}</p>
                  <p className="text-xs text-orange-600">dias</p>
                </div>
              </div>
            )}

            {/* Badge count (simulado) */}
            <div className="flex items-center space-x-2 bg-yellow-100 px-3 py-2 rounded-lg">
              <Award className="w-5 h-5 text-yellow-600" />
              <div className="text-center">
                <p className="font-bold text-yellow-700">5</p>
                <p className="text-xs text-yellow-600">badges</p>
              </div>
            </div>
          </div>

          {/* Botão de saída */}
          <div className="flex items-center space-x-3">
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
              Sair
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}