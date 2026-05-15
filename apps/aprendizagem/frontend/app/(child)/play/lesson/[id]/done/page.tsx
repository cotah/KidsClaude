'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useQueryClient } from '@tanstack/react-query';
import type { Route } from 'next';
import { Sparkles, Trophy, Zap } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Mascot, MascotBubble } from '@/components/ui/mascot-bubble';
import { lessonsApi } from '@/lib/api/lessons';
import { getApiErrorMessage } from '@/lib/api/client';
import useAppStore from '@/lib/store/app-store';
import type { Child, LessonCompletionResponse } from '@/types/api';

/**
 * Tela de recompensa - chama POST /v1/lessons/{id}/complete e celebra
 * XP ganho, level up e badges desbloqueados.
 */
export default function LessonDonePage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const queryClient = useQueryClient();
  const { currentChild, setCurrentChild } = useAppStore();
  const lessonId = params.id;

  const [completion, setCompletion] = useState<LessonCompletionResponse | null>(null);
  const [error, setError] = useState<string | null>(null);

  // Conclui a licao apenas uma vez no mount.
  useEffect(() => {
    if (!lessonId) return;
    let cancelled = false;
    lessonsApi
      .complete(lessonId)
      .then((res) => {
        if (cancelled) return;
        setCompletion(res);
        // Atualiza currentChild no zustand pra que XPProgress no header e
        // ChildNavbar reflitam o novo XP/level imediatamente. Sem isso,
        // a barra continua mostrando o XP antigo ate a crianca relogar.
        if (currentChild) {
          // Cast pra Child porque o tipo local de AppState.currentChild
          // omite alguns campos que existem no payload real (ex:
          // daily_limit_minutes). O store sempre recebe Child do login.
          setCurrentChild({
            ...(currentChild as Child),
            xp: res.xp_total,
            level: res.level,
          });
        }
        // Invalida caches dependentes pra que stages, listas de licao da
        // stage, progresso e badges reflitam a conclusao sem refresh:
        //  - 'stages' (hub /play e header da stage page)
        //  - 'lessons' (lista da /play/stage/N - filtra por stage)
        //  - 'lesson-progress' (Set de concluidas no LessonListItem)
        //  - 'child-badges' (contagem de badges na ChildNavbar)
        // Usamos queryKey parcial pra atingir todas as variantes.
        queryClient.invalidateQueries({ queryKey: ['stages'] });
        queryClient.invalidateQueries({ queryKey: ['lessons'] });
        queryClient.invalidateQueries({ queryKey: ['lesson-progress'] });
        queryClient.invalidateQueries({ queryKey: ['child-badges'] });
      })
      .catch((err) => {
        if (!cancelled) setError(getApiErrorMessage(err));
      });
    return () => {
      cancelled = true;
    };
    // currentChild/setCurrentChild fora das deps de proposito: a callback
    // roda uma unica vez no mount; ler o currentChild dentro do .then
    // pega a referencia mais recente sem retriggerar o complete.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [lessonId, queryClient]);

  if (error) {
    return (
      <div className="mx-auto max-w-2xl p-6">
        <Card className="space-y-4 p-8 text-center">
          <Mascot size="md" expression="thinking" />
          <p className="text-base text-gray-700">{error}</p>
          <Button variant="outline" onClick={() => router.push('/play' as Route)}>
            Voltar para o inicio
          </Button>
        </Card>
      </div>
    );
  }

  if (!completion) {
    return (
      <div className="mx-auto max-w-2xl p-6">
        <Card className="animate-pulse space-y-3 p-8">
          <div className="mx-auto h-12 w-12 rounded-full bg-gray-200" />
          <div className="mx-auto h-4 w-48 rounded bg-gray-200" />
        </Card>
      </div>
    );
  }

  const { xp_total, level, badges_unlocked } = completion;

  return (
    <div className="mx-auto max-w-2xl space-y-6 p-4">
      <Card className="space-y-6 border-sunny-300 bg-gradient-to-br from-sunny-50 to-mint-50 p-8 text-center">
        <div className="flex justify-center">
          <Mascot size="lg" expression="excited" />
        </div>

        <MascotBubble variant="excited">
          <strong>Parabens!</strong> Voce concluiu mais uma licao!
        </MascotBubble>

        <div className="grid grid-cols-2 gap-4 pt-2">
          <div className="rounded-xl border border-sunny-300 bg-white p-4">
            <Zap className="mx-auto h-8 w-8 text-sunny-500" />
            <p className="mt-2 text-3xl font-extrabold text-sunny-700">{xp_total}</p>
            <p className="text-sm text-gray-600">XP total</p>
          </div>
          <div className="rounded-xl border border-grape-300 bg-white p-4">
            <Trophy className="mx-auto h-8 w-8 text-grape-500" />
            <p className="mt-2 text-3xl font-extrabold text-grape-700">{level}</p>
            <p className="text-sm text-gray-600">Nivel</p>
          </div>
        </div>

        {badges_unlocked.length > 0 && (
          <div className="space-y-3 rounded-xl border-2 border-dashed border-sunset-300 bg-sunset-50 p-4">
            <div className="flex items-center justify-center gap-2 text-sunset-800">
              <Sparkles className="h-5 w-5" />
              <p className="text-base font-bold">Novas conquistas!</p>
            </div>
            <ul className="space-y-2">
              {badges_unlocked.map((badge) => (
                <li
                  key={badge.id}
                  className="flex items-center gap-3 rounded-lg bg-white px-3 py-2 text-left"
                >
                  <span className="text-2xl">{badge.icon || '🏆'}</span>
                  <div>
                    <p className="text-sm font-bold text-gray-800">{badge.name}</p>
                    <p className="text-xs text-gray-600">{badge.description}</p>
                  </div>
                </li>
              ))}
            </ul>
          </div>
        )}

        <div className="flex flex-col-reverse gap-2 pt-2 sm:flex-row sm:justify-center">
          <Button
            variant="outline"
            size="lg"
            onClick={() => router.push('/play/badges' as Route)}
          >
            Ver minhas conquistas
          </Button>
          <Button
            variant="sunny"
            size="lg"
            onClick={() => router.push('/play' as Route)}
          >
            Continuar aprendendo
          </Button>
        </div>
      </Card>
    </div>
  );
}
