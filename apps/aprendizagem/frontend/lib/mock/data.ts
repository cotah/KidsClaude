// Mock data para desenvolvimento quando NEXT_PUBLIC_USE_MOCKS=true
import type { Child, Lesson, Badge, ChatSession, PromptTemplate, Stage, FinalExam, StagesResponse } from '@/types/api';
import type { Avatar } from '@/types/app';

export const mockAvatars: Avatar[] = [
  {
    id: 'cat',
    name: 'Gatinho',
    imageUrl: '/avatars/cat.svg',
    suitable_for: ['6-8', '9-10', '11-12'],
  },
  {
    id: 'dog',
    name: 'Cachorro',
    imageUrl: '/avatars/dog.svg',
    suitable_for: ['6-8', '9-10', '11-12'],
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
    suitable_for: ['9-10', '11-12', '12+'],
  },
  {
    id: 'dragon',
    name: 'Dragão',
    imageUrl: '/avatars/dragon.svg',
    suitable_for: ['11-12', '12+'],
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

// Mock stages conforme spec curriculum redesign seção 2
export const mockStages: Stage[] = [
  {
    stage: 1,
    name: 'Discovery',
    description: 'Vamos descobrir o que é IA',
    age_band_label: '6-8 anos',
    difficulty: 'easy',
    is_unlocked: true,
    lessons_total: 4,
    lessons_completed: 2,
    is_completed: false,
  },
  {
    stage: 2,
    name: 'Exploration',
    description: 'Entendendo como prompts funcionam',
    age_band_label: '9-10 anos',
    difficulty: 'medium',
    is_unlocked: false,
    lessons_total: 4,
    lessons_completed: 0,
    is_completed: false,
  },
  {
    stage: 3,
    name: 'Creation',
    description: 'Criando coisas incríveis com IA',
    age_band_label: '11-12 anos',
    difficulty: 'hard',
    is_unlocked: false,
    lessons_total: 4,
    lessons_completed: 0,
    is_completed: false,
  },
  {
    stage: 4,
    name: 'Prompt Engineering',
    description: 'Técnicas avançadas de prompts',
    age_band_label: '12+ anos',
    difficulty: 'advanced',
    is_unlocked: false,
    lessons_total: 4,
    lessons_completed: 0,
    is_completed: false,
  },
];

export const mockFinalExam: FinalExam = {
  lesson_id: 'lesson-final-exam',
  is_unlocked: false,
  is_completed: false,
  label: 'Projeto Final',
  claude_model: 'claude-sonnet-4-6',
};

export const mockStagesResponse: StagesResponse = {
  stages: mockStages,
  final_exam: mockFinalExam,
};

// Mock lessons conforme spec curriculum redesign seção 2
export const mockLessons: Lesson[] = [
  // Stage 1 - Discovery
  {
    id: 'lesson-1-1',
    slug: 'discovery-o-que-e-ia',
    title: 'O que é Inteligência Artificial?',
    description: 'Vamos descobrir o que é IA com exemplos do dia a dia.',
    age_band: '6-8',
    stage: 1,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 1,
    content_blocks: [
      {
        type: 'text',
        content: 'Você sabia que existem programas de computador que conseguem conversar com a gente, contar histórias e responder perguntas? Eles se chamam Inteligência Artificial, ou IA pra simplificar.',
      },
      {
        type: 'image',
        content: '/placeholder-robot-friend.png',
        metadata: { alt: 'Robô amigável acenando' },
      },
      {
        type: 'text',
        content: 'A IA aprende lendo muitos livros, sites e histórias. Por isso ela sabe muita coisa! Mas ela não é mágica, e não é uma pessoa. É como uma calculadora superinteligente.',
      },
    ],
    prerequisites: [],
    xp_reward: 50,
    is_locked: false,
  },
  {
    id: 'lesson-1-2',
    slug: 'discovery-falando-com-claude',
    title: 'Como falar com o Claude',
    description: 'Aprenda a fazer perguntas tocando em botões.',
    age_band: '6-8',
    stage: 1,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 2,
    content_blocks: [
      {
        type: 'text',
        content: 'O Claude é uma IA que adora conversar! Pra falar com ele, você escreve uma pergunta ou um pedido. A gente chama isso de prompt.',
      },
      {
        type: 'image',
        content: '/placeholder-prompt-buttons.png',
        metadata: { alt: 'Botões coloridos com perguntas prontas' },
      },
    ],
    prerequisites: [],
    xp_reward: 50,
    is_locked: false,
  },
  {
    id: 'lesson-1-3',
    slug: 'discovery-regras-de-seguranca',
    title: 'Regras de segurança com IA',
    description: 'Coisas importantes pra lembrar quando você conversa com uma IA.',
    age_band: '6-8',
    stage: 1,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 3,
    content_blocks: [
      {
        type: 'text',
        content: 'Conversar com IA é divertido, mas tem 3 regrinhas importantes que toda criança precisa saber.',
      },
    ],
    prerequisites: [],
    xp_reward: 50,
    is_locked: true,
  },
  {
    id: 'lesson-1-4',
    slug: 'discovery-primeira-conversa',
    title: 'Sua primeira conversa de verdade',
    description: 'Vamos colocar tudo em prática e conversar com o Claude!',
    age_band: '6-8',
    stage: 1,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 4,
    content_blocks: [
      {
        type: 'text',
        content: 'Agora você já sabe o que é IA, sabe como falar com o Claude e sabe as regras de segurança. Bora conversar de verdade!',
      },
    ],
    prerequisites: [],
    xp_reward: 50,
    is_locked: true,
  },
  // Stage 2 - Exploration
  {
    id: 'lesson-2-1',
    slug: 'exploration-como-prompts-funcionam',
    title: 'Como prompts funcionam',
    description: 'Por que algumas perguntas dão respostas melhores que outras.',
    age_band: '9-10',
    stage: 2,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 1,
    content_blocks: [
      {
        type: 'text',
        content: 'Um prompt é como uma instrução que você dá pra IA. Quanto mais clara a instrução, melhor a resposta.',
      },
    ],
    prerequisites: [],
    xp_reward: 70,
    is_locked: true,
  },
  {
    id: 'lesson-2-2',
    slug: 'exploration-respostas-melhores',
    title: 'Conseguindo respostas melhores',
    description: 'Três truques pra fazer a IA te entender melhor.',
    age_band: '9-10',
    stage: 2,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 2,
    content_blocks: [
      {
        type: 'text',
        content: 'Truque 1: Diga pra quem é a resposta. Por exemplo, "explica pra uma criança de 10 anos" deixa a IA usar palavras mais simples.',
      },
    ],
    prerequisites: [],
    xp_reward: 70,
    is_locked: true,
  },
  {
    id: 'lesson-2-3',
    slug: 'exploration-exemplo-com-api-real',
    title: 'Um exemplo de verdade: pegando dados de Pokemon',
    description: 'Vamos ver como programas pegam informação da internet, usando uma API real de Pokemon.',
    age_band: '9-10',
    stage: 2,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 3,
    content_blocks: [
      {
        type: 'text',
        content: 'Sabe quando você abre um app e ele mostra a previsão do tempo? O app pegou esses dados de algum lugar na internet. Esse "algum lugar" chama API.',
      },
    ],
    prerequisites: [],
    xp_reward: 70,
    is_locked: true,
  },
  {
    id: 'lesson-2-4',
    slug: 'exploration-o-que-e-mcp',
    title: 'O que é MCP (Model Context Protocol)',
    description: 'Como a IA consegue se conectar com outros programas pra te ajudar mais.',
    age_band: '9-10',
    stage: 2,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 4,
    content_blocks: [
      {
        type: 'text',
        content: 'Imagina se a IA pudesse ver seu calendário, suas notas, ou pegar dados de um site, sem você precisar copiar e colar?',
      },
    ],
    prerequisites: [],
    xp_reward: 70,
    is_locked: true,
  },
  // Stage 3 - Creation (resumido para o mock)
  {
    id: 'lesson-3-1',
    slug: 'creation-construindo-com-claude',
    title: 'Construindo algo com o Claude',
    description: 'Como pedir ajuda pra criar algo do zero.',
    age_band: '11-12',
    stage: 3,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 1,
    content_blocks: [
      {
        type: 'text',
        content: 'Até agora você conversou e aprendeu. Agora você vai criar! O Claude é ótimo parceiro pra construir coisas: textos, planos, ideias, até jogos simples.',
      },
    ],
    prerequisites: [],
    xp_reward: 100,
    is_locked: true,
  },
  {
    id: 'lesson-3-2',
    slug: 'creation-encadeando-prompts',
    title: 'Encadeando prompts',
    description: 'Use várias perguntas em sequência pra chegar mais longe.',
    age_band: '11-12',
    stage: 3,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 2,
    content_blocks: [
      {
        type: 'text',
        content: 'Encadear prompts é usar uma resposta pra alimentar a próxima pergunta. É como construir uma escada degrau por degrau.',
      },
    ],
    prerequisites: [],
    xp_reward: 100,
    is_locked: true,
  },
  {
    id: 'lesson-3-3',
    slug: 'creation-ideia-de-chatbot',
    title: 'Criando a ideia de um chatbot simples',
    description: 'Vamos planejar um chatbot que ajuda numa tarefa do dia a dia.',
    age_band: '11-12',
    stage: 3,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 3,
    content_blocks: [
      {
        type: 'text',
        content: 'Um chatbot é um programa que conversa por mensagens. Pode ser pra ajudar a estudar, lembrar tarefas, ou até sugerir filmes.',
      },
    ],
    prerequisites: [],
    xp_reward: 100,
    is_locked: true,
  },
  {
    id: 'lesson-3-4',
    slug: 'creation-resolvendo-problema-real',
    title: 'Usando o Claude pra resolver um problema real',
    description: 'Pega um problema do seu dia e ataca com a IA.',
    age_band: '11-12',
    stage: 3,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 4,
    content_blocks: [
      {
        type: 'text',
        content: 'O Claude pode te ajudar com problemas reais: organizar a mochila pra prova, planejar uma festa, escrever um agradecimento, achar um erro num texto.',
      },
    ],
    prerequisites: [],
    xp_reward: 100,
    is_locked: true,
  },
  // Stage 4 - Prompt Engineering (resumido para o mock)
  {
    id: 'lesson-4-1',
    slug: 'prompt-eng-roles-e-personas',
    title: 'Roles e Personas',
    description: 'Como dar uma "persona" pra IA muda completamente a resposta.',
    age_band: '12+',
    stage: 4,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 1,
    content_blocks: [
      {
        type: 'text',
        content: 'Quando você começa um prompt com "Você é um professor de história animado", a IA passa a responder no estilo daquela persona. Isso se chama dar uma role.',
      },
    ],
    prerequisites: [],
    xp_reward: 150,
    is_locked: true,
  },
  {
    id: 'lesson-4-2',
    slug: 'prompt-eng-few-shot',
    title: 'Few-shot examples',
    description: 'Mostrar exemplos do que você quer é quase mágica.',
    age_band: '12+',
    stage: 4,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 2,
    content_blocks: [
      {
        type: 'text',
        content: 'Few-shot é dar pra IA alguns exemplos do tipo de resposta que você quer, antes de pedir o resultado. É como mostrar o gabarito antes da prova.',
      },
    ],
    prerequisites: [],
    xp_reward: 150,
    is_locked: true,
  },
  {
    id: 'lesson-4-3',
    slug: 'prompt-eng-chain-of-thought',
    title: 'Chain of thought',
    description: 'Pedir pra IA pensar passo a passo melhora a precisão.',
    age_band: '12+',
    stage: 4,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 3,
    content_blocks: [
      {
        type: 'text',
        content: 'Chain of thought é pedir pra IA pensar passo a passo antes de responder. É como mostrar o cálculo na prova de matemática.',
      },
    ],
    prerequisites: [],
    xp_reward: 150,
    is_locked: true,
  },
  {
    id: 'lesson-4-4',
    slug: 'prompt-eng-system-prompts',
    title: 'System prompts',
    description: 'A instrução mestra que controla todo o comportamento da IA.',
    age_band: '12+',
    stage: 4,
    is_final_exam: false,
    claude_model: 'claude-haiku-4-5-20251001',
    order_index: 4,
    content_blocks: [
      {
        type: 'text',
        content: 'O system prompt é tipo o manual da IA. Ele define o papel, as regras, o tom, e o que ela pode ou não pode fazer. É configurado uma vez e vale pra conversa toda.',
      },
    ],
    prerequisites: [],
    xp_reward: 150,
    is_locked: true,
  },
  // Final Exam
  {
    id: 'lesson-final-exam',
    slug: 'final-exam-project-capstone',
    title: 'Projeto Final: planeje seu app dos sonhos',
    description: 'Conte sua ideia de app pro Claude e construa o plano juntos, em 5 passos.',
    age_band: '12+',
    stage: 5,
    is_final_exam: true,
    claude_model: 'claude-sonnet-4-6',
    order_index: 1,
    content_blocks: [
      {
        type: 'text',
        content: 'Você chegou ao fim do curso! Está na hora de provar tudo que você aprendeu construindo o plano de um app dos seus sonhos, junto com o Claude.',
      },
      {
        type: 'text',
        content: 'Aqui o Claude vai conversar diferente: ele vai te fazer perguntas em vez de te dar respostas prontas. Vai ser você no comando da ideia.',
      },
    ],
    prerequisites: [],
    xp_reward: 500,
    is_locked: true,
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
    lesson_id: 'lesson-1-1',
    label: 'Diga oi para o Claude!',
    template: 'Olá Claude, como você está hoje?',
    slots: [],
    age_band: '6-8',
    order_index: 1,
  },
  {
    id: 'prompt-2',
    lesson_id: 'lesson-2-1',
    label: 'Peça uma história',
    template: 'Conte uma história sobre {{animal}}',
    slots: [
      {
        name: 'animal',
        max_length: 20,
        allowed_chars: '^[A-Za-zÀ-ÿ ]+$',
      },
    ],
    age_band: '9-10',
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