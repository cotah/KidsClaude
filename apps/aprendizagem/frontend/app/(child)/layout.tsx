import { Suspense } from 'react';
import { ChildNavbar } from '@/components/child/child-navbar';
import { TimezoneInit } from '@/components/timezone-init';

// Rotas da crianca dependem do cookie de sessao - nao podem ser pre-renderizadas
export const dynamic = 'force-dynamic';

/**
 * Layout para paginas de criancas.
 * Inclui mascote, barra de XP, chama de sequencia, botao de saida.
 */
export default function ChildLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-gradient-to-br from-purple-50 via-pink-50 to-blue-50">
      <TimezoneInit />
      <Suspense fallback={<div className="h-16 bg-purple-500 animate-pulse" />}>
        <ChildNavbar />
      </Suspense>

      <main className="max-w-6xl mx-auto px-4 py-6">
        {children}
      </main>
    </div>
  );
}