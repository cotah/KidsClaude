'use client';

import { useRouter } from 'next/navigation';
import type { Route } from 'next';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { Mascot, MascotBubble } from '@/components/ui/mascot-bubble';

/**
 * Tela "volte amanha" exibida quando a crianca atinge o limite diario.
 * Acionada pelo middleware/heartbeat do backend (HeartbeatResponse.blocked = true).
 */
export default function BlockedPage() {
  const router = useRouter();

  return (
    <div className="mx-auto max-w-2xl p-4">
      <Card className="space-y-6 border-sunset-300 bg-gradient-to-br from-sunset-50 to-grape-50 p-8 text-center">
        <div className="flex justify-center">
          <Mascot size="lg" expression="sleeping" />
        </div>

        <MascotBubble variant="warning">
          <strong>Hora de descansar!</strong> Voce ja aproveitou bastante o
          aprendizado por hoje. Que tal voltar amanha para mais aventuras?
        </MascotBubble>

        <p className="text-sm text-gray-600">
          O limite diario foi definido pelo seu responsavel. Volte amanha para
          continuar de onde parou.
        </p>

        <div className="flex flex-col gap-2 sm:flex-row sm:justify-center">
          <Button variant="outline" onClick={() => router.push('/select' as Route)}>
            Trocar de perfil
          </Button>
          <Button variant="ocean" onClick={() => router.push('/' as Route)}>
            Sair
          </Button>
        </div>
      </Card>
    </div>
  );
}
