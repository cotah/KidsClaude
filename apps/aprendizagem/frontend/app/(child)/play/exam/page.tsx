'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { useQuery, useMutation } from '@tanstack/react-query';
import { useTranslations } from 'next-intl';
import Link from 'next/link';
import { ArrowLeft, CrownIcon, SendIcon, CheckCircleIcon, ExternalLink, Download } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { KidCard } from '@/components/ui/card';
import { Badge } from '@/components/ui/badge';
import { examApi, lessonsApi } from '@/lib/api';
import useAppStore from '@/lib/store/app-store';
import { cn, getAgeGroup } from '@/lib/utils';
import { TypingIndicator } from '@/components/chat/typing-indicator';
import type { ExamSession, ExamMessageResponse, ExamSubmitResponse } from '@/types/api';

/**
 * Limite dinamico de chars no texto livre por faixa etaria. Mesma
 * funcao do lesson chat (app/(child)/play/lesson/[id]/chat/page.tsx)
 * e do backend (_max_message_length_for_age em api/chat.py). Os 3
 * lugares precisam mover juntos.
 */
function freeTextMaxLength(age: number | undefined): number {
  const a = age ?? 8;
  if (a <= 8) return 200;
  if (a <= 10) return 500;
  if (a <= 12) return 1000;
  return 2000;
}

/**
 * Quantidade de passos do projeto por faixa. 6-8 e 9-10 sao projetos
 * de 5 passos (assistente de historias, Pokedex); 11-12 e 12+ tem 6
 * passos (site, system prompt). Backend caps current_step em 6.
 */
function totalSteps(age: number | undefined): number {
  const a = age ?? 8;
  return a <= 10 ? 5 : 6;
}

/**
 * Extrai o conteudo do ULTIMO bloco [[ ... ]] de mensagens do assistente.
 * Backend instrui a Atena a colocar o entregavel final (prompt/ficha/
 * system prompt) entre [[ ]] junto com PROJETO_COMPLETO. Aqui pegamos
 * isso pra mostrar destacado na tela de conclusao e no download.
 */
function extractFinalProject(messages: Array<{ role: 'child' | 'assistant'; content: string }>): string | null {
  for (let i = messages.length - 1; i >= 0; i--) {
    const msg = messages[i];
    if (msg.role !== 'assistant') continue;
    const matches = [...msg.content.matchAll(/\[\[([\s\S]+?)\]\]/g)];
    if (matches.length > 0) {
      return matches[matches.length - 1][1].trim();
    }
  }
  return null;
}

/**
 * Página do exame final - conforme spec curriculum redesign seção 7.4
 */
export default function ExamPage() {
  const t = useTranslations('exam_page');
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
      // Mensagem de abertura vem do backend agora, adaptada por idade
      // e locale e com o nome real da crianca. Antes era hardcoded aqui.
      setMessages([
        {
          role: 'assistant',
          content: session.opening_message,
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
          <p className="text-kid-lg text-gray-600">{t('need_profile')}</p>
          <Button variant="sunny" size="kid-lg" asChild>
            <Link href="/select">{t('pick_profile')}</Link>
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
                <span>{t('back_to_hub')}</span>
              </Link>
            </Button>

            {examSession && (
              <ExamProgressBar currentStep={currentStep} totalSteps={totalSteps(currentChild.age)} />
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
            childAge={currentChild.age}
            childName={currentChild.name}
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
            maxLength={freeTextMaxLength(currentChild.age)}
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
  const t = useTranslations('exam_page');

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
              {examLesson?.title || t('fallback_title')}
            </h1>
            <p className="text-kid-lg text-purple-700 font-medium">
              {t('intro_subtitle')}
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
            {isStarting ? t('intro_starting') : t('intro_start')}
          </Button>
        </div>
      </KidCard>
    </div>
  );
}

/**
 * Barra de progresso do exame (5 passos)
 */
function ExamProgressBar({ currentStep, totalSteps }: { currentStep: number; totalSteps: number }) {
  const t = useTranslations('exam_page');
  // Backend devolve current_step com cap em 6 - se a faixa for 5 passos
  // (6-8 / 9-10), capear aqui pra nao mostrar "Passo 6 de 5" nem bolinhas
  // a mais quando current_step extrapola o tamanho do projeto da idade.
  const displayStep = Math.min(currentStep, totalSteps);
  return (
    <div className="flex items-center space-x-2">
      <span className="text-kid-sm text-gray-600 font-medium">
        {t('progress_step', { step: displayStep, total: totalSteps })}
      </span>
      <div className="flex space-x-1">
        {Array.from({ length: totalSteps }).map((_, index) => (
          <div
            key={index}
            className={cn(
              'w-3 h-3 rounded-full transition-colors',
              index < displayStep
                ? 'bg-purple-500'
                : index === displayStep
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
  maxLength,
}: {
  messages: Array<{ role: 'child' | 'assistant'; content: string }>;
  inputValue: string;
  onInputChange: (value: string) => void;
  onSendMessage: () => void;
  onKeyDown: (e: React.KeyboardEvent) => void;
  isSending: boolean;
  maxLength: number;
}) {
  const t = useTranslations('exam_page');
  return (
    <div className="max-w-4xl mx-auto space-y-6">
      {/* Chat area - min-h garante area util mesmo com poucas mensagens;
          max-h aumentado (era 24rem) pra caber mais mensagens sem scroll. */}
      <KidCard className="bg-white/90 backdrop-blur-sm">
        <div className="p-6 space-y-4 min-h-[28rem] max-h-[36rem] overflow-y-auto">
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
                {message.role === 'assistant' ? (
                  <AssistantMessageContent content={message.content} />
                ) : (
                  <p className="text-kid-base">{message.content}</p>
                )}
              </div>
            </div>
          ))}
          {isSending && (
            <div className="flex justify-start">
              <TypingIndicator />
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
              placeholder={t('input_placeholder', { max: maxLength })}
              maxLength={maxLength}
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
            {t('input_counter', { current: inputValue.length, max: maxLength })}
          </p>
        </div>
      </KidCard>
    </div>
  );
}

/**
 * Tela de conclusao: mostra o entregavel final (entre [[ ]]) destacado,
 * sugere o que fazer com ele (varia por idade), botao de download e
 * finalmente o submit que dispara XP + badge.
 */
function ExamCompletion({
  messages,
  childAge,
  childName,
  onSubmitExam,
  isSubmitting,
}: {
  messages: Array<{ role: 'child' | 'assistant'; content: string }>;
  childAge: number;
  childName: string;
  onSubmitExam: () => void;
  isSubmitting: boolean;
}) {
  const t = useTranslations('exam_page');
  const project = extractFinalProject(messages);
  const ageGroup = getAgeGroup(childAge);

  // Download .txt do projeto. Sem libs: Blob + URL.createObjectURL.
  // Filename traduzido (meu-projeto-Miguel.txt / my-project-Miguel.txt).
  const handleDownload = () => {
    if (!project) return;
    const filename = t('project_filename', { name: childName }).replace(/\s+/g, '-');
    const blob = new Blob([project], { type: 'text/plain;charset=utf-8' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  // Mapa de "o que fazer agora?" por faixa. Cada entrada tem o texto
  // explicativo + 1 ou 2 botoes (links externos abrem nova aba).
  const whatsNext: Record<string, { text: string; buttons: Array<{ label: string; href: string; external: boolean }> }> = {
    '6-8': {
      text: t('whats_next_6_8'),
      buttons: [{ label: t('open_atena'), href: '/play', external: false }],
    },
    '9-10': {
      text: t('whats_next_9_10'),
      buttons: [{ label: t('open_claude_ai'), href: 'https://claude.ai', external: true }],
    },
    '11-12': {
      text: t('whats_next_11_12'),
      buttons: [
        { label: t('open_codepen'), href: 'https://codepen.io/pen', external: true },
        { label: t('open_claude_ai_test'), href: 'https://claude.ai', external: true },
      ],
    },
    '12+': {
      text: t('whats_next_12_plus'),
      buttons: [{ label: t('open_claude_ai_test'), href: 'https://claude.ai', external: true }],
    },
  };

  const next = whatsNext[ageGroup];

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <KidCard className="bg-gradient-to-br from-green-100 to-mint-200 border-2 border-green-300">
        <div className="p-8 space-y-6">
          {/* Header centralizado */}
          <div className="text-center space-y-3">
            <CheckCircleIcon className="w-16 h-16 text-green-600 mx-auto" />
            <h2 className="text-kid-xl font-bold text-green-800">
              {t('completion_title')}
            </h2>
            <p className="text-kid-base text-green-700">
              {project ? t('completion_your_project') : t('completion_no_project')}
            </p>
          </div>

          {/* Bloco do projeto extraido dos [[ ]] - mesma vibe purple/
              yellow mono que usamos no chat pra destacar entregaveis. */}
          {project && (
            <pre className="bg-purple-900 text-yellow-100 font-mono text-sm rounded-kid-md p-4 whitespace-pre-wrap break-words shadow-inner">
              {project}
            </pre>
          )}

          {/* O que fazer agora? - varia por idade. */}
          {next && (
            <div className="bg-white/80 rounded-kid-lg p-5 space-y-3">
              <h3 className="text-kid-base font-bold text-purple-800">
                {t('whats_next')}
              </h3>
              <p className="text-kid-sm text-gray-700">{next.text}</p>
              <div className="flex flex-col sm:flex-row gap-2">
                {next.buttons.map((b) =>
                  b.external ? (
                    <a
                      key={b.label}
                      href={b.href}
                      target="_blank"
                      rel="noopener noreferrer"
                      className="inline-flex items-center justify-center gap-2 rounded-kid-md bg-purple-500 hover:bg-purple-600 text-white font-bold px-4 py-2 text-kid-sm transition-colors"
                    >
                      {b.label}
                      <ExternalLink className="w-4 h-4" />
                    </a>
                  ) : (
                    <Link
                      key={b.label}
                      href={b.href as any}
                      className="inline-flex items-center justify-center gap-2 rounded-kid-md bg-purple-500 hover:bg-purple-600 text-white font-bold px-4 py-2 text-kid-sm transition-colors"
                    >
                      {b.label}
                    </Link>
                  )
                )}
              </div>
            </div>
          )}

          {/* Botoes finais: download + submit */}
          <div className="flex flex-col items-center gap-3 pt-2">
            {project && (
              <Button
                onClick={handleDownload}
                variant="outline"
                size="kid-default"
                className="border-purple-400 text-purple-700 hover:bg-purple-50"
              >
                <Download className="w-4 h-4 mr-2" />
                {t('download_project')}
              </Button>
            )}
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
              {isSubmitting ? t('completion_finalizing') : t('completion_finalize')}
            </Button>
          </div>
        </div>
      </KidCard>
    </div>
  );
}

/**
 * Tela de celebração final com badge e XP
 */
function ExamCelebration({ result }: { result: ExamSubmitResponse }) {
  const t = useTranslations('exam_page');
  return (
    <div className="min-h-screen bg-gradient-to-br from-yellow-100 to-purple-200 flex items-center justify-center">
      <div className="max-w-2xl mx-auto p-6">
        <KidCard className="bg-gradient-to-br from-yellow-100 to-purple-200 border-4 border-gradient-to-r from-yellow-400 to-purple-400">
          <div className="p-8 text-center space-y-6">
            {/* Celebração */}
            <div className="text-6xl animate-bounce">🎉</div>

            <div className="space-y-2">
              <h1 className="text-kid-2xl font-bold bg-gradient-to-r from-purple-600 to-yellow-600 bg-clip-text text-transparent">
                {t('celebration_title')}
              </h1>
              <p className="text-kid-lg text-purple-700">
                {t('celebration_subtitle')}
              </p>
            </div>

            {/* Recompensas */}
            <div className="bg-white/80 rounded-kid-lg p-6 space-y-4">
              <div className="text-center space-y-2">
                <div className="text-4xl">⭐</div>
                <p className="text-kid-lg font-bold text-gray-800">
                  {t('celebration_xp', { xp: result.xp_earned })}
                </p>
              </div>

              {result.badges_unlocked.length > 0 && (
                <div className="text-center space-y-2">
                  <div className="text-4xl">🏆</div>
                  <p className="text-kid-base font-bold text-gray-800">
                    {t('celebration_new_badge')}
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
                  {t('celebration_see_badges')}
                </Link>
              </Button>

              <p className="text-kid-sm text-gray-600">
                {t('celebration_footer')}
              </p>
            </div>
          </div>
        </KidCard>
      </div>
    </div>
  );
}

/**
 * Renderiza a mensagem do assistente destacando conteudo entre [[ ]]
 * como um bloco mono com fundo diferente - sinaliza pra crianca que
 * aquela e' a criacao final dela (prompt, ficha, system prompt etc).
 *
 * Backend instrui a Atena a usar [[ ]] ao volta da criacao no fim de
 * cada projeto. Aqui parseamos o texto em segmentos plain/highlight
 * e renderizamos cada um com seu estilo proprio.
 */
function AssistantMessageContent({ content }: { content: string }) {
  // Split conservador: aceita multiplos blocos [[...]] na mesma mensagem.
  // Regex nao-greedy + flag s pra cobrir blocos multi-linha.
  const segments: Array<{ kind: 'text' | 'highlight'; value: string }> = [];
  const re = /\[\[([\s\S]+?)\]\]/g;
  let lastIndex = 0;
  let match: RegExpExecArray | null;
  while ((match = re.exec(content)) !== null) {
    if (match.index > lastIndex) {
      segments.push({ kind: 'text', value: content.slice(lastIndex, match.index) });
    }
    segments.push({ kind: 'highlight', value: match[1] });
    lastIndex = match.index + match[0].length;
  }
  if (lastIndex < content.length) {
    segments.push({ kind: 'text', value: content.slice(lastIndex) });
  }

  // Sem blocos: renderiza igual ao antes.
  if (segments.every((s) => s.kind === 'text')) {
    return <p className="text-kid-base">{content}</p>;
  }

  return (
    <div className="space-y-2">
      {segments.map((seg, i) =>
        seg.kind === 'text' ? (
          seg.value.trim() ? (
            <p key={i} className="text-kid-base whitespace-pre-wrap">{seg.value}</p>
          ) : null
        ) : (
          <pre
            key={i}
            className="bg-purple-900 text-yellow-100 font-mono text-sm rounded-kid-md p-3 whitespace-pre-wrap break-words"
          >
            {seg.value.trim()}
          </pre>
        )
      )}
    </div>
  );
}