import { Button } from '@/components/ui/button';
import type { PromptTemplate } from '@/types/api';

interface PromptButtonRowProps {
  templates: PromptTemplate[];
  onSelect: (template: PromptTemplate) => void;
  disabled?: boolean;
}

// Modo crianca pequena (6-8 anos): apenas botoes fechados, sem digitar.
// Cada botao envia o template direto, sem slots editaveis.
export function PromptButtonRow({ templates, onSelect, disabled }: PromptButtonRowProps) {
  if (templates.length === 0) {
    return (
      <p className="text-center text-base text-gray-500">
        Nenhuma sugestao disponivel para esta licao.
      </p>
    );
  }

  return (
    <div className="grid grid-cols-1 gap-3 sm:grid-cols-2">
      {templates.map((tpl) => (
        <Button
          key={tpl.id}
          variant="sunny"
          size="kid-lg"
          onClick={() => onSelect(tpl)}
          disabled={disabled}
          className="h-auto whitespace-normal py-4 text-left text-base font-semibold leading-snug"
        >
          {tpl.label}
        </Button>
      ))}
    </div>
  );
}
