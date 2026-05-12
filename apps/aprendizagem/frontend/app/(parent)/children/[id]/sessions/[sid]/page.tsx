'use client';

import { useParams } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import Link from 'next/link';
import { ArrowLeft, Shield, ShieldAlert, ShieldOff } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { chatApi } from '@/lib/api/chat';
import { cn } from '@/lib/utils';
import type { Route } from 'next';

const SAFETY_META: Record<
  string,
  { label: string; icon: typeof Shield; tone: string }
> = {
  green: { label: 'Conversa segura', icon: Shield, tone: 'text-mint-700 bg-mint-50 border-mint-200' },
  yellow: { label: 'Com avisos', icon: ShieldAlert, tone: 'text-sunny-800 bg-sunny-50 border-sunny-200' },
  red: { label: 'Encerrada por seguranca', icon: ShieldOff, tone: 'text-sunset-800 bg-sunset-50 border-sunset-300' },
};

/**
 * Transcricao completa de uma sessao de chat. Mostra mensagens da crianca e
 * da Claude com marcacao visual quando alguma foi bloqueada pela moderacao.
 */
export default function SessionTranscriptPage() {
  const params = useParams<{ id: string; sid: string }>();
  const childId = params.id;
  const sessionId = params.sid;

  const { data, isLoading } = useQuery({
    queryKey: ['chat-session', sessionId],
    queryFn: () => chatApi.getSession(sessionId),
    enabled: !!sessionId,
  });

  if (isLoading || !data) {
    return (
      <div className="mx-auto max-w-3xl">
        <Card className="animate-pulse p-8">
          <div className="mb-2 h-4 w-64 rounded bg-gray-200" />
          <div className="h-4 w-40 rounded bg-gray-200" />
        </Card>
      </div>
    );
  }

  // Backend retorna { session, messages } - resiliente caso o shape mude.
  const session = (data as any).session ?? data;
  const messages = (data as any).messages ?? session.messages ?? [];
  const safety = SAFETY_META[session.safety_status] ?? SAFETY_META.green;
  const SafetyIcon = safety.icon;

  return (
    <div className="mx-auto max-w-3xl space-y-6">
      <div className="flex items-center justify-between">
        <Link href={`/children/${childId}/sessions` as Route}>
          <Button variant="ghost" size="sm">
            <ArrowLeft className="mr-2 h-4 w-4" />
            Todas as conversas
          </Button>
        </Link>
      </div>

      <Card className="space-y-3 p-5">
        <h1 className="text-2xl font-bold text-gray-900">Transcricao</h1>
        <p className="text-sm text-gray-600">
          Iniciada em {new Date(session.started_at).toLocaleString('pt-BR')}
          {session.ended_at &&
            ` · encerrada em ${new Date(session.ended_at).toLocaleString('pt-BR')}`}
        </p>
        <div
          className={cn(
            'flex items-center gap-2 rounded-lg border px-3 py-2 text-sm font-medium',
            safety.tone
          )}
        >
          <SafetyIcon className="h-4 w-4" />
          {safety.label}
        </div>
        {session.summary && (
          <div className="rounded-lg border border-grape-200 bg-grape-50 p-3 text-sm">
            <p className="mb-1 font-semibold text-grape-700">Resumo da conversa</p>
            <p className="text-grape-900">{session.summary}</p>
          </div>
        )}
      </Card>

      <Card className="space-y-4 p-5">
        <h2 className="text-base font-semibold text-gray-800">Mensagens</h2>
        {messages.length === 0 ? (
          <p className="text-sm text-gray-500">Esta sessao nao teve mensagens.</p>
        ) : (
          <ol className="space-y-4">
            {messages.map((msg: any) => {
              const blocked = msg.moderation_status === 'blocked';
              const isChild = msg.role === 'child';
              return (
                <li
                  key={msg.id}
                  className={cn(
                    'flex',
                    isChild ? 'justify-end' : 'justify-start'
                  )}
                >
                  <div
                    className={cn(
                      'max-w-[80%] space-y-1 rounded-2xl px-4 py-3 text-sm shadow-sm',
                      isChild
                        ? blocked
                          ? 'border border-sunset-300 bg-sunset-50 text-sunset-900'
                          : 'bg-ocean-500 text-white'
                        : blocked
                        ? 'border border-sunset-300 bg-sunset-50 text-sunset-900'
                        : 'border border-grape-200 bg-white text-gray-800'
                    )}
                  >
                    <p className="text-xs uppercase tracking-wide opacity-70">
                      {isChild ? 'Crianca' : 'Claude'}
                      {blocked && ' · bloqueado'}
                    </p>
                    <p className="whitespace-pre-wrap">{msg.content}</p>
                    {blocked && msg.moderation_reason && (
                      <p className="text-xs italic opacity-80">
                        Motivo: {msg.moderation_reason}
                      </p>
                    )}
                    <p className="text-[10px] opacity-60">
                      {new Date(msg.created_at).toLocaleTimeString('pt-BR')}
                    </p>
                  </div>
                </li>
              );
            })}
          </ol>
        )}
      </Card>
    </div>
  );
}
