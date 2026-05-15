'use client';

import Link from 'next/link';
import { LockIcon, CheckCircleIcon, CrownIcon } from 'lucide-react';
import { useTranslations } from 'next-intl';
import { Button } from './button';
import { KidCard } from './card';
import { cn } from '@/lib/utils';
import type { FinalExam } from '@/types/api';

interface FinalExamCardProps {
  finalExam: FinalExam;
  className?: string;
}

/**
 * Card especial para o exame final com visual diferenciado (dourado/roxo)
 */
export function FinalExamCard({ finalExam, className }: FinalExamCardProps) {
  const tCard = useTranslations('final_exam_card');

  const getStatusInfo = () => {
    if (!finalExam.is_unlocked) {
      return {
        action: 'Bloqueado',
        icon: <LockIcon className="w-4 h-4" />,
        disabled: true,
        description: tCard('locked_message'),
      };
    }
    if (finalExam.is_completed) {
      return {
        action: 'Revisar Projeto',
        icon: <CheckCircleIcon className="w-4 h-4" />,
        disabled: false,
        description: 'Você construiu algo incrível!',
      };
    }
    return {
      action: 'Começar Projeto',
      icon: <CrownIcon className="w-4 h-4" />,
      disabled: false,
      description: 'Pronto para o desafio final?',
    };
  };

  const statusInfo = getStatusInfo();

  return (
    <KidCard
      className={cn(
        'relative overflow-hidden transition-all duration-200',
        'bg-gradient-to-br from-purple-100 via-yellow-100 to-purple-200',
        'border-2 border-gradient-to-r from-purple-300 to-yellow-300',
        !finalExam.is_unlocked && 'opacity-50 cursor-not-allowed',
        finalExam.is_unlocked && 'hover:scale-105 hover:shadow-lg',
        className
      )}
    >
      <div className="p-6 space-y-4">
        {/* Header especial com coroa */}
        <div className="flex items-center justify-center space-x-3 mb-4">
          <div className="w-14 h-14 bg-gradient-to-br from-yellow-400 to-purple-500 rounded-full flex items-center justify-center border-2 border-white shadow-lg">
            <CrownIcon className="w-8 h-8 text-white" />
          </div>
          <div className="text-center">
            <h3 className="text-kid-xl font-bold bg-gradient-to-r from-purple-600 to-yellow-600 bg-clip-text text-transparent">
              {finalExam.label}
            </h3>
            <span className="text-kid-sm text-purple-700 font-medium">
              Capstone Project
            </span>
          </div>
        </div>

        {/* Descrição especial */}
        <div className="text-center space-y-2">
          <p className="text-kid-base text-purple-800 font-medium">
            Planeje seu app dos sonhos em 5 passos
          </p>
          <p className="text-kid-sm text-purple-600">
            {statusInfo.description}
          </p>
        </div>

        {/* Info especial sobre o Claude Sonnet */}
        {finalExam.is_unlocked && (
          <div className="bg-white/60 rounded-kid-lg p-3 text-center">
            <p className="text-kid-xs text-purple-700">
              ✨ Powered by Claude Sonnet — nossa IA mais avançada
            </p>
          </div>
        )}

        {/* Botão de ação especial */}
        <Button
          variant="default"
          size="kid-lg"
          className={cn(
            'w-full font-bold',
            'bg-gradient-to-r from-purple-500 to-yellow-500',
            'hover:from-purple-600 hover:to-yellow-600',
            'text-white shadow-lg',
            statusInfo.disabled && 'opacity-50 cursor-not-allowed'
          )}
          asChild
          disabled={statusInfo.disabled}
        >
          {statusInfo.disabled ? (
            <div className="flex items-center justify-center space-x-2">
              {statusInfo.icon}
              <span>{statusInfo.action}</span>
            </div>
          ) : (
            <Link href={"/play/exam" as any} className="flex items-center justify-center space-x-2">
              {statusInfo.icon}
              <span>{statusInfo.action}</span>
            </Link>
          )}
        </Button>

        {/* Tooltip para exame bloqueado */}
        {!finalExam.is_unlocked && (
          <div className="absolute inset-0 flex items-center justify-center bg-black/10 backdrop-blur-sm rounded-kid-lg">
            <div className="bg-white/95 text-purple-800 text-kid-sm px-4 py-3 rounded-kid-md shadow-lg text-center max-w-[200px]">
              <LockIcon className="w-5 h-5 mx-auto mb-1" />
              <p className="font-medium">{tCard('locked_message')}</p>
            </div>
          </div>
        )}
      </div>
    </KidCard>
  );
}