// Mock data para desenvolvimento quando NEXT_PUBLIC_USE_MOCKS=true
import type { Child, Lesson, Badge, ChatSession, PromptTemplate } from '@/types/api';
import type { Avatar } from '@/types/app';

export const mockAvatars: Avatar[] = [
  {
    id: 'cat',
    name: 'Gatinho',
    imageUrl: '/avatars/cat.svg',
    suitable_for: ['6-8', '9-12'],
  },
  {
    id: 'dog',
    name: 'Cachorro',
    imageUrl: '/avatars/dog.svg',
    suitable_for: ['6-8', '9-12'],
  },
  {
    id: 'unicorn',
    name: 'Unicórnio',
    imageUrl: '/avatars/unicorn.svg',
    suitable_for: ['6-8'],
  },
  {
    id: 'robot',
    name: 'Robô',
    imageUrl: '/avatars/robot.svg',
    suitable_for: ['9-12'],
  },
  {
    id: 'dragon',
    name: 'Dragão',
    imageUrl: '/avatars/dragon.svg',
    suitable_for: ['9-12'],
  },
];

export const mockChildren: Child[] = [
  {
    id: 'child-1',
    name: 'Ana',
    age: 7,
    avatar_id: 'cat',
    daily_limit_minutes: 30,
    level: 3,
    xp: 285,
    streak_days: 5,
    last_active_date: '2024-01-15',
  },
  {
    id: 'child-2',
    name: 'Pedro',
    age: 10,
    avatar_id: 'robot',
    daily_limit_minutes: 45,
    level: 2,
    xp: 150,
    streak_days: 2,
    last_active_date: '2024-01-14',
  },
];

export const mockLessons: Lesson[] = [
  {
    id: 'lesson-1',
    slug: 'conhecendo-claude',
    title: 'Conhecendo a Claude',
    description: 'Descubra quem é a Claude e como ela pode te ajudar a aprender!',
    age_band: '6-8',
    order_index: 1,
    content_blocks: [
      {
        type: 'text',
        content: 'Olá! Eu sou a Claude, sua nova amiga digital. Vou te ensinar como conversar comigo de forma divertida!',
      },
      {
        type: 'image',
        content: '/illustrations/claude-intro.svg',
        metadata: { alt: 'Claude acenando' },
      },
      {
        type: 'text',
        content: 'Posso te ajudar a criar histórias, responder perguntas e aprender coisas novas. Que tal começarmos?',
      },
    ],
    prerequisites: [],
    xp_reward: 50,
    is_locked: false,
  },
  {
    id: 'lesson-2',
    slug: 'primeiros-prompts',
    title: 'Meus Primeiros Prompts',
    description: 'Aprenda a fazer perguntas que a Claude entende bem!',
    age_band: '9-12',
    order_index: 2,
    content_blocks: [
      {
        type: 'text',
        content: 'Um prompt é como uma pergunta especial que fazemos para a Claude. Quanto mais clara for sua pergunta, melhor ela te ajuda!',
      },
      {
        type: 'text',
        content: 'Experimente usar palavras como "me ajude", "explique" ou "crie uma história sobre".',
      },
    ],
    prerequisites: ['lesson-1'],
    xp_reward: 75,
    is_locked: false,
  },
];

export const mockBadges: Badge[] = [
  {
    id: 'badge-1',
    code: 'FIRST_STEPS',
    name: 'Primeiros Passos',
    description: 'Completou sua primeira lição',
    icon: 'star',
    unlock_rule: { type: 'lesson_completed', count: 1 },
  },
  {
    id: 'badge-2',
    code: 'QUICK_LEARNER',
    name: 'Aprendiz Rápido',
    description: 'Completou 5 lições',
    icon: 'zap',
    unlock_rule: { type: 'lesson_completed', count: 5 },
  },
  {
    id: 'badge-3',
    code: 'STREAK_3',
    name: 'Trio Vencedor',
    description: 'Streak de 3 dias',
    icon: 'flame',
    unlock_rule: { type: 'streak', days: 3 },
  },
];

export const mockPromptTemplates: PromptTemplate[] = [
  {
    id: 'prompt-1',
    lesson_id: 'lesson-1',
    label: 'Diga oi para a Claude!',
    template: 'Olá Claude, como você está hoje?',
    slots: [],
    age_band: '6-8',
    order_index: 1,
  },
  {
    id: 'prompt-2',
    lesson_id: 'lesson-1',
    label: 'Peça uma história',
    template: 'Conte uma história sobre {{animal}}',
    slots: [
      {
        name: 'animal',
        max_length: 20,
        allowed_chars: '^[A-Za-zÀ-ÿ ]+$',
      },
    ],
    age_band: '9-12',
    order_index: 1,
  },
];

export const mockChatSession: ChatSession = {
  id: 'session-1',
  child_id: 'child-1',
  lesson_id: 'lesson-1',
  started_at: '2024-01-15T14:30:00Z',
  safety_status: 'green',
  summary: 'Conversa sobre animais e histórias. Criança demonstrou interesse em gatos.',
  message_count: 4,
  messages: [
    {
      id: 'msg-1',
      session_id: 'session-1',
      role: 'child',
      content: 'Olá Claude, como você está hoje?',
      moderation_status: 'passed',
      created_at: '2024-01-15T14:30:15Z',
    },
    {
      id: 'msg-2',
      session_id: 'session-1',
      role: 'assistant',
      content: 'Olá! Eu estou muito bem, obrigada por perguntar! Estou animada para conversar com você. Como você está se sentindo hoje?',
      moderation_status: 'passed',
      created_at: '2024-01-15T14:30:25Z',
    },
  ],
};

// Helper functions para usar nos mocks
export const mockDelay = (ms: number = 800): Promise<void> =>
  new Promise(resolve => setTimeout(resolve, ms));

export const mockFailure = (rate: number = 0.1): boolean =>
  Math.random() < rate;