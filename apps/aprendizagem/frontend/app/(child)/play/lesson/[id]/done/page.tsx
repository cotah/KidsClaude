'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import type { Route } from 'next';
import { Sparkles, Trophy, Zap } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Mascot, MascotBubble } from '@/components/ui/mascot-bubble';
import { lessonsApi } from '@/lib/api/lessons';
import { getApiErrorMessage } from '@/lib/api/client';
import type { LessonCompletionResponse } from '@/types/api';

/**
 * Tela de recompensa - chama POST /v1/lessons/{id}/complete e celebra
 * XP ganho, level up e badges desbloqueados.
 */
export default function LessonDonePage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
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
        if (!cancelled) setCompletion(res);
      })
      .catch((err) => {
        if (!cancelled) setError(getApiErrorMessage(err));
      });
    return () => {
      cancelled = true;
    };
  }, [lessonId]);

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
