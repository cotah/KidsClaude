import { type ClassValue, clsx } from 'clsx';
import { twMerge } from 'tailwind-merge';
import { config } from './config';
import type { AgeGroup, LevelInfo } from '@/types/app';

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

/**
 * Formatar tempo em formato legível para crianças
 */
export function formatTimeForKids(minutes: number): string {
  if (minutes < 60) {
    return `${minutes} min`;
  }
  const hours = Math.floor(minutes / 60);
  const remainingMinutes = minutes % 60;
  if (remainingMinutes === 0) {
    return `${hours}h`;
  }
  return `${hours}h ${remainingMinutes}min`;
}

/**
 * Formatar data relativa para crianças
 */
export function formatDateForKids(date: Date | string): string {
  const d = typeof date === 'string' ? new Date(date) : date;
  const now = new Date();
  const diffInHours = (now.getTime() - d.getTime()) / (1000 * 60 * 60);

  if (diffInHours < 1) {
    return 'Agora há pouco';
  }
  if (diffInHours < 24) {
    return 'Hoje';
  }
  if (diffInHours < 48) {
    return 'Ontem';
  }
  if (diffInHours < 24 * 7) {
    const days = Math.floor(diffInHours / 24);
    return `${days} dias atrás`;
  }

  return d.toLocaleDateString('pt-BR', {
    day: 'numeric',
    month: 'short'
  });
}

/**
 * Calcula o nivel da crianca a partir do XP total acumulado.
 * Espelha o backend (gamification.calculate_level_from_xp):
 *   xp_per_level(n) = 100 * n * (n+1) / 2 e' o threshold para alcancar nivel n+1.
 *   Floor para nivel n: 0 se n=1, senao xp_per_level(n).
 * Exemplos: xp=0 -> nivel 1, xp=299 -> nivel 1, xp=300 -> nivel 2, xp=600 -> nivel 3.
 */
export function getLevelFromXp(xp: number): number {
  if (xp < 0) return 1;
  let level = 1;
  while (level < 10 && config.gamification.xpPerLevel(level + 1) <= xp) {
    level++;
  }
  return level;
}

/**
 * Floor de XP para um dado nivel (XP minimo para estar nesse nivel).
 * Floor para nivel 1 e' 0; para n>=2 e' xp_per_level(n).
 */
export function getLevelFloor(level: number): number {
  if (level <= 1) return 0;
  return config.gamification.xpPerLevel(level);
}

/**
 * Percentual de progresso entre o floor do nivel atual e o do proximo nivel.
 * Sempre entre 0 e 100. No nivel maximo (10) sempre retorna 100.
 */
export function getProgressToNextLevel(xp: number, level: number): number {
  if (level >= 10) return 100;
  const floor = getLevelFloor(level);
  const ceiling = getLevelFloor(level + 1);
  const required = ceiling - floor;
  if (required <= 0) return 100;
  const raw = ((xp - floor) / required) * 100;
  return Math.min(100, Math.max(0, raw));
}

/**
 * Calcula informacoes do nivel atual a partir do XP total.
 */
export function calculateLevelInfo(xp: number): LevelInfo {
  const level = getLevelFromXp(xp);
  const floor = getLevelFloor(level);
  const ceiling = getLevelFloor(level + 1);
  const xp_current = xp - floor;
  const xp_needed = ceiling - floor;
  const progress_percent = getProgressToNextLevel(xp, level);

  return {
    current: level,
    name: config.gamification.levelNames[level - 1] || 'Aprendiz',
    xp_current,
    xp_required: xp_needed,
    progress_percent: Math.round(progress_percent),
  };
}

/**
 * Obter faixa etária baseada na idade
 */
export function getAgeGroup(age: number): AgeGroup {
  return age <= 8 ? '6-8' : '9-12';
}

/**
 * Validar PIN numérico
 */
export function isValidPin(pin: string): boolean {
  return /^\d{4}$/.test(pin);
}

/**
 * Validar email
 */
export function isValidEmail(email: string): boolean {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  return emailRegex.test(email);
}

/**
 * Validar senha forte
 */
export function isValidPassword(password: string): boolean {
  return password.length >= 8 &&
         /[a-zA-Z]/.test(password) &&
         /\d/.test(password);
}

/**
 * Obter erros de validação de senha
 */
export function getPasswordValidationErrors(password: string): string[] {
  const errors: string[] = [];

  if (password.length < 8) {
    errors.push('Mínimo 8 caracteres');
  }
  if (!/[a-zA-Z]/.test(password)) {
    errors.push('Pelo menos uma letra');
  }
  if (!/\d/.test(password)) {
    errors.push('Pelo menos um número');
  }

  return errors;
}

/**
 * Escapar HTML para prevenir XSS
 */
export function escapeHtml(text: string): string {
  const map: Record<string, string> = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&#039;'
  };
  return text.replace(/[&<>"']/g, (m) => map[m]);
}

/**
 * Sanitizar nome da criança (remover caracteres perigosos)
 */
export function sanitizeChildName(name: string): string {
  return name
    .trim()
    .replace(/[<>]/g, '') // Remove caracteres HTML perigosos
    .substring(0, config.limits.childNameMaxLength);
}

/**
 * Gerar ID único
 */
export function generateId(): string {
  return Math.random().toString(36).substring(2) + Date.now().toString(36);
}

/**
 * Delay para testing/desenvolvimento
 */
export function delay(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Truncar texto com elipses
 */
export function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) return text;
  return text.substring(0, maxLength).trim() + '...';
}

/**
 * Obter cor baseada na faixa etária
 */
export function getAgeGroupColor(age: number): string {
  const ageGroup = getAgeGroup(age);
  return ageGroup === '6-8' ? 'sunny' : 'ocean';
}

/**
 * Formatar erro de API para exibição
 */
export function formatApiError(error: any): string {
  if (error?.error?.message) {
    return error.error.message;
  }
  if (error?.message) {
    return error.message;
  }
  return 'Algo deu errado. Tente novamente.';
}

/**
 * Verificar se device é touch
 */
export function isTouchDevice(): boolean {
  return typeof window !== 'undefined' &&
         ('ontouchstart' in window || navigator.maxTouchPoints > 0);
}

/**
 * Obter classes CSS baseadas na idade
 */
export function getAgeGroupClasses(age: number) {
  const ageGroup = getAgeGroup(age);
  return {
    text: ageGroup === '6-8' ? 'age-6-8' : 'age-9-12',
    button: ageGroup === '6-8' ? 'kid-button-lg' : 'kid-button',
    spacing: ageGroup === '6-8' ? 'space-y-8' : 'space-y-6',
    container: ageGroup === '6-8' ? 'p-8' : 'p-6',
  };
}