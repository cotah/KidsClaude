/**
 * Helpers pra texto vindo do Claude (markdown). Crianças 6-12 nao precisam
 * lidar com sintaxe **bold**, # header, `code`, etc. - melhor mostrar
 * texto limpo com quebras de linha preservadas.
 *
 * Estrategia: strip dos marcadores mantendo o texto e a estrutura. Listas
 * viram bullets visuais (• item, 1. item) e quebras de linha sao mantidas
 * pra render via CSS whitespace-pre-wrap.
 */

export function stripMarkdown(text: string): string {
  if (!text) return '';

  return (
    text
      // Bold/italic em ordem (mais especifico primeiro pra evitar conflitos):
      // **bold** e __bold__ -> bold
      .replace(/\*\*([^*\n]+)\*\*/g, '$1')
      .replace(/__([^_\n]+)__/g, '$1')
      // *italic* e _italic_ -> italic (cuidado: nao consome em palavras como log_in)
      .replace(/(?<![A-Za-z0-9])\*([^*\n]+)\*(?![A-Za-z0-9])/g, '$1')
      .replace(/(?<![A-Za-z0-9])_([^_\n]+)_(?![A-Za-z0-9])/g, '$1')
      // Headers # ## ### -> texto limpo
      .replace(/^#{1,6}\s+/gm, '')
      // Inline code `foo` -> foo
      .replace(/`([^`\n]+)`/g, '$1')
      // Bloco de codigo ``` ... ``` -> texto sem cercas (preserva conteudo)
      .replace(/```[a-zA-Z]*\n?([\s\S]*?)```/g, '$1')
      // Links [texto](url) -> texto
      .replace(/\[([^\]]+)\]\([^)]+\)/g, '$1')
      // Listas com - * + viram bullet • mantendo o ident
      .replace(/^(\s*)[-*+]\s+/gm, '$1• ')
      // Listas numeradas mantem o numero, normaliza espaco
      .replace(/^(\s*)(\d+)\.\s+/gm, '$1$2. ')
      // Blockquote > -> sem o sinal
      .replace(/^>\s+/gm, '')
      // Limpa multiplas linhas em branco (3+ -> 2)
      .replace(/\n{3,}/g, '\n\n')
      .trim()
  );
}
