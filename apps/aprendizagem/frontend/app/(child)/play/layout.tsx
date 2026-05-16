'use client';

import { useHeartbeat } from '@/hooks/useHeartbeat';

/**
 * Layout das rotas /play/* - existe somente para montar o useHeartbeat
 * enquanto a crianca esta navegando pela area de jogo. Layout pai
 * (app/(child)/layout.tsx) ja' cuida de navbar/wrapper visual, entao
 * aqui so' passamos children adiante.
 */
export default function PlayLayout({ children }: { children: React.ReactNode }) {
  useHeartbeat();
  return <>{children}</>;
}
