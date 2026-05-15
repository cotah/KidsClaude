'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import { useParams, useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import type { Route } from 'next';
import { ArrowLeft, X, Send } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { MascotBubble, Mascot } from '@/components/ui/mascot-bubble';
import { useToast } from '@/components/ui/toast';
import { ChatBubbles } from '@/components/chat/chat-bubbles';
import { PromptButtonRow } from '@/components/chat/prompt-button-row';
import { PromptSlotEditor } from '@/components/chat/prompt-slot-editor';
import { SafetyStrikes } from '@/components/chat/safety-strikes';
import { lessonsApi } from '@/lib/api/lessons';
import { chatApi } from '@/lib/api/chat';
import { getApiErrorCode, getApiErrorMessage } from '@/lib/api/client';
import useAppStore from '@/lib/store/app-store';
import { getAgeGroup } from '@/lib/utils';
import { stripMarkdown } from '@/lib/utils/markdown';
import type { ChatMessage, PromptTemplate, SendMessageRequest, SendMessageResponse } from '@/types/api';

const FREE_TEXT_MAX_LENGTH = 200;

const MAX_STRIKES = 3;
// Velocidade da animacao de "digitacao" da resposta da Claude (caracteres/tick).
const TYPING_SPEED_MS = 18;

/**
 * Pagina de chat com Claude - prompts guiados.
 * Backend nao expoe SSE real; simulamos streaming animando caractere a caractere
 * a resposta apos receber via POST /v1/chat/sessions/:id/messages.
 */
export default function ChatPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { toast } = useToast();
  const { currentChild } = useAppStore();
  const lessonId = params.id;

  const [sessionId, setSessionId] = useState<string | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [pending, setPending] = useState(false);
  const [pendingText, setPendingText] = useState('');
  const [strikes, setStrikes] = useState(0);
  const [sessionEnded, setSessionEnded] = useState(false);
  // hasInteracted: true depois que a crianca enviou a 1a mensagem (sugestao
  // ou texto livre). Usado pra alternar suggestions -> input box.
  const [hasInteracted, setHasInteracted] = useState(false);
  const [inputText, setInputText] = useState('');
  const scrollRef = useRef<HTMLDivElement>(null);

  const ageGroup = currentChild ? getAgeGroup(currentChild.age) : '6-8';

  // Carrega licao para obter os prompt templates filtrados pela faixa.
  const { data: lesson, isLoading: loadingLesson } = useQuery({
    queryKey: ['lesson-chat', lessonId],
    queryFn: () => lessonsApi.get(lessonId),
    enabled: !!lessonId,
  });

  // Cria sessao de chat ao carregar a pagina (uma unica vez).
  useEffect(() => {
    if (!lessonId || sessionId) return;
    let cancelled = false;
    chatApi
      .createSession({ lesson_id: lessonId })
      .then((res) => {
        if (!cancelled) setSessionId(res.session_id);
      })
      .catch((err) => {
        if (!cancelled) {
          toast({
            type: 'error',
            title: 'Nao consegui abrir a conversa',
            description: getApiErrorMessage(err),
          });
        }
      });
    return () => {
      cancelled = true;
    };
  }, [lessonId, sessionId, toast]);

  // Auto-scroll suave quando mensagens crescem.
  useEffect(() => {
    scrollRef.current?.scrollTo({
      top: scrollRef.current.scrollHeight,
      behavior: 'smooth',
    });
  }, [messages, pendingText]);

  // Mostra TODOS os templates da licao - o age_band do template servia
  // como filtro global, mas dentro de uma licao a lista ja foi curada
  // pra aquela faixa. Filtrar de novo zerava as sugestoes quando a idade
  // da crianca nao casava perfeitamente (ex: 8 anos numa licao da Stage 2,
  // cujo age_band e' '9-10'). Se quiser priorizar por idade no futuro,
  // ordene em vez de filtrar.
  const templates: PromptTemplate[] = lesson?.prompt_templates ?? [];

  // Anima a resposta da Claude caractere a caractere para criar a sensacao de stream.
  const animateAssistant = useCallback(
    async (full: string, response: SendMessageResponse) => {
      setPendingText('');
      for (let i = 1; i <= full.length; i++) {
        await new Promise((r) => setTimeout(r, TYPING_SPEED_MS));
        setPendingText(full.slice(0, i));
      }
      // Materializa como mensagem persistida apos terminar a animacao.
      const finalMsg: ChatMessage = {
        id: response.message_id,
        session_id: sessionId ?? '',
        role: 'assistant',
        content: full,
        moderation_status: response.assistant_message.moderation_status,
        created_at: new Date().toISOString(),
      };
      setMessages((prev) => [...prev, finalMsg]);
      setPendingText('');
      setPending(false);
    },
    [sessionId]
  );

  // Helper compartilhado: envia mensagem (template OU texto livre), faz
  // optimistic UI, anima a resposta e trata erros. Antes era inline em
  // sendPrompt; agora reusado por sendFreeText pra que o input livre tenha
  // exatamente o mesmo fluxo (strikes, INPUT_BLOCKED handling, etc).
  const sendAndAnimate = async (params: {
    optimisticContent: string;
    optimisticTemplateId?: string;
    apiRequest: SendMessageRequest;
  }) => {
    if (!sessionId || sessionEnded || pending) return;

    const optimisticChild: ChatMessage = {
      id: `tmp-${Date.now()}`,
      session_id: sessionId,
      role: 'child',
      template_id: params.optimisticTemplateId,
      content: params.optimisticContent,
      moderation_status: 'passed',
      created_at: new Date().toISOString(),
    };
    setMessages((prev) => [...prev, optimisticChild]);
    setPending(true);
    setHasInteracted(true);

    try {
      const res = await chatApi.sendMessage(sessionId, params.apiRequest);

      // Se o backend bloqueou o output, conta strike e mostra mensagem amigavel.
      const blocked = res.assistant_message.moderation_status === 'blocked';
      if (blocked) {
        const next = strikes + 1;
        setStrikes(next);
        if (next >= MAX_STRIKES) {
          setSessionEnded(true);
        }
      }
      // Strip markdown da resposta do Claude antes de animar - crianças
      // 6-12 nao precisam ver simbolos **, #, `, etc. CSS whitespace-pre-wrap
      // no ChatBubble preserva quebras de linha geradas por listas/paragrafos.
      const cleanContent = stripMarkdown(res.assistant_message.content);
      await animateAssistant(cleanContent, res);
    } catch (err) {
      const code = getApiErrorCode(err);
      // INPUT_BLOCKED tambem conta strike e mostra refusal amigavel inline.
      if (code === 'INPUT_BLOCKED') {
        const next = strikes + 1;
        setStrikes(next);
        // Marca a mensagem otimista como bloqueada.
        setMessages((prev) =>
          prev.map((m) =>
            m.id === optimisticChild.id ? { ...m, moderation_status: 'blocked' as const } : m
          )
        );
        // Resposta-mascote amigavel.
        const refusal: ChatMessage = {
          id: `mascot-${Date.now()}`,
          session_id: sessionId,
          role: 'assistant',
          content:
            'Vamos escolher outro caminho? Esse pedido nao da pra responder agora. Tente uma sugestao diferente!',
          moderation_status: 'passed',
          created_at: new Date().toISOString(),
        };
        setMessages((prev) => [...prev, refusal]);
        if (next >= MAX_STRIKES) setSessionEnded(true);
        setPending(false);
      } else if (code === 'RATE_LIMITED') {
        toast({
          type: 'warning',
          title: 'Muitas mensagens',
          description: 'Voce ja conversou bastante por aqui. Vamos fazer outra coisa?',
        });
        setPending(false);
      } else {
        toast({
          type: 'error',
          title: 'Algo deu errado',
          description: getApiErrorMessage(err),
        });
        setPending(false);
      }
    }
  };

  // Envia uma sugestao (template) - renderiza slots e delega ao helper.
  const sendPrompt = async (template: PromptTemplate, slots?: Record<string, string>) => {
    let renderedText = template.template;
    if (slots) {
      for (const [k, v] of Object.entries(slots)) {
        renderedText = renderedText.replaceAll(`{{${k}}}`, v);
      }
    } else {
      // Sem slots, removemos os marcadores caso existam.
      renderedText = renderedText.replace(/\{\{[^}]+\}\}/g, '');
    }
    await sendAndAnimate({
      optimisticContent: renderedText.trim() || template.label,
      optimisticTemplateId: template.id,
      apiRequest: { template_id: template.id, slots },
    });
  };

  // Envia texto livre digitado pela crianca (apos a 1a interacao).
  // Backend valida 200 chars + roda blocklist completa (sem bypass).
  const sendFreeText = async () => {
    const text = inputText.trim();
    if (!text) return;
    setInputText('');
    await sendAndAnimate({
      optimisticContent: text,
      apiRequest: { content: text },
    });
  };

  const handleInputKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && !e.shiftKey) {
      e.preventDefault();
      sendFreeText();
    }
  };

  const handleEndSession = async (navigateAfter: boolean) => {
    if (!sessionId) return;
    try {
      await chatApi.endSession(sessionId);
    } catch {
      // Encerrar conversa nunca deve travar a UI.
    }
    if (navigateAfter) {
      router.push(`/play/lesson/${lessonId}/done` as Route);
    }
  };

  if (loadingLesson || !lesson) {
    return (
      <div className="mx-auto max-w-3xl p-6">
        <Card className="animate-pulse p-8">
          <div className="mb-4 h-4 w-64 rounded bg-gray-200" />
          <div className="h-4 w-48 rounded bg-gray-200" />
        </Card>
      </div>
    );
  }

  return (
    <div className="mx-auto flex h-[calc(100vh-8rem)] max-w-3xl flex-col gap-4 p-4">
      {/* Header */}
      <Card className="flex items-center justify-between p-4">
        <Button
          variant="ghost"
          size="sm"
          onClick={() => router.push(`/play/lesson/${lessonId}` as Route)}
        >
          <ArrowLeft className="mr-1 h-4 w-4" />
          Voltar
        </Button>
        <div className="flex flex-1 items-center justify-center gap-2">
          <h1 className="text-lg font-bold text-gray-800">
            Conversar sobre: {lesson.title}
          </h1>
        </div>
        <SafetyStrikes strikes={strikes} max={MAX_STRIKES} />
      </Card>

      {/* Mensagens */}
      <div
        ref={scrollRef}
        className="flex-1 overflow-y-auto rounded-2xl bg-grape-50/50 p-4"
      >
        {messages.length === 0 && !pending ? (
          <div className="flex flex-col items-center gap-3 py-12 text-center">
            <Mascot size="lg" expression="happy" />
            <MascotBubble variant="encouraging">
              Oi! Escolha uma das sugestoes abaixo para comecar a conversar.
            </MascotBubble>
          </div>
        ) : (
          <ChatBubbles messages={messages} pending={pending} pendingText={pendingText} />
        )}
      </div>

      {/* Footer com sugestoes ou tela de fim de sessao */}
      {sessionEnded ? (
        <Card className="flex flex-col items-center gap-3 border-sunset-300 bg-sunset-50 p-6 text-center">
          <Mascot size="md" expression="sleeping" />
          <h2 className="text-lg font-bold text-sunset-900">Conversa encerrada</h2>
          <p className="text-sm text-sunset-800">
            Tivemos {MAX_STRIKES} avisos seguidos, entao por seguranca encerrei a
            conversa. Vamos para a proxima!
          </p>
          <div className="flex gap-2">
            <Button variant="ghost" onClick={() => handleEndSession(false)}>
              <X className="mr-1 h-4 w-4" />
              Sair
            </Button>
            <Button variant="sunny" onClick={() => handleEndSession(true)}>
              Continuar
            </Button>
          </div>
        </Card>
      ) : (
        <Card className="space-y-3 p-4">
          <div className="flex items-center justify-between">
            <p className="text-sm font-medium text-gray-700">
              {hasInteracted ? 'Escreve a tua resposta' : 'Escolha uma sugestao para começar'}
            </p>
            <Button
              variant="ghost"
              size="sm"
              onClick={() => handleEndSession(true)}
              disabled={pending}
            >
              Encerrar conversa
            </Button>
          </div>

          {hasInteracted ? (
            // Modo texto livre: input com contador + botao enviar + Enter.
            // Disabled enquanto Claude esta animando (pending).
            <div className="space-y-2">
              <div className="flex items-center gap-2">
                <input
                  type="text"
                  value={inputText}
                  onChange={(e) => setInputText(e.target.value.slice(0, FREE_TEXT_MAX_LENGTH))}
                  onKeyDown={handleInputKeyDown}
                  placeholder="Escreve aqui a tua resposta... 💬"
                  maxLength={FREE_TEXT_MAX_LENGTH}
                  disabled={pending || !sessionId}
                  className="flex-1 rounded-2xl border-2 border-grape-200 bg-white px-4 py-3 text-base focus:border-grape-400 focus:outline-none focus:ring-2 focus:ring-grape-200 disabled:bg-gray-100 disabled:text-gray-500"
                  autoFocus
                />
                <Button
                  variant="grape"
                  size="kid-icon"
                  onClick={sendFreeText}
                  disabled={pending || !sessionId || !inputText.trim()}
                  aria-label="Enviar mensagem"
                >
                  <Send className="h-5 w-5" />
                </Button>
              </div>
              <div className="flex items-center justify-between text-xs text-gray-500">
                <span>Pressiona Enter pra enviar</span>
                <span
                  className={
                    inputText.length >= FREE_TEXT_MAX_LENGTH
                      ? 'font-bold text-sunset-600'
                      : ''
                  }
                >
                  {inputText.length}/{FREE_TEXT_MAX_LENGTH}
                </span>
              </div>
            </div>
          ) : ageGroup === '6-8' ? (
            <PromptButtonRow
              templates={templates}
              onSelect={(tpl) => sendPrompt(tpl)}
              disabled={pending || !sessionId}
            />
          ) : (
            <PromptSlotEditor
              templates={templates}
              onSubmit={(tpl, slots) => sendPrompt(tpl, slots)}
              disabled={pending || !sessionId}
            />
          )}
        </Card>
      )}
    </div>
  );
}
