'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { useQuery, useMutation } from '@tanstack/react-query';
import Link from 'next/link';
import { ArrowLeft, CrownIcon, SendIcon, CheckCircleIcon } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { KidCard } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { examApi, lessonsApi } from '@/lib/api';
import useAppStore from '@/lib/store/app-store';
import { cn } from '@/lib/utils';
import type { ExamSession, ExamMessageResponse, ExamSubmitResponse } from '@/types/api';

/**
 * Página do exame final - conforme spec curriculum redesign seção 7.4
 */
export default function ExamPage() {
  const router = useRouter();
  const { currentChild } = useAppStore();
  const [examSession, setExamSession] = React.useState<ExamSession | null>(null);
  const [currentStep, setCurrentStep] = React.useState(1);
  const [isComplete, setIsComplete] = React.useState(false);
  const [messages, setMessages] = React.useState<Array<{ role: 'child' | 'assistant'; content: string }>>([]);
  const [inputValue, setInputValue] = React.useState('');
  const [isSubmitting, setIsSubmitting] = React.useState(false);
  const [examResult, setExamResult] = React.useState<ExamSubmitResponse | null>(null);

  // Buscar dados da lição do exame final
  const { data: examLesson, isLoading: isLoadingLesson } = useQuery({
    queryKey: ['lesson', 'final-exam'],
    queryFn: async () => {
      const lessons = await lessonsApi.list();
      return lessons.find(l => l.is_final_exam);
    },
    enabled: !!currentChild,
  });

  // Iniciar exame
  const startExamMutation = useMutation({
    mutationFn: () => examApi.startExam(),
    onSuccess: (session) => {
      setExamSession(session);
      // Primeira mensagem do Claude
      setMessages([
        {
          role: 'assistant',
          content: 'Oi! Eu sou o Claude Mentor, e estou aqui para te ajudar a planejar o app dos seus sonhos. Vamos passar por 5 etapas juntos. Primeiro, me conta: que problema do seu dia a dia você gostaria de resolver com um app?',
        }
      ]);
    },
    onError: (error: any) => {
      // Se exame estiver bloqueado (403 EXAM_LOCKED), voltar ao hub
      if (error?.response?.status === 403) {
        router.push('/play');
      }
    },
  });

  // Enviar mensagem no exame
  const sendMessageMutation = useMutation({
    mutationFn: ({ sessionId, content }: { sessionId: string; content: string }) =>
      examApi.sendExamMessage(sessionId, { content }),
    onSuccess: (response: ExamMessageResponse) => {
      setMessages(prev => [
        ...prev,
        { role: 'child', content: inputValue },
        { role: 'assistant', content: response.assistant_message.content }
      ]);
      setCurrentStep(response.current_step);
      setIsComplete(response.is_complete);
      setInputValue('');
    },
  });

  // Submeter exame
  const submitExamMutation = useMutation({
    mutationFn: (sessionId: string) => examApi.submitExam(sessionId),
    onSuccess: (result) => {
      setExamResult(result);
    },
  });

  const handleStartExam = () => {
    startExamMutation.mutate();
  };

  const handleSendMessage = () => {
    if (!examSession || !inputValue.trim() || sendMessageMutation.isPending) return;

    sendMessageMutation.mutate({
      sessionId: examSession.session_id,
      content: inputValue.trim(),
    });
  };

  const handleSubmitExam = () => {
    if (!examSession) return;
    setIsSubmitting(true);
    submitExamMutation.mutate(examSession.session_id);
  };

  const handleKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      handleSendMessage();
    }
  };

  if (!currentChild) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="text-6xl">🤔</div>
          <p className="text-kid-lg text-gray-600">
            Ops! Você precisa escolher seu perfil primeiro.
          </p>
          <Button variant="sunny" size="kid-lg" asChild>
            <Link href="/select">Escolher Perfil</Link>
          </Button>
        </div>
      </div>
    );
  }

  if (examResult) {
    return <ExamCelebration result={examResult} />;
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-100 via-yellow-100 to-purple-200">
      {/* Header especial do exame */}
      <header className="bg-white/80 backdrop-blur-sm border-b border-purple-200 p-4">
        <div className="container mx-auto max-w-4xl">
          <div className="flex items-center justify-between">
            <Button
              variant="ghost"
              size="kid-sm"
              asChild
              className="text-gray-600 hover:text-gray-800"
            >
              <Link href="/play" className="flex items-center space-x-2">
                <ArrowLeft className="w-4 h-4" />
                <span>Voltar ao Hub</span>
              </Link>
            </Button>

            {examSession && (
              <ExamProgressBar currentStep={currentStep} />
            )}
          </div>
        </div>
      </header>

      <main className="container mx-auto max-w-4xl p-6">
        {!examSession ? (
          <ExamIntro
            examLesson={examLesson}
            isLoading={isLoadingLesson}
            onStartExam={handleStartExam}
            isStarting={startExamMutation.isPending}
          />
        ) : isComplete && !isSubmitting ? (
          <ExamCompletion
            messages={messages}
            onSubmitExam={handleSubmitExam}
            isSubmitting={submitExamMutation.isPending}
          />
        ) : (
          <ExamChat
            messages={messages}
            inputValue={inputValue}
            onInputChange={setInputValue}
            onSendMessage={handleSendMessage}
            onKeyDown={handleKeyDown}
            isSending={sendMessageMutation.isPending}
          />
        )}
      </main>
    </div>
  );
}

/**
 * Componente de introdução do exame
 */
function ExamIntro({
  examLesson,
  isLoading,
  onStartExam,
  isStarting,
}: {
  examLesson?: any;
  isLoading: boolean;
  onStartExam: () => void;
  isStarting: boolean;
}) {
  if (isLoading) {
    return (
      <div className="max-w-2xl mx-auto">
        <div className="h-96 rounded-kid-lg bg-gradient-to-br from-purple-200 to-yellow-200 animate-pulse" />
      </div>
    );
  }

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <KidCard className="bg-gradient-to-br from-purple-100 to-yellow-100 border-2 border-purple-300">
        <div className="p-8 text-center space-y-6">
          {/* Ícone especial */}
          <div className="w-20 h-20 bg-gradient-to-br from-yellow-400 to-purple-500 rounded-full flex items-center justify-center mx-auto shadow-lg">
            <CrownIcon className="w-12 h-12 text-white" />
          </div>

          {/* Título */}
          <div className="space-y-2">
            <h1 className="text-kid-2xl font-bold bg-gradient-to-r from-purple-600 to-yellow-600 bg-clip-text text-transparent">
              {examLesson?.title || 'Projeto Final'}
            </h1>
            <p className="text-kid-lg text-purple-700 font-medium">
              Atena vai te ajudar a planejar seu app em 5 passos
            </p>
          </div>

          {/* Content blocks da introdução */}
          {examLesson?.content_blocks && (
            <div className="space-y-4 text-kid-base text-gray-700">
              {examLesson.content_blocks.map((block: any, index: number) => (
                <p key={index}>{block.content}</p>
              ))}
            </div>
          )}

          {/* Botão de início */}
          <Button
            variant="default"
            size="kid-lg"
            onClick={onStartExam}
            disabled={isStarting}
            className={cn(
              'bg-gradient-to-r from-purple-500 to-yellow-500',
              'hover:from-purple-600 hover:to-yellow-600',
              'text-white shadow-lg font-bold',
              'w-full max-w-xs'
            )}
          >
            {isStarting ? 'Iniciando...' : 'Estou pronto, vamos começar!'}
          </Button>
        </div>
      </KidCard>
    </div>
  );
}

/**
 * Barra de progresso do exame (5 passos)
 */
function ExamProgressBar({ currentStep }: { currentStep: number }) {
  return (
    <div className="flex items-center space-x-2">
      <span className="text-kid-sm text-gray-600 font-medium">
        Passo {currentStep} de 5
      </span>
      <div className="flex space-x-1">
        {Array.from({ length: 5 }).map((_, index) => (
          <div
            key={index}
            className={cn(
              'w-3 h-3 rounded-full transition-colors',
              index < currentStep
                ? 'bg-purple-500'
                : index === currentStep
                  ? 'bg-yellow-400'
                  : 'bg-gray-200'
            )}
          />
        ))}
      </div>
    </div>
  );
}

/**
 * Interface de chat do exame
 */
function ExamChat({
  messages,
  inputValue,
  onInputChange,
  onSendMessage,
  onKeyDown,
  isSending,
}: {
  messages: Array<{ role: 'child' | 'assistant'; content: string }>;
  inputValue: string;
  onInputChange: (value: string) => void;
  onSendMessage: () => void;
  onKeyDown: (e: React.KeyboardEvent) => void;
  isSending: boolean;
}) {
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Chat area */}
      <KidCard className="bg-white/90 backdrop-blur-sm">
        <div className="p-6 space-y-4 max-h-96 overflow-y-auto">
          {messages.map((message, index) => (
            <div
              key={index}
              className={cn(
                'flex',
                message.role === 'child' ? 'justify-end' : 'justify-start'
              )}
            >
              <div
                className={cn(
                  'max-w-xs lg:max-w-md px-4 py-3 rounded-kid-lg',
                  message.role === 'child'
                    ? 'bg-purple-500 text-white'
                    : 'bg-yellow-100 text-gray-800 border border-yellow-300'
                )}
              >
                <p className="text-kid-base">{message.content}</p>
              </div>
            </div>
          ))}
          {isSending && (
            <div className="flex justify-start">
              <div className="bg-yellow-100 px-4 py-3 rounded-kid-lg border border-yellow-300">
                <p className="text-kid-base text-gray-600">Claude está pensando...</p>
              </div>
            </div>
          )}
        </div>
      </KidCard>

      {/* Input area */}
      <KidCard className="bg-white/90 backdrop-blur-sm">
        <div className="p-4">
          <div className="flex space-x-3">
            <textarea
              value={inputValue}
              onChange={(e) => onInputChange(e.target.value)}
              onKeyDown={onKeyDown}
              placeholder="Escreva sua resposta aqui... (máximo 300 caracteres)"
              maxLength={300}
              rows={3}
              className="flex-1 resize-none border border-gray-300 rounded-kid-md p-3 text-kid-base focus:outline-none focus:ring-2 focus:ring-purple-500"
              disabled={isSending}
            />
            <Button
              onClick={onSendMessage}
              disabled={!inputValue.trim() || isSending}
              variant="default"
              size="kid-default"
              className="bg-purple-500 hover:bg-purple-600 text-white self-end"
            >
              <SendIcon className="w-4 h-4" />
            </Button>
          </div>
          <p className="text-kid-xs text-gray-500 mt-2">
            {inputValue.length}/300 caracteres
          </p>
        </div>
      </KidCard>
    </div>
  );
}

/**
 * Tela de conclusão do exame antes do submit
 */
function ExamCompletion({
  messages,
  onSubmitExam,
  isSubmitting,
}: {
  messages: Array<{ role: 'child' | 'assistant'; content: string }>;
  onSubmitExam: () => void;
  isSubmitting: boolean;
}) {
  // O último message do assistant deve conter o resumo final
  const finalSummary = messages[messages.length - 1]?.content || '';

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <KidCard className="bg-gradient-to-br from-green-100 to-mint-200 border-2 border-green-300">
        <div className="p-8 text-center space-y-6">
          <CheckCircleIcon className="w-16 h-16 text-green-600 mx-auto" />

          <div className="space-y-2">
            <h2 className="text-kid-xl font-bold text-green-800">
              Parabéns! Você completou os 5 passos!
            </h2>
            <p className="text-kid-base text-green-700">
              Aqui está o resumo do seu projeto:
            </p>
          </div>

          {/* Ficha-resumo do projeto */}
          <div className="bg-white/80 rounded-kid-lg p-6 text-left">
            <div className="prose prose-sm max-w-none text-gray-800">
              {finalSummary.split('\n').map((paragraph, index) => (
                <p key={index} className="text-kid-sm mb-2">
                  {paragraph}
                </p>
              ))}
            </div>
          </div>

          <Button
            onClick={onSubmitExam}
            disabled={isSubmitting}
            variant="default"
            size="kid-lg"
            className={cn(
              'bg-gradient-to-r from-green-500 to-mint-500',
              'hover:from-green-600 hover:to-mint-600',
              'text-white shadow-lg font-bold',
              'w-full max-w-xs'
            )}
          >
            {isSubmitting ? 'Enviando...' : 'Concluir e Enviar Projeto'}
          </Button>
        </div>
      </KidCard>
    </div>
  );
}

/**
 * Tela de celebração final com badge e XP
 */
function ExamCelebration({ result }: { result: ExamSubmitResponse }) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-yellow-100 to-purple-200 flex items-center justify-center">
      <div className="max-w-2xl mx-auto p-6">
        <KidCard className="bg-gradient-to-br from-yellow-100 to-purple-200 border-4 border-gradient-to-r from-yellow-400 to-purple-400">
          <div className="p-8 text-center space-y-6">
            {/* Celebração */}
            <div className="text-6xl animate-bounce">🎉</div>

            <div className="space-y-2">
              <h1 className="text-kid-2xl font-bold bg-gradient-to-r from-purple-600 to-yellow-600 bg-clip-text text-transparent">
                INCRÍVEL! VOCÊ CONSEGUIU!
              </h1>
              <p className="text-kid-lg text-purple-700">
                Você completou todo o curso e criou um projeto incrível!
              </p>
            </div>

            {/* Recompensas */}
            <div className="bg-white/80 rounded-kid-lg p-6 space-y-4">
              <div className="text-center space-y-2">
                <div className="text-4xl">⭐</div>
                <p className="text-kid-lg font-bold text-gray-800">
                  +{result.xp_earned} XP
                </p>
              </div>

              {result.badges_unlocked.length > 0 && (
                <div className="text-center space-y-2">
                  <div className="text-4xl">🏆</div>
                  <p className="text-kid-base font-bold text-gray-800">
                    Nova conquista desbloqueada:
                  </p>
                  <Badge variant="default" className="bg-gradient-to-r from-purple-500 to-yellow-500 text-white">
                    {result.badges_unlocked[0]} {/* CAPSTONE_BUILDER */}
                  </Badge>
                </div>
              )}
            </div>

            <div className="space-y-4">
              <Button
                variant="default"
                size="kid-lg"
                asChild
                className={cn(
                  'bg-gradient-to-r from-purple-500 to-yellow-500',
                  'hover:from-purple-600 hover:to-yellow-600',
                  'text-white shadow-lg font-bold'
                )}
              >
                <Link href="/play">
                  Ver Minhas Conquistas
                </Link>
              </Button>

              <p className="text-kid-sm text-gray-600">
                Você agora é oficialmente um Construtor Capstone! 👑
              </p>
            </div>
          </div>
        </KidCard>
      </div>
    </div>
  );
}