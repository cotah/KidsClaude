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
  return (
    <div className={className}>
      {/* Grid das 4 stages */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
        {stagesData.stages.map((stage) => (
          <StageCard key={stage.stage} stage={stage} />
        ))}
      </div>

      {/* Final Exam - destaque especial abaixo das stages */}
      <div className="flex justify-center">
        <div className="w-full max-w-md">
          <FinalExamCard finalExam={stagesData.final_exam} />
        </div>
      </div>
    </div>
  );
}