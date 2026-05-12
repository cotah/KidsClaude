import { create } from 'zustand';
import type { LessonPlayerState } from '@/types/app';
import type { Lesson, ChatSession } from '@/types/api';

interface LessonStoreState {
  // Current lesson state
  currentLesson?: Lesson;
  playerState?: LessonPlayerState;

  // Chat session
  currentChatSession?: ChatSession;
  chatMessages: Array<{
    id: string;
    role: 'child' | 'assistant' | 'system';
    content: string;
    timestamp: Date;
  }>;

  // Actions
  setCurrentLesson: (lesson: Lesson) => void;
  setPlayerState: (state: LessonPlayerState) => void;
  nextBlock: () => void;
  prevBlock: () => void;
  completeLesson: () => void;

  // Chat actions
  setChatSession: (session: ChatSession) => void;
  addChatMessage: (message: {
    role: 'child' | 'assistant' | 'system';
    content: string;
  }) => void;
  clearChatMessages: () => void;

  // Reset
  reset: () => void;
}

const useLessonStore = create<LessonStoreState>((set, get) => ({
  // Initial state
  chatMessages: [],

  // Lesson actions
  setCurrentLesson: (lesson) => {
    set({
      currentLesson: lesson,
      playerState: {
        currentBlockIndex: 0,
        completed: false,
        startedAt: new Date(),
      },
    });
  },

  setPlayerState: (state) => {
    set({ playerState: state });
  },

  nextBlock: () => {
    const { currentLesson, playerState } = get();
    if (!currentLesson || !playerState) return;

    const nextIndex = playerState.currentBlockIndex + 1;
    if (nextIndex < currentLesson.content_blocks.length) {
      set({
        playerState: {
          ...playerState,
          currentBlockIndex: nextIndex,
        },
      });
    }
  },

  prevBlock: () => {
    const { playerState } = get();
    if (!playerState) return;

    const prevIndex = Math.max(0, playerState.currentBlockIndex - 1);
    set({
      playerState: {
        ...playerState,
        currentBlockIndex: prevIndex,
      },
    });
  },

  completeLesson: () => {
    const { playerState } = get();
    if (!playerState) return;

    set({
      playerState: {
        ...playerState,
        completed: true,
      },
    });
  },

  // Chat actions
  setChatSession: (session) => {
    set({ currentChatSession: session });
  },

  addChatMessage: (message) => {
    const id = Math.random().toString(36).substring(2);
    const chatMessage = {
      ...message,
      id,
      timestamp: new Date(),
    };

    set((state) => ({
      chatMessages: [...state.chatMessages, chatMessage],
    }));
  },

  clearChatMessages: () => {
    set({ chatMessages: [] });
  },

  // Reset all state
  reset: () => {
    set({
      currentLesson: undefined,
      playerState: undefined,
      currentChatSession: undefined,
      chatMessages: [],
    });
  },
}));

export default useLessonStore;