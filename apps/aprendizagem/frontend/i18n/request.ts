import { cookies } from 'next/headers';
import { getRequestConfig } from 'next-intl/server';

/**
 * Configuracao de i18n: locale lido do cookie 'locale' setado pelo
 * LanguageSwitcher. Default = 'en' (decisao do produto).
 *
 * Cookie-based em vez de URL routing (/en/login, /pt/login) preserva
 * todas as rotas existentes - middleware de auth, BFF proxy, internal
 * links, bookmarks. Trocar idioma = setar cookie + router.refresh().
 */
const SUPPORTED_LOCALES = ['en', 'pt'] as const;
type Locale = (typeof SUPPORTED_LOCALES)[number];
const DEFAULT_LOCALE: Locale = 'en';

export default getRequestConfig(async () => {
  const cookieStore = await cookies();
  const cookieValue = cookieStore.get('locale')?.value;
  const locale: Locale = SUPPORTED_LOCALES.includes(cookieValue as Locale)
    ? (cookieValue as Locale)
    : DEFAULT_LOCALE;

  return {
    locale,
    messages: (await import(`../messages/${locale}.json`)).default,
  };
});
