'use client';

import { useLocale, useTranslations } from 'next-intl';
import { useRouter } from 'next/navigation';
import { useTransition } from 'react';
import { Globe } from 'lucide-react';

/**
 * Switcher de idioma cookie-based. Seta cookie 'locale' (1 ano) e
 * router.refresh() pra que o layout resolva o novo locale + carregue
 * messages corretas. URLs nao mudam (sem prefixo /en, /pt).
 *
 * Suporta 2 locales por agora: en (default), pt.
 */
const LOCALES = ['en', 'pt'] as const;
type Locale = (typeof LOCALES)[number];

export function LanguageSwitcher() {
  const t = useTranslations('language');
  const currentLocale = useLocale() as Locale;
  const router = useRouter();
  const [isPending, startTransition] = useTransition();

  const switchTo = (locale: Locale) => {
    if (locale === currentLocale || isPending) return;
    // Cookie max-age 1 ano. Path / pra alcancar todas as rotas.
    document.cookie = `locale=${locale}; path=/; max-age=31536000; samesite=lax`;
    startTransition(() => {
      router.refresh();
    });
  };

  return (
    <div
      className="inline-flex items-center gap-1 rounded-full border border-gray-200 bg-white px-2 py-1 text-xs"
      aria-label={t('label')}
    >
      <Globe className="h-3 w-3 text-gray-500" />
      {LOCALES.map((loc) => (
        <button
          key={loc}
          type="button"
          onClick={() => switchTo(loc)}
          disabled={isPending}
          className={
            loc === currentLocale
              ? 'rounded-full bg-grape-500 px-2 py-0.5 font-bold uppercase text-white'
              : 'rounded-full px-2 py-0.5 uppercase text-gray-600 hover:bg-gray-100'
          }
          aria-current={loc === currentLocale ? 'true' : undefined}
        >
          {loc}
        </button>
      ))}
    </div>
  );
}
