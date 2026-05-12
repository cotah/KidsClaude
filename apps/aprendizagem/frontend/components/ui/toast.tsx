'use client';

import * as React from 'react';
import { useEffect, useState, useCallback } from 'react';
import { X } from 'lucide-react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';
import useAppStore from '@/lib/store/app-store';

const toastVariants = cva(
  'group pointer-events-auto relative flex w-full items-center justify-between space-x-4 overflow-hidden rounded-md border p-6 pr-8 shadow-lg transition-all',
  {
    variants: {
      variant: {
        default: 'border bg-background text-foreground',
        destructive: 'destructive group border-destructive bg-destructive text-destructive-foreground',
        // Alias para o tipo "error" usado no app-store (mesmo estilo do destructive)
        error: 'destructive group border-destructive bg-destructive text-destructive-foreground',
        success: 'border-mint-200 bg-mint-50 text-mint-800',
        warning: 'border-sunny-200 bg-sunny-50 text-sunny-800',
        info: 'border-ocean-200 bg-ocean-50 text-ocean-800',
      },
    },
    defaultVariants: {
      variant: 'default',
    },
  }
);

interface ToastProps extends React.HTMLAttributes<HTMLDivElement>, VariantProps<typeof toastVariants> {
  title: string;
  description?: string;
  onClose?: () => void;
}

const Toast: React.FC<ToastProps> = ({
  className,
  variant,
  title,
  description,
  onClose,
  ...props
}) => {
  return (
    <div className={cn(toastVariants({ variant }), className)} {...props}>
      <div className="grid gap-1">
        <div className="text-sm font-semibold">{title}</div>
        {description && (
          <div className="text-sm opacity-90">{description}</div>
        )}
      </div>
      {onClose && (
        <button
          className="absolute right-2 top-2 rounded-md p-1 text-foreground/50 opacity-0 transition-opacity hover:text-foreground focus:opacity-100 focus:outline-none focus:ring-2 group-hover:opacity-100"
          onClick={onClose}
        >
          <X className="h-4 w-4" />
          <span className="sr-only">Fechar</span>
        </button>
      )}
    </div>
  );
};

// Toast container component - so renderiza no cliente para evitar problemas
// com o Zustand persist (useSyncExternalStore) durante SSR/prerender.
export const ToastContainer: React.FC = () => {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) return null;

  return <ToastContainerInner />;
};

const ToastContainerInner: React.FC = () => {
  const { toasts, removeToast } = useAppStore();

  if (toasts.length === 0) return null;

  return (
    <div className="fixed bottom-0 right-0 z-50 flex max-h-screen w-full flex-col-reverse p-4 sm:bottom-0 sm:right-0 sm:top-auto sm:flex-col md:max-w-[420px]">
      {toasts.map((toast) => (
        <Toast
          key={toast.id}
          variant={toast.type}
          title={toast.title}
          description={toast.description}
          onClose={() => removeToast(toast.id)}
          className="mb-2"
        />
      ))}
    </div>
  );
};

// Hook para usar toasts facilmente
export const useToast = () => {
  const addToast = useAppStore((state) => state.addToast);

  const toast = useCallback(
    (props: Omit<Parameters<typeof addToast>[0], 'id'>) => {
      addToast(props);
    },
    [addToast]
  );

  return { toast };
};

export { Toast, toastVariants };