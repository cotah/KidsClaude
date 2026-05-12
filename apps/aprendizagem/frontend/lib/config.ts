// Configuração centralizada da aplicação
export const config = {
  api: {
    baseUrl: process.env.NEXT_PUBLIC_API_BASE_URL || 'http://localhost:8000/v1',
    timeout: 30000,
  },
  app: {
    url: process.env.NEXT_PUBLIC_APP_URL || 'http://localhost:3000',
    name: 'Aprendizagem',
    version: '1.0.0',
  },
  supabase: {
    url: process.env.NEXT_PUBLIC_SUPABASE_URL!,
    anonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
  },
  features: {
    useMocks: process.env.NEXT_PUBLIC_USE_MOCKS === 'true',
    debug: process.env.NEXT_PUBLIC_DEBUG === 'true',
    tts: typeof window !== 'undefined' && 'speechSynthesis' in window,
  },
  auth: {
    parentCookieName: 'parent-session',
    childCookieName: 'child-session',
    redirectAfterLogin: '/dashboard',
    redirectAfterChildLogin: '/play',
    redirectAfterLogout: '/',
  },
  limits: {
    childNameMaxLength: 30,
    pinLength: 4,
    maxChildrenPerParent: 5,
    defaultDailyLimitMinutes: 30,
    minDailyLimitMinutes: 5,
    maxDailyLimitMinutes: 180,
    heartbeatIntervalSeconds: 60,
    sessionTimeoutMinutes: 10,
  },
  ui: {
    minTouchTargetSize: 56, // pixels
    minFontSizeKids: 18, // pixels
    animationDuration: 300,
    toastDefaultDuration: 5000,
  },
  gamification: {
    xpPerLevel: (level: number) => 100 * level * (level + 1) / 2,
    levelNames: [
      'Curioso',
      'Explorador',
      'Inventor',
      'Pesquisador',
      'Mestre dos Prompts',
      'Aprendiz Maker',
      'Construtor',
      'Cientista',
      'Sábio',
      'Lendário',
    ],
  },
  tts: {
    lang: 'pt-BR',
    rate: 0.9,
    pitch: 1.1,
    volume: 0.8,
  },
} as const;

// Função auxiliar para verificar se estamos no cliente
export const isClient = typeof window !== 'undefined';

// Função auxiliar para verificar ambiente de desenvolvimento
export const isDevelopment = process.env.NODE_ENV === 'development';

// Função auxiliar para logs debug
export const debugLog = (...args: any[]) => {
  if (config.features.debug && isDevelopment) {
    console.log('[DEBUG]', ...args);
  }
};