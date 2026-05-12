import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { AppState, ToastMessage, XPGain } from '@/types/app';
import type { Child } from '@/types/api';

interface AppStoreState extends AppState {
  // Toast notifications
  toasts: ToastMessage[];
  addToast: (toast: Omit<ToastMessage, 'id'>) => void;
  removeToast: (id: string) => void;

  // Session management
  setCurrentChild: (child: Child | undefined) => void;
  setSession: (session: AppState['session']) => void;
  clearSession: () => void;

  // Usage tracking
  updateUsage: (usage: AppState['usage']) => void;

  // XP animations
  xpGains: XPGain[];
  addXPGain: (gain: Omit<XPGain, 'timestamp'>) => void;
  clearXPGains: () => void;
}

const useAppStore = create<AppStoreState>()(
  persist(
    (set, get) => ({
      // Initial state
      toasts: [],
      xpGains: [],

      // Toast actions
      addToast: (toast) => {
        const id = Math.random().toString(36).substring(2);
        const newToast = { ...toast, id };

        set((state) => ({
          toasts: [...state.toasts, newToast],
        }));

        // Auto-remove toast after duration
        const duration = toast.duration || 5000;
        setTimeout(() => {
          set((state) => ({
            toasts: state.toasts.filter((t) => t.id !== id),
          }));
        }, duration);
      },

      removeToast: (id) => {
        set((state) => ({
          toasts: state.toasts.filter((t) => t.id !== id),
        }));
      },

      // Session actions
      setCurrentChild: (child) => {
        set({ currentChild: child });
      },

      setSession: (session) => {
        set({ session });
      },

      clearSession: () => {
        set({
          session: undefined,
          currentChild: undefined,
          usage: undefined,
        });
      },

      // Usage actions
      updateUsage: (usage) => {
        set({ usage });
      },

      // XP actions
      addXPGain: (gain) => {
        const xpGain: XPGain = {
          ...gain,
          timestamp: new Date(),
        };

        set((state) => ({
          xpGains: [...state.xpGains, xpGain],
        }));

        // Auto-remove after animation
        setTimeout(() => {
          set((state) => ({
            xpGains: state.xpGains.filter((xp) => xp.timestamp !== xpGain.timestamp),
          }));
        }, 3000);
      },

      clearXPGains: () => {
        set({ xpGains: [] });
      },
    }),
    {
      name: 'aprendizagem-app-store',
      partialize: (state) => ({
        // Persistir apenas dados importantes
        currentChild: state.currentChild,
        session: state.session,
        usage: state.usage,
      }),
    }
  )
);

export default useAppStore;