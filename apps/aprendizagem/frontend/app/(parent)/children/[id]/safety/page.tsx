'use client';

import { useParams } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import { ArrowLeft, Shield, ShieldAlert, ShieldOff } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { childrenApi } from '@/lib/api/children';
import { cn } from '@/lib/utils';
import type { Route } from 'next';

const KIND_META: Record<
  string,
  { label: string; icon: typeof Shield; tone: string }
> = {
  input_blocked: {
    label: 'Mensagem da crianca bloqueada',
    icon: ShieldAlert,
    tone: 'border-sunny-300 bg-sunny-50',
  },
  output_blocked: {
    label: 'Resposta da Claude bloqueada',
    icon: ShieldAlert,
    tone: 'border-sunny-300 bg-sunny-50',
  },
  session_terminated: {
    label: 'Sessao encerrada por seguranca',
    icon: ShieldOff,
    tone: 'border-sunset-300 bg-sunset-50',
  },
};

/**
 * Linha do tempo de eventos de seguranca de uma crianca.
 * Mostra bloqueios da moderacao input/output e encerramentos automaticos.
 */
export default function ChildSafetyPage() {
  const params = useParams<{ id: string }>();
  const childId = params.id;

  const { data: events, isLoading } = useQuery({
    queryKey: ['child-safety', childId],
    queryFn: () => childrenApi.getSafetyEvents(childId),
    enabled: !!childId,
  });

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <Link href={`/children/${childId}` as Route}>
        <Button variant="ghost" size="sm">
          <ArrowLeft className="mr-2 h-4 w-4" />
          Voltar para o filho
        </Button>
      </Link>

      <div>
        <h1 className="text-2xl font-bold text-gray-900">Eventos de seguranca</h1>
        <p className="text-gray-600">
          Sempre que a moderacao bloqueia algo ou uma sessao termina por seguranca,
          fica registrado aqui.
        </p>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="h-20 animate-pulse rounded-xl bg-gray-200" />
          ))}
        </div>
      ) : !events || events.length === 0 ? (
        <Card className="p-8 text-center">
          <Shield className="mx-auto mb-3 h-10 w-10 text-mint-500" />
          <p className="text-base font-medium text-gray-700">Tudo tranquilo!</p>
          <p className="text-sm text-gray-500">
            Nenhum evento de seguranca foi registrado para esta crianca.
          </p>
        </Card>
      ) : (
        <ol className="space-y-3">
          {events.map((event) => {
            const meta = KIND_META[event.kind] ?? {
              label: event.kind,
              icon: Shield,
              tone: 'border-gray-200 bg-gray-50',
            };
            const Icon = meta.icon;
            const reason = (event.details as { reason?: string } | undefined)?.reason;
            return (
              <li key={event.id}>
                <Card className={cn('p-4', meta.tone)}>
                  <div className="flex items-start gap-3">
                    <Icon className="h-5 w-5 flex-shrink-0 text-gray-700" />
                    <div className="flex-1 space-y-1">
                      <p className="font-semibold text-gray-900">{meta.label}</p>
                      {reason && (
                        <p className="text-sm text-gray-700">{reason}</p>
                      )}
                      <p className="text-xs text-gray-500">
                        {new Date(event.created_at).toLocaleString('pt-BR')}
                      </p>
                      {event.session_id && (
                        <Link
                          href={`/children/${childId}/sessions/${event.session_id}` as Route}
                          className="text-xs font-medium text-ocean-600 hover:underline"
                        >
                          Ver transcricao da sessao
                        </Link>
                      )}
                    </div>
                  </div>
                </Card>
              </li>
            );
          })}
        </ol>
      )}
    </div>
  );
}
