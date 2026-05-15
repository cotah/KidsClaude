// Tipos baseados na spec API da secao 7
export interface ApiError {
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
}

export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

// Auth
export interface ParentSignupRequest {
  email: string;
  password: string;
  display_name?: string;
}

export interface ParentSignupResponse {
  parent_id: string;
  access_token: string;
}

export interface ParentLoginRequest {
  email: string;
  password: string;
}

export interface ParentLoginResponse {
  access_token: string;
  expires_in: number;
}

export interface ChildLoginRequest {
  child_id: string;
  pin?: string;
}

export interface ChildLoginDirectRequest {
  username: string;
  pin: string;
}

export interface ChildLoginResponse {
  access_token: string;
  expires_in: number;
  child: Child;
}

export interface ParentProfile {
  id: string;
  email: string;
  display_name?: string;
}

// Children
export interface Child {
  id: string;
  name: string;
  // Optional pra dados antigos sem username (pre migration 006).
  username?: string;
  age: number;
  avatar_id: string;
  daily_limit_minutes: number;
  level: number;
  xp: number;
  streak_days: number;
  last_active_date?: string;
  // Indica se a crianca tem PIN configurado (o hash nunca volta para o cliente)
  pin_set?: boolean;
}

export interface CreateChildRequest {
  name: string;
  username: string;
  age: number;
  avatar_id: string;
  pin?: string;
  daily_limit_minutes?: number;
}

export interface UpdateChildRequest {
  name?: string;
  username?: string;
  age?: number;
  avatar_id?: string;
  pin?: string;
  daily_limit_minutes?: number;
}

// Stages
export interface Stage {
  stage: number;
  name: string;
  description: string;
  age_band_label: string;
  difficulty: string;
  is_unlocked: boolean;
  lessons_total: number;
  lessons_completed: number;
  is_completed: boolean;
}

export interface FinalExam {
  lesson_id: string;
  is_unlocked: boolean;
  is_completed: boolean;
  label: string;
  claude_model: string;
}

export interface StagesResponse {
  stages: Stage[];
  final_exam: FinalExam;
}

// Lessons
export interface ContentBlock {
  type: 'text' | 'image' | 'video' | 'animation';
  // content e' obrigatorio em blocos de texto, opcional em image/video
  // (que podem usar src/alt no lugar). Mantemos string para nao quebrar
  // os call sites existentes que assumem string.
  content: string;
  // Campos extras suportados pelo schema backend (schemas/lessons.py
  // ContentBlock). image blocks usam alt/src; outros tipos podem usar
  // metadata. Todos opcionais para nao quebrar dados antigos.
  src?: string;
  alt?: string;
  metadata?: Record<string, any>;
}

export interface Lesson {
  id: string;
  slug: string;
  title: string;
  description: string;
  age_band: '6-8' | '9-10' | '11-12' | '12+';
  stage: number;
  is_final_exam: boolean;
  claude_model: string;
  order_index: number;
  content_blocks: ContentBlock[];
  prerequisites: string[];
  xp_reward: number;
  is_locked: boolean;
  challenges?: Challenge[];
  prompt_templates?: PromptTemplate[];
}

export interface LessonProgress {
  lesson_id: string;
  status: 'not_started' | 'in_progress' | 'completed';
  xp_earned: number;
  started_at?: string;
  completed_at?: string;
  // Titulo da licao incluido para evitar lookup adicional no cliente
  lesson_title?: string;
}

export interface LessonCompletionResponse {
  // XP ganho NESTA conclusao. 0 se a licao ja estava completed antes.
  xp_earned: number;
  xp_total: number;
  level: number;
  badges_unlocked: Badge[];
  stage_unlocked?: number;
}

// Challenges
export interface Challenge {
  id: string;
  lesson_id: string;
  kind: 'multiple_choice' | 'fill_prompt';
  question: Record<string, any>;
  correct_answer: Record<string, any>;
  xp_reward: number;
}

export interface ChallengeAttemptRequest {
  answer: Record<string, any>;
}

export interface ChallengeAttemptResponse {
  is_correct: boolean;
  xp_earned: number;
  correct_answer?: Record<string, any>;
}

// Chat & Prompts
export interface PromptTemplate {
  id: string;
  lesson_id: string;
  label: string;
  template: string;
  // null/empty pra templates "fechados" (sem campos editaveis) - usuario
  // so' clica e envia. Migration 005/007 cria todos como slots=NULL.
  slots:
    | Array<{
        name: string;
        max_length: number;
        allowed_chars: string;
      }>
    | null;
  age_band: '6-8' | '9-10' | '11-12' | '12+';
  order_index: number;
}

export interface ChatSession {
  id: string;
  child_id: string;
  lesson_id: string;
  started_at: string;
  ended_at?: string;
  safety_status: 'green' | 'yellow' | 'red';
  summary?: string;
  message_count: number;
  messages?: ChatMessage[];
}

export interface ChatMessage {
  id: string;
  session_id: string;
  role: 'child' | 'assistant' | 'system';
  template_id?: string;
  content: string;
  moderation_status: 'passed' | 'blocked';
  moderation_reason?: string;
  created_at: string;
}

export interface CreateChatSessionRequest {
  lesson_id: string;
}

export interface CreateChatSessionResponse {
  session_id: string;
  started_at: string;
}

export interface SendMessageRequest {
  template_id: string;
  slots?: Record<string, string>;
}

export interface SendMessageResponse {
  message_id: string;
  assistant_message: {
    content: string;
    moderation_status: 'passed' | 'blocked';
  };
}

// Exam (Final Capstone)
export interface ExamSession {
  session_id: string;
  started_at: string;
  lesson_id: string;
}

export interface ExamMessageRequest {
  content: string;
}

export interface ExamMessageResponse {
  message_id: string;
  assistant_message: {
    content: string;
  };
  current_step: number;
  is_complete: boolean;
}

export interface ExamSubmitResponse {
  xp_earned: number;
  badges_unlocked: string[];
  summary: string;
  plan: {
    problem: string;
    users: string;
    features: string;
    screen: string;
    first_step: string;
  };
}

// Badges & Gamification
export interface Badge {
  id: string;
  code: string;
  name: string;
  description: string;
  icon: string;
  unlock_rule: Record<string, any>;
  awarded_at?: string;
}

export interface ChildBadge {
  id: string;
  child_id: string;
  badge_id: string;
  badge_code: string;
  badge_name: string;
  badge_description: string;
  badge_icon: string;
  awarded_at: string;
}

export interface DailyUsage {
  child_id: string;
  usage_date: string;
  minutes_used: number;
}

// Usage & Safety
export interface UsageRecord {
  date: string;
  minutes_used: number;
}

export interface HeartbeatRequest {
  seconds: number;
}

export interface HeartbeatResponse {
  minutes_today: number;
  limit: number;
  blocked: boolean;
}

export interface SafetyEvent {
  id: string;
  child_id: string;
  session_id?: string;
  kind: 'input_blocked' | 'output_blocked' | 'session_terminated';
  details: Record<string, any>;
  created_at: string;
}

// Dashboard
export interface DashboardData {
  children: Array<{
    id: string;
    name: string;
    xp: number;
    level: number;
    streak_days: number;
    today_minutes: number;
    recent_badges: Badge[];
    alerts_count: number;
  }>;
}

// Health
export interface HealthResponse {
  status: 'ok' | 'error';
  version: string;
  db: 'ok' | 'error';
  anthropic: 'ok' | 'error';
}