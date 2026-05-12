// Indicador de "digitando" com tres bolinhas pulsando.
export function TypingIndicator() {
  return (
    <div
      className="inline-flex items-center gap-1 rounded-full bg-grape-50 px-4 py-3"
      aria-label="Claude esta pensando"
      role="status"
    >
      <span className="sr-only">Claude esta pensando...</span>
      {[0, 1, 2].map((i) => (
        <span
          key={i}
          className="block h-2 w-2 animate-bounce rounded-full bg-grape-400"
          style={{ animationDelay: `${i * 150}ms` }}
        />
      ))}
    </div>
  );
}
