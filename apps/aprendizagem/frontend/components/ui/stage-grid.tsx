'use client';

import { StageCard } from './stage-card';
import { FinalExamCard } from './final-exam-card';
import type { StagesResponse } from '@/types/api';

interface StageGridProps {
  stagesData: StagesResponse;
  className?: string;
}

/**
 * Grid principal do hub de stages - 4 cards de stage + 1 card final exam
 */
export function StageGrid({ stagesData, className }: StageGridProps) {
  // Defensivo: se stages nao for array (shape errado), avisa em vez de
  // renderizar grid vazio que parece blank page.
  if (!stagesData?.stages || !Array.isArray(stagesData.stages)) {
    return (
      <div className="text-center text-gray-600 bg-white/60 rounded-kid-lg p-6">
        <p className="text-kid-base font-medium">
          Formato de dados inesperado. Recarregue a página.
        </p>
      </div>
    );
  }

  return (
    <div className={className}>
      {/* Grid das 4 stages */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {stagesData.stages.map((stage) => (
          <StageCard key={stage.stage} stage={stage} />
        ))}
      </div>

      {/* Final Exam - destaque especial abaixo das stages */}
      {stagesData.final_exam && (
        <div className="flex justify-center">
          <div className="w-full max-w-md">
            <FinalExamCard finalExam={stagesData.final_exam} />
          </div>
        </div>
      )}
    </div>
  );
}