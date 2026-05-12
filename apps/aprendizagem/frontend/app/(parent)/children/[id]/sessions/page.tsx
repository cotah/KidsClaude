'use client';

import { useParams } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import { ArrowLeft, MessageSquare } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { childrenApi } from '@/lib/api/children';
import { cn } from '@/lib/utils';
import type { Route } from 'next';

const SAFETY_STYLE: Record<string, string> = {
  green: 'bg-mint-100 text-mint-800',
  yellow: 'bg-sunny-100 text-sunny-800',
  red: 'bg-sunset-100 text-sunset-800',
};

const SAFETY_LABEL: Record<string, string> = {
  green: 'Sem avisos',
  yellow: 'Atencao',
  red: 'Bloqueada',
};

export default function ChildSessionsPage() {
  const params = useParams<{ id: string }>();
  const childId = params.id;

  const { data: sessions, isLoading } = useQuery({
    queryKey: ['child-sessions', childId],
    queryFn: () => childrenApi.getSessions(childId, { limit: 50 }),
    enabled: !!childId,
  });

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <div className="flex items-center justify-between">
        <Link href={`/children/${childId}` as Route}>
          <Button variant="ghost" size="sm">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Voltar para o filho
          </Button>
        </Link>
      </div>

      <div>
        <h1 className="text-2xl font-bold text-gray-900">Conversas</h1>
        <p className="text-gray-600">
          Historico de sessoes de chat. Toque em uma sessao para ver a transcricao
          completa.
        </p>
      </div>

      {isLoading ? (
        <div className="space-y-3">
          {Array.from({ length: 4 }).map((_, i) => (
            <div key={i} className="h-20 animate-pulse rounded-xl bg-gray-200" />
          ))}
        </div>
      ) : !sessions || sessions.length === 0 ? (
        <Card className="p-8 text-center">
          <MessageSquare className="mx-auto mb-3 h-10 w-10 text-gray-400" />
          <p className="text-gray-600">Esta crianca ainda nao iniciou conversas.</p>
        </Card>
      ) : (
        <ul className="space-y-3">
          {sessions.map((session) => {
            const safetyKey = session.safety_status ?? 'green';
            return (
              <li key={session.id}>
                <Link
                  href={`/children/${childId}/sessions/${session.id}` as Route}
                  className="block"
                >
                  <Card className="cursor-pointer p-4 transition-all hover:border-grape-300 hover:shadow-md">
                    <div className="flex items-start justify-between gap-4">
                      <div className="flex-1">
                        <p className="font-semibold text-gray-800">
                          {(session as any).lesson_title ?? `Licao ${session.lesson_id.slice(0, 8)}`}
                        </p>
                        <p className="text-xs text-gray-500">
                          Iniciada em{' '}
                          {new Date(session.started_at).toLocaleString('pt-BR')}
                        </p>
                        {session.summary && (
                          <p className="mt-2 line-clamp-2 text-sm text-gray-700">
                            {session.summary}
                          </p>
                        )}
                      </div>
                      <div className="flex flex-col items-end gap-1">
                        <Badge className={cn('text-xs', SAFETY_STYLE[safetyKey])}>
                          {SAFETY_LABEL[safetyKey] ?? safetyKey}
                        </Badge>
                        <span className="text-xs text-gray-500">
                          {session.message_count} mensagens
                        </span>
                      </div>
                    </div>
                  </Card>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
