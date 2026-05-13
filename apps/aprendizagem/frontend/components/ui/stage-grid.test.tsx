import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { StageGrid } from './stage-grid';
import { mockStagesResponse } from '@/lib/mock/data';

describe('StageGrid', () => {
  it('renders 4 stage cards plus final exam', () => {
    render(<StageGrid stagesData={mockStagesResponse} />);

    // Should show all 4 stages
    expect(screen.getByText('Discovery')).toBeInTheDocument();
    expect(screen.getByText('Exploration')).toBeInTheDocument();
    expect(screen.getByText('Creation')).toBeInTheDocument();
    expect(screen.getByText('Prompt Engineering')).toBeInTheDocument();

    // Should show the final exam
    expect(screen.getByText('Projeto Final')).toBeInTheDocument();
  });

  it('shows stage progress correctly', () => {
    render(<StageGrid stagesData={mockStagesResponse} />);

    // Stage 1 should show 2/4 completed (from mock data)
    expect(screen.getByText('2 / 4 lições')).toBeInTheDocument();
  });

  it('shows locked stages as disabled', () => {
    render(<StageGrid stagesData={mockStagesResponse} />);

    // Stage 2-4 and final exam should be locked in mock data
    const lockedElements = screen.getAllByText('Bloqueado');
    expect(lockedElements.length).toBeGreaterThan(0);
  });
});