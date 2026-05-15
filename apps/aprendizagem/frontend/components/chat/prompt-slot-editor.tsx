'use client';

import { useState, useMemo } from 'react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import type { PromptTemplate } from '@/types/api';

interface PromptSlotEditorProps {
  templates: PromptTemplate[];
  onSubmit: (template: PromptTemplate, slots: Record<string, string>) => void;
  disabled?: boolean;
}

// Modo crianca maior (9-12 anos): templates com slots editaveis.
// Cada slot tem regex de chars permitidos e tamanho maximo (validados antes do envio).
export function PromptSlotEditor({ templates, onSubmit, disabled }: PromptSlotEditorProps) {
  const [selected, setSelected] = useState<PromptTemplate | null>(null);
  const [slotValues, setSlotValues] = useState<Record<string, string>>({});
  const [error, setError] = useState<string | null>(null);

  // Helper: templates com slots NULL ou [] sao "fechados" (clicar = enviar).
  // Migration 005/007 cria todos os 48 templates com slots=NULL.
  const hasEditableSlots = (tpl: PromptTemplate | null): boolean =>
    !!tpl?.slots && tpl.slots.length > 0;

  // Pre-visualizacao do prompt com os slots substituidos.
  const preview = useMemo(() => {
    if (!selected) return '';
    let text = selected.template;
    for (const slot of selected.slots ?? []) {
      const value = slotValues[slot.name] ?? '';
      text = text.replaceAll(`{{${slot.name}}}`, value || `___${slot.name}___`);
    }
    return text;
  }, [selected, slotValues]);

  const handleSelect = (tpl: PromptTemplate) => {
    // Template fechado (sem slots): submete direto, sem abrir o editor.
    // UX igual ao PromptButtonRow das criancas 6-8.
    if (!hasEditableSlots(tpl)) {
      onSubmit(tpl, {});
      return;
    }
    setSelected(tpl);
    setSlotValues({});
    setError(null);
  };

  const handleSubmit = () => {
    if (!selected) return;
    // Valida slots antes de enviar - confere comprimento e caracteres permitidos.
    for (const slot of selected.slots ?? []) {
      const value = (slotValues[slot.name] ?? '').trim();
      if (!value) {
        setError(`Preencha o campo "${slot.name}" para enviar.`);
        return;
      }
      if (value.length > slot.max_length) {
        setError(`O campo "${slot.name}" tem mais de ${slot.max_length} caracteres.`);
        return;
      }
      try {
        const re = new RegExp(slot.allowed_chars);
        if (!re.test(value)) {
          setError(`O campo "${slot.name}" contem caracteres nao permitidos.`);
          return;
        }
      } catch {
        // Se a regex do backend for invalida, deixa passar - servidor revalida.
      }
    }
    setError(null);
    onSubmit(selected, slotValues);
    setSelected(null);
    setSlotValues({});
  };

  if (templates.length === 0) {
    return (
      <p className="text-center text-base text-gray-500">
        Nenhuma sugestao disponivel para esta licao.
      </p>
    );
  }

  if (!selected) {
    return (
      <div className="grid grid-cols-1 gap-2 sm:grid-cols-2">
        {templates.map((tpl) => (
          <Button
            key={tpl.id}
            variant="ocean"
            onClick={() => handleSelect(tpl)}
            disabled={disabled}
            className="h-auto whitespace-normal py-3 text-left text-base font-semibold leading-snug"
          >
            {tpl.label}
          </Button>
        ))}
      </div>
    );
  }

  return (
    <Card className="space-y-4 p-4">
      <header className="flex items-start justify-between gap-4">
        <div>
          <h3 className="text-lg font-bold text-gray-800">{selected.label}</h3>
          <p className="text-sm text-gray-500">Preencha as palavras destacadas:</p>
        </div>
        <Button variant="ghost" size="sm" onClick={() => setSelected(null)}>
          Trocar sugestao
        </Button>
      </header>

      <div className="space-y-3">
        {(selected.slots ?? []).map((slot) => (
          <div key={slot.name} className="space-y-1">
            <label
              htmlFor={`slot-${slot.name}`}
              className="block text-sm font-medium text-gray-700"
            >
              {slot.name}
            </label>
            <input
              id={`slot-${slot.name}`}
              type="text"
              maxLength={slot.max_length}
              value={slotValues[slot.name] ?? ''}
              onChange={(e) =>
                setSlotValues({ ...slotValues, [slot.name]: e.target.value })
              }
              className="w-full rounded-md border border-gray-300 px-3 py-2 text-base focus:border-ocean-400 focus:outline-none focus:ring-2 focus:ring-ocean-200"
              disabled={disabled}
            />
            <p className="text-xs text-gray-500">
              Maximo de {slot.max_length} caracteres
            </p>
          </div>
        ))}
      </div>

      <div className="rounded-lg border border-grape-200 bg-grape-50 p-3 text-sm">
        <p className="mb-1 font-medium text-grape-700">Como vai chegar:</p>
        <p className="whitespace-pre-wrap text-grape-900">{preview}</p>
      </div>

      {error && (
        <p className="text-sm font-medium text-red-600" role="alert">
          {error}
        </p>
      )}

      <Button
        variant="ocean"
        size="lg"
        onClick={handleSubmit}
        disabled={disabled}
        className="w-full"
      >
        Enviar para Claude
      </Button>
    </Card>
  );
}
