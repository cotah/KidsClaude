'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useQuery, useMutation } from '@tanstack/react-query';
import { useTranslations, useLocale } from 'next-intl';
import { Volume2, ArrowRight, ArrowLeft } from 'lucide-react';
import type { Route } from 'next';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Progress } from '@/components/ui/progress';
import { lessonsApi } from '@/lib/api/lessons';

/**
 * Lesson Player - exibe blocos sequenciais da lição
 * Implementa narração via Web Speech API conforme spec
 */
export default function LessonPage() {
  const t = useTranslations('lesson_player');
  const locale = useLocale();
  const params = useParams();
  const router = useRouter();
  const lessonId = params.id as string;

  const [currentBlock, setCurrentBlock] = useState(0);

  // Buscar dados da licao
  const { data: lesson, isLoading } = useQuery({
    queryKey: ['lesson', lessonId],
    queryFn: () => lessonsApi.get(lessonId),
  });

  // Marcar lição como iniciada. Erros tratados:
  //  - 403 LESSON_LOCKED: redireciona pra stage (crianca tentou pular).
  //  - 409 ALREADY_STARTED: SUCESSO silencioso. Crianca esta revisando
  //    licao ja' completa OU re-entrando em progresso - nao e' erro,
  //    page renderiza normal. Sem isso, toast/error UI aparecia ao
  //    tentar "Rever" uma licao concluida.
  //  - Outros: silencioso (page ja' renderiza com dados da useQuery).
  const startLessonMutation = useMutation({
    mutationFn: () => lessonsApi.start(lessonId),
    onError: (error: any) => {
      const status = error?.response?.status;
      const code = error?.apiError?.error?.code;
      if (status === 403 || code === 'LESSON_LOCKED') {
        const stageId = lesson?.stage;
        if (stageId) {
          router.push(`/play/stage/${stageId}` as any);
        } else {
          router.push('/play');
        }
        return;
      }
      // 409 ALREADY_STARTED e qualquer outro: ignora. Page ja' funciona
      // com lesson data carregado via useQuery acima.
    },
  });

  useEffect(() => {
    if (lesson) {
      // Check se a lição está bloqueada no frontend primeiro
      if (lesson.is_locked) {
        const stageId = lesson.stage;
        router.push(`/play/stage/${stageId}` as any);
        return;
      }
      startLessonMutation.mutate();
    }
  }, [lesson]);

  const handleNarration = (text: string) => {
    if ('speechSynthesis' in window) {
      speechSynthesis.cancel();

      const utterance = new SpeechSynthesisUtterance(text);
      utterance.lang = 'pt-BR';
      utterance.rate = 0.9;
      utterance.pitch = 1.1;
      utterance.volume = 0.8;

      speechSynthesis.speak(utterance);
    }
  };

  // Locale-aware: usa versao EN dos campos quando locale='en' E o backend
  // tem a traducao (migration 010). Fallback pra PT em qualquer outro caso
  // (locale=pt OU EN mas licao nao traduzida).
  const useEnglish = locale === 'en';
  const displayTitle = useEnglish && lesson?.title_en ? lesson.title_en : lesson?.title;
  const displayBlocks =
    useEnglish && lesson?.content_blocks_en && lesson.content_blocks_en.length > 0
      ? lesson.content_blocks_en
      : lesson?.content_blocks ?? [];

  const handleNext = () => {
    if (!lesson) return;

    if (currentBlock < displayBlocks.length - 1) {
      setCurrentBlock(currentBlock + 1);
    } else {
      router.push(`/play/lesson/${lessonId}/challenge` as Route);
    }
  };

  const handlePrevious = () => {
    if (currentBlock > 0) {
      setCurrentBlock(currentBlock - 1);
    }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Card className="p-8 animate-pulse">
          <div className="w-64 h-4 bg-gray-200 rounded mb-4" />
          <div className="w-48 h-4 bg-gray-200 rounded" />
        </Card>
      </div>
    );
  }

  if (!lesson) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <Card className="p-8 text-center">
          <h2 className="text-xl font-bold text-gray-900 mb-2">{t('not_found_title')}</h2>
          <Button onClick={() => router.push('/play')}>{t('back_home')}</Button>
        </Card>
      </div>
    );
  }

  const block = displayBlocks[currentBlock];
  const progress = ((currentBlock + 1) / displayBlocks.length) * 100;

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header com progresso */}
      <Card className="p-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{displayTitle}</h1>
            <p className="text-gray-600">
              {t('block_progress', { current: currentBlock + 1, total: displayBlocks.length })}
            </p>
          </div>
          <div className="text-right min-w-[100px]">
            <p className="text-sm text-gray-600">{t('progress_label')}</p>
            <p className="text-lg font-bold text-purple-600">
              {t('progress_percent', { percent: Math.round(progress) })}
            </p>
          </div>
        </div>

        <Progress value={progress} className="h-3" />
      </Card>

      {/* Conteúdo do bloco */}
      <Card className="p-8">
        <div className="flex items-start justify-between mb-6">
          <div className="flex-1">
            {block.type === 'text' && (
              <div className="prose prose-lg max-w-none">
                <p className="text-lg leading-relaxed text-gray-800">
                  {block.content}
                </p>
              </div>
            )}

            {/* Placeholder com mesmo estilo do bloco de animacao (sem
                broken-image icon). Mostra o nome do asset (alt > src >
                content) com um emoji ate' termos imagens reais. */}
            {block.type === 'image' && (
              <div className="aspect-video bg-gradient-to-br from-blue-100 to-emerald-100 rounded-lg flex items-center justify-center">
                <p className="text-blue-700 font-medium">
                  ✨ {t('image_placeholder', { alt: block.alt || block.src || block.content || t('image_default_alt') })}
                </p>
              </div>
            )}

            {block.type === 'video' && (
              <div className="aspect-video bg-gray-100 rounded-lg flex items-center justify-center">
                <p className="text-gray-500">
                  📹 {t('video_placeholder', { label: block.content || t('video_default_label') })}
                </p>
              </div>
            )}

            {block.type === 'animation' && (
              <div className="aspect-square bg-gradient-to-br from-purple-100 to-pink-100 rounded-lg flex items-center justify-center">
                <p className="text-purple-700 font-medium">
                  ✨ {t('animation_placeholder', { label: block.content || t('animation_default_label') })}
                </p>
              </div>
            )}
          </div>

          {/* Botão de narração */}
          {block.type === 'text' && (
            <Button
              variant="ghost"
              size="sm"
              onClick={() => handleNarration(block.content)}
              className="ml-4 flex-shrink-0"
              title={t('narration_title')}
            >
              <Volume2 className="w-5 h-5" />
            </Button>
          )}
        </div>
      </Card>

      {/* Navegação */}
      <div className="flex justify-between items-center">
        <Button
          variant="outline"
          onClick={handlePrevious}
          disabled={currentBlock === 0}
        >
          <ArrowLeft className="w-4 h-4 mr-2" />
          {t('previous')}
        </Button>

        <div className="flex space-x-2">
          {displayBlocks.map((_: unknown, index: number) => (
            <button
              key={index}
              onClick={() => setCurrentBlock(index)}
              className={`w-3 h-3 rounded-full transition-colors ${
                index === currentBlock
                  ? 'bg-purple-500'
                  : index <= currentBlock
                    ? 'bg-purple-300'
                    : 'bg-gray-200'
              }`}
              title={t('block_progress', { current: index + 1, total: displayBlocks.length })}
            />
          ))}
        </div>

        <Button
          onClick={handleNext}
          className="bg-purple-600 hover:bg-purple-700"
        >
          {currentBlock === displayBlocks.length - 1 ? (
            <>
              {t('challenge')}
              <ArrowRight className="w-4 h-4 ml-2" />
            </>
          ) : (
            <>
              {t('next')}
              <ArrowRight className="w-4 h-4 ml-2" />
            </>
          )}
        </Button>
      </div>
    </div>
  );
}