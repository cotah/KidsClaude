'use client';

import * as React from 'react';
import { useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import { useTranslations } from 'next-intl';
import { childrenApi, authApi } from '@/lib/api';
import { AvatarDisplay } from '@/components/avatar-picker';
import { KidCard } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { LanguageSwitcher } from '@/components/ui/language-switcher';
import { useToast } from '@/components/ui/toast';
import useAppStore from '@/lib/store/app-store';
import type { Child } from '@/types/api';

/**
 * Página de seleção de perfil da criança - conforme spec seção 8.4
 */
export default function SelectProfilePage() {
  const t = useTranslations('select');
  const router = useRouter();
  const { toast } = useToast();
  const { setCurrentChild, setSession } = useAppStore();

  const [selectedChild, setSelectedChild] = React.useState<Child | null>(null);
  const [pin, setPin] = React.useState('');
  const [isLoading, setIsLoading] = React.useState(false);
  const [pinAttempts, setPinAttempts] = React.useState<Record<string, number>>({});

  // Buscar lista de filhos
  const { data: children, isLoading: isLoadingChildren } = useQuery({
    queryKey: ['children'],
    queryFn: childrenApi.list,
  });

  const handleChildSelect = (child: Child) => {
    setSelectedChild(child);
    setPin('');

    // Se nao tem PIN, fazer login direto
    if (!child.pin_set) {
      handleLogin(child, undefined);
    }
  };

  const handleLogin = async (child: Child, pin?: string) => {
    setIsLoading(true);

    try {
      const response = await authApi.childLogin({
        child_id: child.id,
        pin,
      });

      // Salvar dados da crianca; o token ja foi armazenado em cookie httpOnly por childLogin
      setCurrentChild(response.child);
      setSession({
        type: 'child',
        token: response.access_token,
        expires_at: Date.now() + response.expires_in * 1000,
      });

      toast({
        type: 'success',
        title: t('toast_welcome_title', { name: child.name }),
        description: t('toast_welcome_desc'),
      });

      router.push('/play');
    } catch (error: any) {
      console.error('Child login error:', error);

      if (error?.status === 401) {
        // PIN incorreto
        const attempts = (pinAttempts[child.id] || 0) + 1;
        setPinAttempts(prev => ({ ...prev, [child.id]: attempts }));

        if (attempts >= 3) {
          toast({
            type: 'error',
            title: t('toast_too_many_title'),
            description: t('toast_too_many_desc'),
          });
          setSelectedChild(null);
        } else {
          toast({
            type: 'error',
            title: t('toast_pin_wrong_title'),
            description: t('toast_pin_wrong_desc', { remaining: 3 - attempts }),
          });
        }
        setPin('');
      } else if (error?.status === 423) {
        toast({
          type: 'warning',
          title: t('toast_blocked_title'),
          description: t('toast_blocked_desc'),
        });
        setSelectedChild(null);
      } else {
        toast({
          type: 'error',
          title: t('toast_unexpected_title'),
          description: t('toast_unexpected_desc'),
        });
      }
    } finally {
      setIsLoading(false);
    }
  };

  const handlePinDigit = (digit: string) => {
    if (pin.length < 4) {
      const newPin = pin + digit;
      setPin(newPin);

      // Fazer login automaticamente quando completar 4 dígitos
      if (newPin.length === 4 && selectedChild) {
        handleLogin(selectedChild, newPin);
      }
    }
  };

  const handlePinBackspace = () => {
    setPin(prev => prev.slice(0, -1));
  };

  if (isLoadingChildren) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="text-6xl animate-spin">⭐</div>
          <p className="text-kid-lg font-medium text-gray-700">{t('loading')}</p>
        </div>
      </div>
    );
  }

  if (!children || children.length === 0) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 flex items-center justify-center p-4">
        <div className="text-center space-y-6">
          <div className="text-8xl">👨‍👩‍👧‍👦</div>
          <div className="space-y-2">
            <h1 className="text-kid-3xl font-bold text-gray-800">{t('no_profiles_title')}</h1>
            <p className="text-kid-base text-gray-600">{t('no_profiles_body')}</p>
          </div>
          <Button variant="sunny" size="kid-lg" asChild>
            <a href="/dashboard">{t('back')}</a>
          </Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-sunny-100 to-mint-100 p-4">
      <div className="container mx-auto max-w-4xl py-8">
        <div className="flex justify-end mb-4">
          <LanguageSwitcher />
        </div>
        {!selectedChild ? (
          <div className="text-center space-y-8">
            <div className="space-y-4">
              <h1 className="text-kid-3xl font-bold text-gray-800">{t('title_who')}</h1>
              <p className="text-kid-lg text-gray-600">{t('subtitle_tap')}</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 max-w-3xl mx-auto">
              {children.map((child) => {
                const isBlocked = (pinAttempts[child.id] || 0) >= 3;

                return (
                  <KidCard
                    key={child.id}
                    colorScheme="sunny"
                    className={cn(
                      'cursor-pointer transition-all duration-200 hover:scale-105 p-8 text-center space-y-4',
                      isBlocked && 'opacity-50 cursor-not-allowed'
                    )}
                    onClick={() => !isBlocked && handleChildSelect(child)}
                  >
                    <AvatarDisplay
                      avatarId={child.avatar_id}
                      size="xl"
                      className="mx-auto"
                    />
                    <div className="space-y-2">
                      <h2 className="text-kid-xl font-bold text-gray-800">
                        {child.name}
                      </h2>
                      <div className="text-kid-base text-gray-600">
                        {t('level_xp', { level: child.level, xp: child.xp })}
                      </div>
                      {child.streak_days > 0 && (
                        <div className="flex items-center justify-center space-x-1 text-kid-sm text-sunset-600">
                          <span>🔥</span>
                          <span>{t('streak_days', { days: child.streak_days })}</span>
                        </div>
                      )}
                      {isBlocked && (
                        <div className="text-kid-sm text-red-600 font-medium">
                          {t('blocked_temp')}
                        </div>
                      )}
                    </div>
                  </KidCard>
                );
              })}
            </div>

            <div className="pt-8">
              <Button variant="outline" size="kid-default" asChild>
                <a href="/dashboard">{t('back_to_panel')}</a>
              </Button>
            </div>
          </div>
        ) : (
          <div className="text-center space-y-8 max-w-md mx-auto">
            <div className="space-y-4">
              <AvatarDisplay
                avatarId={selectedChild.avatar_id}
                size="xl"
                className="mx-auto"
              />
              <h1 className="text-kid-2xl font-bold text-gray-800">
                {t('hi_name', { name: selectedChild.name })}
              </h1>
              <p className="text-kid-base text-gray-600">{t('type_pin')}</p>
            </div>

            {/* Exibição do PIN */}
            <div className="flex justify-center space-x-4">
              {Array.from({ length: 4 }).map((_, index) => (
                <div
                  key={index}
                  className="w-12 h-12 rounded-kid border-2 border-sunny-300 bg-white flex items-center justify-center text-kid-lg font-bold"
                >
                  {pin.length > index ? '●' : ''}
                </div>
              ))}
            </div>

            {/* Teclado numérico */}
            <div className="grid grid-cols-3 gap-4 max-w-xs mx-auto">
              {Array.from({ length: 9 }, (_, i) => i + 1).map((digit) => (
                <Button
                  key={digit}
                  variant="outline"
                  size="kid-icon-lg"
                  className="text-kid-xl font-bold"
                  onClick={() => handlePinDigit(digit.toString())}
                  disabled={isLoading}
                >
                  {digit}
                </Button>
              ))}
              <Button
                variant="outline"
                size="kid-icon-lg"
                onClick={() => setSelectedChild(null)}
                disabled={isLoading}
              >
                <ArrowLeft className="w-6 h-6" />
              </Button>
              <Button
                variant="outline"
                size="kid-icon-lg"
                className="text-kid-xl font-bold"
                onClick={() => handlePinDigit('0')}
                disabled={isLoading}
              >
                0
              </Button>
              <Button
                variant="outline"
                size="kid-icon-lg"
                onClick={handlePinBackspace}
                disabled={isLoading || pin.length === 0}
              >
                ⌫
              </Button>
            </div>

            {isLoading && (
              <div className="text-kid-base text-gray-600">{t('verifying')}</div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

// Helper para importar ícone
import { ArrowLeft } from 'lucide-react';
import { cn } from '@/lib/utils';