import type { Metadata, Viewport } from 'next';
import { ReactQueryProvider } from '@/components/providers/react-query-provider';
import { ToastContainer } from '@/components/ui/toast';
import './globals.css';

export const metadata: Metadata = {
  title: 'Aprendizagem - Aprenda IA de Forma Divertida',
  description: 'Ensine suas criancas a usar assistentes de IA de forma segura e educativa.',
  keywords: 'educacao, IA, criancas, Claude, inteligencia artificial, aprendizado',
  authors: [{ name: 'Equipe Aprendizagem' }],
  openGraph: {
    title: 'Aprendizagem - Aprenda IA de Forma Divertida',
    description: 'Ensine suas criancas a usar assistentes de IA de forma segura e educativa.',
    type: 'website',
    locale: 'pt_BR',
  },
  robots: {
    index: true,
    follow: true,
  },
};

// Viewport agora vai em export proprio conforme Next.js 16
export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  maximumScale: 1,
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="pt-BR" className="h-full">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
      </head>
      <body className="min-h-full bg-background font-sans antialiased">
        <ReactQueryProvider>
          {children}
          <ToastContainer />
        </ReactQueryProvider>
      </body>
    </html>
  );
}