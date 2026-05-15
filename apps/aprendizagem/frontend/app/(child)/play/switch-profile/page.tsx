import { redirect } from 'next/navigation';
import { cookies } from 'next/headers';
import { config } from '@/lib/config';

/**
 * Trocar perfil de criança.
 *
 * Decide pra onde mandar baseado em quem ta logado:
 *  - tem cookie de pai -> /select (lista todos os filhos da familia)
 *  - so' cookie de crianca (login direto via /crianca) -> /crianca
 *    (re-login com username + PIN de outro perfil)
 *
 * Server Component: le cookies via next/headers e redireciona antes
 * de qualquer render. Sem client roundtrip.
 */
export default async function SwitchProfilePage() {
  const cookieStore = await cookies();
  const hasParent = !!cookieStore.get(config.auth.parentCookieName)?.value;
  redirect(hasParent ? '/select' : '/crianca');
}
