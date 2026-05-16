import { Suspense } from 'react';
import { ParentNavbar } from '@/components/parent/parent-navbar';
import { TimezoneInit } from '@/components/timezone-init';

// Rotas do pai dependem do cookie de sessao - nao podem ser pre-renderizadas
export const dynamic = 'force-dynamic';

/**
 * Layout para paginas de pais.
 * Inclui navegacao, seletor de filhos, logout.
 */
export default function ParentLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-gray-50">
      <TimezoneInit />
      <Suspense fallback={<div className="h-16 bg-white border-b animate-pulse" />}>
        <ParentNavbar />
      </Suspense>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        {children}
      </main>
    </div>
  );
}