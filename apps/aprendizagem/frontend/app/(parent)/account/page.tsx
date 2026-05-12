'use client';

import { useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { LogOut, Mail, User } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import { useToast } from '@/components/ui/toast';
import { authApi } from '@/lib/api/auth';
import { getApiErrorMessage } from '@/lib/api/client';
import type { Route } from 'next';

/**
 * Pagina de conta do responsavel: exibe dados do perfil e oferece logout.
 * Endpoints adicionais (trocar senha, excluir conta) ficam para fase 2.
 */
export default function AccountPage() {
  const router = useRouter();
  const { toast } = useToast();

  const { data: parent, isLoading } = useQuery({
    queryKey: ['parent-profile'],
    queryFn: () => authApi.getParentProfile(),
  });

  const handleLogout = async () => {
    try {
      await authApi.parentLogout();
      router.push('/' as Route);
    } catch (err) {
      toast({
        type: 'error',
        title: 'Erro ao sair',
        description: getApiErrorMessage(err),
      });
    }
  };

  return (
    <div className="mx-auto max-w-2xl space-y-6">
      <div>
        <h1 className="text-2xl font-bold text-gray-900">Minha conta</h1>
        <p className="text-gray-600">
          Dados do seu perfil de responsavel. Voce pode encerrar a sessao aqui.
        </p>
      </div>

      <Card className="space-y-4 p-6">
        {isLoading || !parent ? (
          <div className="space-y-3">
            <div className="h-4 w-48 animate-pulse rounded bg-gray-200" />
            <div className="h-4 w-64 animate-pulse rounded bg-gray-200" />
          </div>
        ) : (
          <>
            <div className="flex items-center gap-3">
              <User className="h-5 w-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Nome</p>
                <p className="font-medium text-gray-900">
                  {parent.display_name || 'Sem nome'}
                </p>
              </div>
            </div>
            <div className="flex items-center gap-3">
              <Mail className="h-5 w-5 text-gray-400" />
              <div>
                <p className="text-sm text-gray-500">Email</p>
                <p className="font-medium text-gray-900">{parent.email}</p>
              </div>
            </div>
          </>
        )}
      </Card>

      <Card className="space-y-3 p-6">
        <h2 className="text-base font-semibold text-gray-900">Sessao</h2>
        <p className="text-sm text-gray-600">
          Encerrar sua sessao remove os cookies de autenticacao deste navegador.
        </p>
        <Button
          variant="outline"
          onClick={handleLogout}
          className="border-red-300 text-red-600 hover:bg-red-50"
        >
          <LogOut className="mr-2 h-4 w-4" />
          Sair da conta
        </Button>
      </Card>
    </div>
  );
}
