'use client';

import { useEffect } from 'react';

/**
 * Seta o cookie 'tz' com o timezone IANA do navegador (Intl). O BFF
 * proxy le esse cookie e propaga via header X-Timezone para o backend
 * computar datas usando a zona do usuario (em vez de UTC ou America/
 * Sao_Paulo hardcoded).
 *
 * Idempotente: roda no mount de cada visita e atualiza se o usuario
 * mudou de timezone (viagem, mudanca de DST). max-age=1ano.
 */
export function TimezoneInit() {
  useEffect(() => {
    try {
      const tz = Intl.DateTimeFormat().resolvedOptions().timeZone;
      if (!tz) return;
      document.cookie = `tz=${encodeURIComponent(tz)}; path=/; max-age=31536000; samesite=lax`;
    } catch {
      // Intl indisponivel (improvavel em browser moderno) - sem cookie,
      // backend cai no fallback de settings.timezone.
    }
  }, []);

  return null;
}
