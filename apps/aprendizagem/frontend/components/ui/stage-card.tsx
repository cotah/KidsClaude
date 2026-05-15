'use client';

import Link from 'next/link';
import { LockIcon, CheckCircleIcon } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { Button } from './button';
import { KidCard } from './card';
import { Badge } from './badge';
import { Progress } from './progress';
import { cn } from '@/lib/utils';
import type { Stage } from '@/types/api';

interface StageCardProps {
  stage: Stage;
  className?: string;
}

/**
 * Card individual de stage conforme curriculum redesign
 * Mostra progresso, status de desbloqueio e dificuldade
 */
export function StageCard({ stage, className }: StageCardProps) {
  // Sobrescreve nome/descricao/age_band do backend com a versao traduzida.
  // Backend devolve hardcoded em PT (stages.py); JSON tem ambas as linguas.
  const tInfo = useTranslations('stage_info');
  const tCard = useTranslations('stage_page');
  const tLesson = useTranslations('lesson');
  const tStageCard = useTranslations('stage_card');

  const getDifficultyColor = (difficulty: string) => {
    switch (difficulty) {
      case 'easy':
        return 'bg-green-100 text-green-700';
      case 'medium':
        return 'bg-yellow-100 text-yellow-700';
      case 'hard':
        return 'bg-orange-100 text-orange-700';
      case 'advanced':
        return 'bg-red-100 text-red-700';
      default:
        return 'bg-gray-100 text-gray-700';
    }
  };

  const getColorScheme = () => {
    // 'ocean' como neutro pra stage bloqueada - 'gray' nao existe no KidCard
    // (so 'sunny|ocean|mint|sunset|grape') e devolve undefined nas classes,
    // deixando o card sem fundo.
    if (!stage.is_unlocked) return 'ocean';
    if (stage.is_completed) return 'mint';
    return 'sunny';
  };

  const getStatusInfo = () => {
    if (!stage.is_unlocked) {
      return {
        action: tLesson('button_locked'),
        icon: <LockIcon className="w-4 h-4" />,
        disabled: true,
      };
    }
    if (stage.is_completed) {
      return {
        action: tLesson('button_review'),
        icon: <CheckCircleIcon className="w-4 h-4" />,
        disabled: false,
      };
    }
    return {
      action: tLesson('button_continue'),
      icon: null,
      disabled: false,
    };
  };

  const statusInfo = getStatusInfo();
  const progressPercentage = stage.lessons_total > 0 ? (stage.lessons_completed / stage.lessons_total) * 100 : 0;

  return (
    <KidCard
      colorScheme={getColorScheme() as any}
      className={cn(
        'relative overflow-hidden transition-all duration-200',
        !stage.is_unlocked && 'opacity-50 cursor-not-allowed',
        stage.is_unlocked && 'hover:scale-105',
        className
      )}
    >
      <div className="p-6 space-y-4">
        {/* Header com numero da stage e badge de dificuldade */}
        <div className="flex justify-between items-start">
          <div className="flex items-center space-x-3">
            <div className="w-12 h-12 bg-white/80 rounded-full flex items-center justify-center border-2 border-current">
              <span className="text-2xl font-bold">{stage.stage}</span>
            </div>
            <div>
              <h3 className="text-kid-lg font-bold text-gray-800">
                {tInfo(`${stage.stage}.name`)}
              </h3>
              <span className="text-kid-sm text-gray-600">
                {tInfo(`${stage.stage}.age_band_label`)}
              </span>
            </div>
          </div>
          <div className="flex flex-col items-end space-y-2">
            <Badge
              variant="secondary"
              className={cn('text-kid-xs', getDifficultyColor(stage.difficulty))}
            >
              {stage.difficulty}
            </Badge>
            {!stage.is_unlocked && (
              <LockIcon className="w-5 h-5 text-gray-400" />
            )}
          </div>
        </div>

        {/* Descrição */}
        <p className="text-kid-base text-gray-600 line-clamp-2">
          {tInfo(`${stage.stage}.description`)}
        </p>

        {/* Barra de progresso */}
        <div className="space-y-2">
          <div className="flex justify-between items-center text-kid-sm">
            <span className="text-gray-600">{tCard('stage_progress')}</span>
            <span className="font-medium text-gray-800">
              {tCard('lessons_count', { completed: stage.lessons_completed, total: stage.lessons_total })}
            </span>
          </div>
          <Progress
            value={progressPercentage}
            className="h-2"
          />
        </div>

        {/* Botão de ação */}
        <Button
          variant={getColorScheme() as any}
          size="kid-default"
          className="w-full"
          asChild
          disabled={statusInfo.disabled}
        >
          {statusInfo.disabled ? (
            <div className="flex items-center justify-center space-x-2">
              {statusInfo.icon}
              <span>{statusInfo.action}</span>
            </div>
          ) : (
            <Link href={`/play/stage/${stage.stage}` as any} className="flex items-center justify-center space-x-2">
              {statusInfo.icon}
              <span>{statusInfo.action}</span>
            </Link>
          )}
        </Button>

        {/* Tooltip para stages bloqueadas */}
        {!stage.is_unlocked && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/10 backdrop-blur-sm">
            <div className="bg-white/90 text-gray-800 text-kid-sm px-3 py-2 rounded-kid-md shadow-lg">
              {tStageCard('locked_hint', { previous: stage.stage - 1 })}
            </div>
          </div>
        )}
      </div>
    </KidCard>
  );
}