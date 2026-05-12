import { describe, it, expect } from 'vitest';
import { config } from '@/lib/config';
import {
  getLevelFromXp,
  getLevelFloor,
  getProgressToNextLevel,
  calculateLevelInfo,
} from '@/lib/utils';

// Testes da matematica de gamificacao. Espelham o backend (gamification.py):
// xp_per_level(n) = 100 * n * (n+1) / 2 e' o threshold para alcancar nivel n+1.
// Floor para nivel 1 = 0; para n>=2 = xp_per_level(n).
//   nivel 1: 0..299
//   nivel 2: 300..599
//   nivel 3: 600..999
describe('Gamificacao — formulas basicas', () => {
  it('xpPerLevel segue a formula triangular do spec', () => {
    expect(config.gamification.xpPerLevel(1)).toBe(100);
    expect(config.gamification.xpPerLevel(2)).toBe(300);
    expect(config.gamification.xpPerLevel(3)).toBe(600);
    expect(config.gamification.xpPerLevel(5)).toBe(1500);
    expect(config.gamification.xpPerLevel(10)).toBe(5500);
  });

  it('getLevelFromXp casa com calculate_level_from_xp do backend', () => {
    expect(getLevelFromXp(0)).toBe(1);
    expect(getLevelFromXp(99)).toBe(1);
    expect(getLevelFromXp(299)).toBe(1);
    expect(getLevelFromXp(300)).toBe(2);
    expect(getLevelFromXp(599)).toBe(2);
    expect(getLevelFromXp(600)).toBe(3);
    expect(getLevelFromXp(1499)).toBe(4);
    expect(getLevelFromXp(1500)).toBe(5);
  });

  it('getLevelFromXp lida com XP negativo (clamp em 1)', () => {
    expect(getLevelFromXp(-100)).toBe(1);
  });

  it('getLevelFromXp limita no nivel 10', () => {
    expect(getLevelFromXp(10000)).toBe(10);
    expect(getLevelFromXp(999999)).toBe(10);
  });

  it('getLevelFloor retorna 0 para nivel 1 e xpPerLevel(n) para n>=2', () => {
    expect(getLevelFloor(1)).toBe(0);
    expect(getLevelFloor(2)).toBe(300);
    expect(getLevelFloor(3)).toBe(600);
  });
});

describe('Gamificacao — progresso para o proximo nivel', () => {
  it('nivel 1: range 0..300 XP', () => {
    expect(getProgressToNextLevel(0, 1)).toBe(0);
    expect(getProgressToNextLevel(150, 1)).toBe(50);
    expect(getProgressToNextLevel(300, 1)).toBe(100);
  });

  it('nivel 2: range 300..600 XP', () => {
    expect(getProgressToNextLevel(300, 2)).toBe(0);
    expect(getProgressToNextLevel(450, 2)).toBe(50);
    expect(getProgressToNextLevel(600, 2)).toBe(100);
  });

  it('clamp em 0 quando XP esta abaixo do floor', () => {
    expect(getProgressToNextLevel(0, 2)).toBe(0);
  });

  it('clamp em 100 quando XP excede o ceiling', () => {
    expect(getProgressToNextLevel(9999, 2)).toBe(100);
  });

  it('nivel maximo (10) sempre retorna 100', () => {
    expect(getProgressToNextLevel(0, 10)).toBe(100);
    expect(getProgressToNextLevel(99999, 10)).toBe(100);
  });
});

describe('Gamificacao — calculateLevelInfo', () => {
  it('XP zero corresponde ao nivel 1 com 0% de progresso', () => {
    const info = calculateLevelInfo(0);
    expect(info.current).toBe(1);
    expect(info.name).toBe('Curioso');
    expect(info.xp_current).toBe(0);
    expect(info.xp_required).toBe(300);
    expect(info.progress_percent).toBe(0);
  });

  it('XP=150 fica na metade do nivel 1', () => {
    const info = calculateLevelInfo(150);
    expect(info.current).toBe(1);
    expect(info.xp_current).toBe(150);
    expect(info.progress_percent).toBe(50);
  });

  it('XP=300 e o inicio do nivel 2', () => {
    const info = calculateLevelInfo(300);
    expect(info.current).toBe(2);
    expect(info.xp_current).toBe(0);
    expect(info.xp_required).toBe(300);
    expect(info.progress_percent).toBe(0);
  });

  it('XP suficiente para nivel 5', () => {
    const info = calculateLevelInfo(1500);
    expect(info.current).toBe(5);
    expect(info.name).toBe('Mestre dos Prompts');
  });
});

describe('Gamificacao — nomes de niveis', () => {
  it('temos 10 nomes de nivel configurados', () => {
    expect(config.gamification.levelNames).toHaveLength(10);
    expect(config.gamification.levelNames[0]).toBe('Curioso');
    expect(config.gamification.levelNames[9]).toBe('Lendário');
  });
});
