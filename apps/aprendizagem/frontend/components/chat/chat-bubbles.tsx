import { cn } from '@/lib/utils';
import type { ChatMessage } from '@/types/api';
import { Mascot } from '@/components/ui/mascot-bubble';
import { TypingIndicator } from './typing-indicator';

interface ChatBubblesProps {
  messages: ChatMessage[];
  pending?: boolean;
  // Texto sendo "digitado" caractere por caractere para a resposta atual em curso.
  pendingText?: string;
}

// Renderiza a lista de mensagens da conversa com avatar do mascote para a Claude
// e bolha do lado direito para a crianca.
export function ChatBubbles({ messages, pending, pendingText }: ChatBubblesProps) {
  return (
    <div className="flex flex-col gap-4">
      {messages.map((msg) => (
        <ChatBubble key={msg.id} message={msg} />
      ))}
      {pending && (
        <div className="flex items-end gap-2">
          <Mascot size="sm" expression="thinking" />
          {pendingText ? (
            <div className="max-w-[80%] rounded-2xl rounded-bl-sm border border-grape-200 bg-white px-4 py-3 text-base shadow-sm">
              {pendingText}
              <span className="ml-1 inline-block h-4 w-1 animate-pulse bg-grape-400 align-middle" />
            </div>
          ) : (
            <TypingIndicator />
          )}
        </div>
      )}
    </div>
  );
}

function ChatBubble({ message }: { message: ChatMessage }) {
  const isChild = message.role === 'child';
  const isBlocked = message.moderation_status === 'blocked';

  if (isChild) {
    return (
      <div className="flex justify-end">
        <div
          className={cn(
            'max-w-[80%] rounded-2xl rounded-br-sm px-4 py-3 text-base shadow-sm',
            isBlocked
              ? 'bg-sunset-100 text-sunset-900 border border-sunset-300'
              : 'bg-ocean-500 text-white'
          )}
        >
          {isBlocked ? (
            <em className="text-sm">Mensagem bloqueada pela moderacao.</em>
          ) : (
            message.content
          )}
        </div>
      </div>
    );
  }

  // Mensagem da Claude
  return (
    <div className="flex items-end gap-2">
      <Mascot size="sm" expression={isBlocked ? 'thinking' : 'happy'} />
      <div
        className={cn(
          'max-w-[80%] rounded-2xl rounded-bl-sm px-4 py-3 text-base shadow-sm',
          isBlocked
            ? 'border border-sunset-300 bg-sunset-50 text-sunset-900'
            : 'border border-grape-200 bg-white text-gray-800'
        )}
      >
        {message.content}
      </div>
    </div>
  );
}
