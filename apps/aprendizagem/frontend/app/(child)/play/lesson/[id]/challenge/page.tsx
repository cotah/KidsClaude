'use client';

import { useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import type { Route } from 'next';
import { ArrowRight, CheckCircle, XCircle, RotateCw } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { MascotBubble } from '@/components/ui/mascot-bubble';
import { useToast } from '@/components/ui/toast';
import { lessonsApi, challengesApi } from '@/lib/api/lessons';
import { getApiErrorMessage } from '@/lib/api/client';
import type { Challenge, ChallengeAttemptResponse } from '@/types/api';

/**
 * Player de desafio - tipo multiple_choice (MVP).
 * Apresenta pergunta, opcoes, valida via POST /v1/challenges/{id}/attempt.
 */
export default function ChallengePage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { toast } = useToast();
  const lessonId = params.id;

  const [selectedIndex, setSelectedIndex] = useState<number | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [result, setResult] = useState<ChallengeAttemptResponse | null>(null);

  const { data: lesson, isLoading } = useQuery({
    queryKey: ['lesson-challenge', lessonId],
    queryFn: () => lessonsApi.get(lessonId),
    enabled: !!lessonId,
  });

  const challenge: Challenge | undefined = lesson?.challenges?.[0];
  const question = challenge?.question as
    | { question: string; options: string[] }
    | undefined;

  const handleSubmit = async () => {
    if (!challenge || selectedIndex === null) return;
    setSubmitting(true);
    try {
      const res = await challengesApi.attempt(challenge.id, {
        answer: { answer: selectedIndex },
      });
      setResult(res);
    } catch (err) {
      toast({
        type: 'error',
        title: 'Nao consegui enviar sua resposta',
        description: getApiErrorMessage(err),
      });
    } finally {
      setSubmitting(false);
    }
  };

  const handleTryAgain = () => {
    setSelectedIndex(null);
    setResult(null);
  };

  if (isLoading || !lesson) {
    return (
      <div className="mx-auto max-w-3xl p-6">
        <Card className="animate-pulse p-8">
          <div className="mb-4 h-4 w-64 rounded bg-gray-200" />
          <div className="h-4 w-48 rounded bg-gray-200" />
        </Card>
      </div>
    );
  }

  if (!challenge || !question) {
    return (
      <div className="mx-auto max-w-3xl p-6">
        <Card className="p-8 text-center">
          <h1 className="mb-4 text-xl font-bold">Esta licao nao tem desafio</h1>
          <Button
            variant="ocean"
            onClick={() => router.push(`/play/lesson/${lessonId}/chat` as Route)}
          >
            Ir para o chat <ArrowRight className="ml-2 h-4 w-4" />
          </Button>
        </Card>
      </div>
    );
  }

  const correctIndex = (result?.correct_answer as { answer?: number } | undefined)?.answer;

  return (
    <div className="mx-auto max-w-3xl space-y-6 p-4">
      <Card className="p-6">
        <p className="mb-1 text-sm font-medium text-grape-600">{lesson.title}</p>
        <h1 className="text-2xl font-bold text-gray-900">Desafio rapido</h1>
      </Card>

      <Card className="space-y-6 p-8">
        <h2 className="text-xl font-semibold text-gray-800">{question.question}</h2>

        <div className="grid grid-cols-1 gap-3">
          {question.options.map((option, index) => {
            const isSelected = selectedIndex === index;
            const isCorrect = result && correctIndex === index;
            const isWrongPicked =
              result && !result.is_correct && selectedIndex === index;

            return (
              <button
                key={index}
                type="button"
                onClick={() => !result && setSelectedIndex(index)}
                disabled={!!result}
                className={[
                  'flex items-center justify-between rounded-xl border-2 px-5 py-4 text-left text-base font-medium transition-all',
                  result
                    ? isCorrect
                      ? 'border-mint-400 bg-mint-50 text-mint-900'
                      : isWrongPicked
                      ? 'border-sunset-400 bg-sunset-50 text-sunset-900'
                      : 'border-gray-200 bg-white text-gray-500'
                    : isSelected
                    ? 'border-ocean-500 bg-ocean-50 text-ocean-900'
                    : 'border-gray-200 bg-white text-gray-700 hover:border-ocean-300 hover:bg-ocean-50',
                ].join(' ')}
              >
                <span>{option}</span>
                {result && isCorrect && <CheckCircle className="h-5 w-5" />}
                {result && isWrongPicked && <XCircle className="h-5 w-5" />}
              </button>
            );
          })}
        </div>

        {result && (
          <div className="space-y-3">
            {result.is_correct ? (
              <MascotBubble variant="excited">
                Mandou bem! Voce ganhou {result.xp_earned} XP. Vamos para a conversa
                com a Claude?
              </MascotBubble>
            ) : (
              <MascotBubble variant="warning">
                Quase! A resposta certa era a opcao destacada em verde. Pode tentar
                de novo ou seguir adiante.
              </MascotBubble>
            )}
          </div>
        )}

        <div className="flex flex-col-reverse gap-3 sm:flex-row sm:justify-between">
          <Button
            variant="outline"
            onClick={() => router.push(`/play/lesson/${lessonId}` as Route)}
            disabled={submitting}
          >
            Voltar para a licao
          </Button>

          {!result ? (
            <Button
              variant="ocean"
              size="lg"
              onClick={handleSubmit}
              disabled={selectedIndex === null || submitting}
            >
              {submitting ? 'Enviando...' : 'Enviar resposta'}
            </Button>
          ) : (
            <div className="flex gap-2">
              {!result.is_correct && (
                <Button variant="outline" onClick={handleTryAgain}>
                  <RotateCw className="mr-1 h-4 w-4" /> Tentar de novo
                </Button>
              )}
              <Button
                variant="sunny"
                size="lg"
                onClick={() => router.push(`/play/lesson/${lessonId}/chat` as Route)}
              >
                Ir para o chat <ArrowRight className="ml-2 h-4 w-4" />
              </Button>
            </div>
          )}
        </div>
      </Card>
    </div>
  );
}
