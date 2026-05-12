'use client';

import { useState, useEffect } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useQuery, useMutation } from '@tanstack/react-query';
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
  const params = useParams();
  const router = useRouter();
  const lessonId = params.id as string;

  const [currentBlock, setCurrentBlock] = useState(0);

  // Buscar dados da licao
  const { data: lesson, isLoading } = useQuery({
    queryKey: ['lesson', lessonId],
    queryFn: () => lessonsApi.get(lessonId),
  });

  // Marcar lição como iniciada
  const startLessonMutation = useMutation({
    mutationFn: () => lessonsApi.start(lessonId),
  });

  useEffect(() => {
    if (lesson) {
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

  const handleNext = () => {
    if (!lesson) return;

    if (currentBlock < lesson.content_blocks.length - 1) {
      setCurrentBlock(currentBlock + 1);
    } else {
      // Ultima tela - ir para desafio
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
          <h2 className="text-xl font-bold text-gray-900 mb-2">Lição não encontrada</h2>
          <Button onClick={() => router.push('/play')}>
            Voltar ao início
          </Button>
        </Card>
      </div>
    );
  }

  const block = lesson.content_blocks[currentBlock];
  const progress = ((currentBlock + 1) / lesson.content_blocks.length) * 100;

  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Header com progresso */}
      <Card className="p-6">
        <div className="flex items-center justify-between mb-4">
          <div>
            <h1 className="text-2xl font-bold text-gray-900">{lesson.title}</h1>
            <p className="text-gray-600">
              Bloco {currentBlock + 1} de {lesson.content_blocks.length}
            </p>
          </div>
          <div className="text-right min-w-[100px]">
            <p className="text-sm text-gray-600">Progresso</p>
            <p className="text-lg font-bold text-purple-600">
              {Math.round(progress)}%
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

            {block.type === 'image' && (
              <div className="text-center">
                <img
                  src={block.content || '/placeholder-image.svg'}
                  alt="Ilustração da lição"
                  className="mx-auto max-w-full h-auto rounded-lg shadow-md"
                />
              </div>
            )}

            {block.type === 'video' && (
              <div className="aspect-video bg-gray-100 rounded-lg flex items-center justify-center">
                <p className="text-gray-500">
                  📹 Vídeo: {block.content || 'Carregando...'}
                </p>
              </div>
            )}

            {block.type === 'animation' && (
              <div className="aspect-square bg-gradient-to-br from-purple-100 to-pink-100 rounded-lg flex items-center justify-center">
                <p className="text-purple-700 font-medium">
                  ✨ Animação: {block.content || 'Interativa'}
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
              title="Ouvir narração"
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
          Anterior
        </Button>

        <div className="flex space-x-2">
          {lesson.content_blocks.map((_: unknown, index: number) => (
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
              title={`Bloco ${index + 1}`}
            />
          ))}
        </div>

        <Button
          onClick={handleNext}
          className="bg-purple-600 hover:bg-purple-700"
        >
          {currentBlock === lesson.content_blocks.length - 1 ? (
            <>
              Desafio
              <ArrowRight className="w-4 h-4 ml-2" />
            </>
          ) : (
            <>
              Próximo
              <ArrowRight className="w-4 h-4 ml-2" />
            </>
          )}
        </Button>
      </div>
    </div>
  );
}