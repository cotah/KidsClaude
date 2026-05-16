'use client';

import { useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { usageApi } from '@/lib/api/dashboard';
import { config } from '@/lib/config';

/**
 * Tick periodico que reporta tempo de uso da crianca ao backend.
 * Monta no layout das rotas /play/* - desmontagem natural ao sair de play.
 *
 * Backend acumula em daily_usage (UPSERT por child_id+data) e devolve
 * blocked=true quando o limite diario e' atingido; nesse caso redireciona
 * para /play/blocked e para de bater (evita loop de heartbeats sobre uma
 * crianca ja bloqueada).
 *
 * Pausa quando a aba esta hidden (document.visibilityState) - sem isso,
 * uma aba esquecida aberta inflaria minutos_used sem atividade real.
 *
 * Erros sao engolidos: falha de rede ou 5xx nao deve crashar a UI da
 * crianca. O proximo tick tenta de novo.
 */
export function useHeartbeat(): void {
  const router = useRouter();
  const blockedRef = useRef(false);

  useEffect(() => {
    const intervalMs = config.limits.heartbeatIntervalSeconds * 1000;

    const tick = async () => {
      if (blockedRef.current) return;
      if (typeof document !== 'undefined' && document.visibilityState === 'hidden') {
        return;
      }

      try {
        const response = await usageApi.sendHeartbeat({
          seconds: config.limits.heartbeatIntervalSeconds,
        });
        if (response.blocked) {
          blockedRef.current = true;
          router.push('/play/blocked');
        }
      } catch {
        // Heartbeat e' best-effort - nao crasha a UI por causa disso.
      }
    };

    const handle = window.setInterval(tick, intervalMs);
    return () => window.clearInterval(handle);
  }, [router]);
}
