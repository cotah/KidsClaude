import type { Metadata, Viewport } from 'next';
import { NextIntlClientProvider } from 'next-intl';
import { getLocale, getMessages } from 'next-intl/server';
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

export default async function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // Locale + messages vem do i18n/request.ts (cookie 'locale', default 'en').
  // Layout ficou async pra resolver isso via getLocale/getMessages.
  const locale = await getLocale();
  const messages = await getMessages();

  return (
    <html lang={locale} className="h-full">
      <head>
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="" />
      </head>
      <body className="min-h-full bg-background font-sans antialiased">
        <NextIntlClientProvider locale={locale} messages={messages}>
          <ReactQueryProvider>
            {children}
            <ToastContainer />
          </ReactQueryProvider>
        </NextIntlClientProvider>
      </body>
    </html>
  );
}