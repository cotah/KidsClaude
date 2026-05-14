'use client';

import * as React from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ArrowLeft } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useToast } from '@/components/ui/toast';
import { authApi } from '@/lib/api/auth';
import useAppStore from '@/lib/store/app-store';
import { getApiErrorMessage } from '@/lib/api/client';

/**
 * Login direto da crianca (username + PIN). Independente do device do pai.
 * Submete em POST /v1/auth/child/login-direct e redireciona pra /play.
 *
 * Mensagem de erro generica ("Utilizador ou PIN incorretos") qualquer que
 * seja a causa, pra nao vazar quais usernames existem.
 */
export default function ChildDirectLoginPage() {
  const router = useRouter();
  const { toast } = useToast();
  const { setCurrentChild, setSession } = useAppStore();

  const [username, setUsername] = React.useState('');
  const [pin, setPin] = React.useState('');
  const [isSubmitting, setIsSubmitting] = React.useState(false);
  const [errorMessage, setErrorMessage] = React.useState<string | null>(null);

  const handlePinDigit = (digit: string) => {
    setErrorMessage(null);
    setPin((prev) => (prev.length < 4 ? prev + digit : prev));
  };

  const handlePinBackspace = () => {
    setErrorMessage(null);
    setPin((prev) => prev.slice(0, -1));
  };

  const isReady = username.trim().length >= 3 && pin.length === 4 && !isSubmitting;

  const handleSubmit = async () => {
    if (!isReady) return;

    setIsSubmitting(true);
    setErrorMessage(null);

    try {
      const response = await authApi.childLoginDirect({
        username: username.trim().toLowerCase(),
        pin,
      });

      setCurrentChild(response.child);
      setSession({
        type: 'child',
        token: response.access_token,
        expires_at: Date.now() + response.expires_in * 1000,
      });

      toast({
        type: 'success',
        title: `Oi, ${response.child.name}!`,
        description: 'Pronto para aprender?',
      });

      router.push('/play');
    } catch (error: any) {
      // Generico em qualquer 401/404. 429 = rate limit.
      let message = 'Utilizador ou PIN incorretos';
      if (error?.status === 429) {
        message = 'Demasiadas tentativas. Tenta novamente em alguns minutos.';
      } else if (error?.status >= 500) {
        message = 'Erro no servidor. Tenta novamente em instantes.';
      } else {
        // Tenta extrair mensagem do backend; cai no generico se nao houver.
        const fromApi = getApiErrorMessage(error);
        if (fromApi && fromApi !== 'Erro desconhecido') message = fromApi;
      }
      setErrorMessage(message);
      setPin('');
    } finally {
      setIsSubmitting(false);
    }
  };

  // Submit automatico quando completar os 4 digitos do PIN.
  React.useEffect(() => {
    if (pin.length === 4 && username.trim().length >= 3 && !isSubmitting) {
      handleSubmit();
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [pin]);

  return (
    <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center p-4">
      <div className="w-full max-w-md space-y-6">
        <div className="text-center space-y-2">
          <div className="text-6xl">🤖</div>
          <h1 className="text-kid-2xl font-bold text-gray-800">Bem-vindo!</h1>
          <p className="text-kid-base text-gray-600">
            Entra com o teu nome de utilizador e PIN.
          </p>
        </div>

        <div className="bg-white rounded-kid-lg shadow-lg p-6 space-y-6">
          {/* Username */}
          <div>
            <label htmlFor="username" className="block text-sm font-medium text-gray-700 mb-2">
              Nome de utilizador
            </label>
            <input
              id="username"
              type="text"
              autoComplete="username"
              autoCapitalize="none"
              autoCorrect="off"
              spellCheck={false}
              value={username}
              onChange={(e) => {
                setErrorMessage(null);
                setUsername(e.target.value);
              }}
              className="w-full px-4 py-3 text-kid-base border-2 border-sunny-200 rounded-kid focus:outline-none focus:border-sunny-500 focus:ring-2 focus:ring-sunny-200"
              placeholder="ex: valentina2026"
              disabled={isSubmitting}
            />
            <p className="mt-1 text-xs text-gray-500">
              Letras minúsculas, números e hífens. Mínimo 3 caracteres.
            </p>
          </div>

          {/* PIN display */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-2">PIN</label>
            <div className="flex justify-center space-x-3 mb-4">
              {Array.from({ length: 4 }).map((_, index) => (
                <div
                  key={index}
                  className="w-12 h-12 rounded-kid border-2 border-sunny-300 bg-white flex items-center justify-center text-kid-lg font-bold"
                >
                  {pin.length > index ? '●' : ''}
                </div>
              ))}
            </div>

            {/* Teclado numerico */}
            <div className="grid grid-cols-3 gap-3 max-w-xs mx-auto">
              {Array.from({ length: 9 }, (_, i) => i + 1).map((digit) => (
                <Button
                  key={digit}
                  type="button"
                  variant="outline"
                  size="kid-icon-lg"
                  className="text-kid-xl font-bold"
                  onClick={() => handlePinDigit(digit.toString())}
                  disabled={isSubmitting}
                >
                  {digit}
                </Button>
              ))}
              <div /> {/* espaco vazio pra alinhar 0 no centro */}
              <Button
                type="button"
                variant="outline"
                size="kid-icon-lg"
                className="text-kid-xl font-bold"
                onClick={() => handlePinDigit('0')}
                disabled={isSubmitting}
              >
                0
              </Button>
              <Button
                type="button"
                variant="outline"
                size="kid-icon-lg"
                onClick={handlePinBackspace}
                disabled={isSubmitting || pin.length === 0}
              >
                ⌫
              </Button>
            </div>
          </div>

          {/* Mensagem de erro */}
          {errorMessage && (
            <div className="bg-red-50 border border-red-200 rounded-kid p-3 text-center">
              <p className="text-sm font-medium text-red-700">{errorMessage}</p>
            </div>
          )}

          {/* Botao manual de submit (caso nao queira esperar o auto-submit) */}
          <Button
            variant="sunny"
            size="kid-default"
            className="w-full"
            onClick={handleSubmit}
            disabled={!isReady}
          >
            {isSubmitting ? 'A entrar...' : 'Entrar'}
          </Button>
        </div>

        {/* Link pro login do pai */}
        <div className="text-center">
          <Link
            href="/login"
            className="inline-flex items-center text-sm text-gray-600 hover:text-gray-900 underline"
          >
            <ArrowLeft className="w-4 h-4 mr-1" />
            És pai/responsável? Entra aqui
          </Link>
        </div>
      </div>
    </div>
  );
}
