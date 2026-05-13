// Tipos específicos da aplicação frontend - agora com 4 age bands conforme curriculum redesign
export type AgeGroup = '6-8' | '9-10' | '11-12' | '12+';

export interface Avatar {
  id: string;
  name: string;
  imageUrl: string;
  suitable_for: AgeGroup[];
}

export interface AppState {
  currentChild?: {
    id: string;
    name: string;
    age: number;
    avatar_id: string;
    level: number;
    xp: number;
    streak_days: number;
  };
  session?: {
    type: 'parent' | 'child';
    token: string;
    expires_at: number;
  };
  usage?: {
    minutes_today: number;
    limit: number;
    blocked: boolean;
  };
}

export interface LessonPlayerState {
  currentBlockIndex: number;
  completed: boolean;
  startedAt: Date;
}

export interface XPGain {
  amount: number;
  source: 'lesson' | 'challenge' | 'streak';
  timestamp: Date;
}

export interface ToastMessage {
  id: string;
  type: 'success' | 'error' | 'warning' | 'info';
  title: string;
  description?: string;
  duration?: number;
}

// Mock data interfaces para desenvolvimento
export interface MockConfig {
  enabled: boolean;
  delayMs?: number;
  failureRate?: number;
}

// Speech synthesis types
export interface TTSOptions {
  lang: string;
  rate: number;
  pitch: number;
  volume: number;
}

// Gaming elements
export interface StreakData {
  current_days: number;
  best_streak: number;
  last_activity_date?: string;
}

export interface LevelInfo {
  current: number;
  name: string;
  xp_current: number;
  xp_required: number;
  progress_percent: number;
}

// Form validation types
export interface FormError {
  field: string;
  message: string;
}

export interface ParentFormData {
  email: string;
  password: string;
  confirmPassword?: string;
  displayName?: string;
  termsAccepted: boolean;
  consentAccepted: boolean;
}

export interface ChildFormData {
  name: string;
  age: number;
  avatarId: string;
  pin?: string;
  confirmPin?: string;
  dailyLimitMinutes: number;
}