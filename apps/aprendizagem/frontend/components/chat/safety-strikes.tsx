import { Shield, ShieldAlert } from 'lucide-react';
import { cn } from '@/lib/utils';

interface SafetyStrikesProps {
  strikes: number;
  max?: number;
}

// Mostra contador de bloqueios de moderacao na sessao atual.
// Sessao termina automaticamente em 3 bloqueios (regra do backend).
export function SafetyStrikes({ strikes, max = 3 }: SafetyStrikesProps) {
  const isAlert = strikes > 0;
  return (
    <div
      className={cn(
        'flex items-center gap-2 rounded-full border px-3 py-1.5 text-sm',
        isAlert
          ? 'border-sunset-300 bg-sunset-50 text-sunset-800'
          : 'border-mint-200 bg-mint-50 text-mint-800'
      )}
      title={`${strikes} de ${max} avisos nesta conversa`}
    >
      {isAlert ? (
        <ShieldAlert className="h-4 w-4" />
      ) : (
        <Shield className="h-4 w-4" />
      )}
      <span aria-live="polite" className="font-medium">
        {strikes}/{max} avisos
      </span>
    </div>
  );
}
