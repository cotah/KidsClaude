'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useQuery } from '@tanstack/react-query';
import {
  User,
  LogOut,
  ChevronDown,
  Settings,
  Shield,
  Home
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import { authApi } from '@/lib/api/auth';
import { childrenApi } from '@/lib/api/children';
import { getApiErrorMessage } from '@/lib/api/client';

/**
 * Navbar para pais com seletor de filhos e navegação.
 */
export function ParentNavbar() {
  const router = useRouter();
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [isLoggingOut, setIsLoggingOut] = useState(false);

  // Dados do pai
  const { data: parent } = useQuery({
    queryKey: ['parent-profile'],
    queryFn: () => authApi.getParentProfile(),
  });

  // Lista de filhos para seletor
  const { data: children = [] } = useQuery({
    queryKey: ['children'],
    queryFn: () => childrenApi.list(),
  });

  const handleLogout = async () => {
    setIsLoggingOut(true);
    try {
      await authApi.parentLogout();
      router.push('/');
    } catch (error) {
      console.error('Erro no logout:', getApiErrorMessage(error));
      // Redirecionar mesmo se der erro - logout deve sempre funcionar
      router.push('/');
    }
  };

  return (
    <nav className="bg-white border-b border-gray-200 shadow-sm">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between h-16">
          {/* Logo e navegação principal */}
          <div className="flex items-center space-x-8">
            <Link
              href="/dashboard"
              className="flex items-center space-x-2"
            >
              <div className="w-8 h-8 bg-gradient-to-br from-purple-500 to-pink-500 rounded-lg flex items-center justify-center">
                <span className="text-white font-bold text-lg">A</span>
              </div>
              <span className="text-xl font-bold text-gray-900">
                Aprendizagem
              </span>
            </Link>

            {/* Links de navegação */}
            <div className="hidden md:flex items-center space-x-6">
              <Link
                href="/dashboard"
                className="flex items-center space-x-1 text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
              >
                <Home className="w-4 h-4" />
                <span>Dashboard</span>
              </Link>

              {/* Seletor de filhos */}
              {children.length > 0 && (
                <div className="relative">
                  <button
                    onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                    className="flex items-center space-x-1 text-gray-700 hover:text-gray-900 px-3 py-2 rounded-md text-sm font-medium"
                  >
                    <User className="w-4 h-4" />
                    <span>Filhos ({children.length})</span>
                    <ChevronDown className="w-4 h-4" />
                  </button>

                  {isDropdownOpen && (
                    <div className="absolute top-full left-0 mt-1 w-64 bg-white border border-gray-200 rounded-md shadow-lg z-50">
                      <div className="py-1">
                        {children.map((child) => (
                          <Link
                            key={child.id}
                            href={`/children/${child.id}`}
                            onClick={() => setIsDropdownOpen(false)}
                            className="flex items-center justify-between px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                          >
                            <div className="flex items-center space-x-3">
                              <div className="w-8 h-8 bg-gradient-to-br from-blue-400 to-green-400 rounded-full flex items-center justify-center">
                                <span className="text-white text-xs font-medium">
                                  {child.name.charAt(0).toUpperCase()}
                                </span>
                              </div>
                              <div>
                                <p className="font-medium">{child.name}</p>
                                <p className="text-xs text-gray-500">
                                  {child.age} anos • Nível {child.level}
                                </p>
                              </div>
                            </div>
                            <div className="flex items-center space-x-1">
                              <Badge variant="outline" className="text-xs">
                                {child.xp} XP
                              </Badge>
                              {child.streak_days > 0 && (
                                <span className="text-orange-500 text-xs">
                                  🔥{child.streak_days}
                                </span>
                              )}
                            </div>
                          </Link>
                        ))}
                        <div className="border-t border-gray-100 pt-1">
                          <Link
                            href="/children/new"
                            onClick={() => setIsDropdownOpen(false)}
                            className="block px-4 py-2 text-sm text-purple-600 hover:bg-purple-50"
                          >
                            + Adicionar filho
                          </Link>
                        </div>
                      </div>
                    </div>
                  )}
                </div>
              )}
            </div>
          </div>

          {/* Menu do usuário */}
          <div className="flex items-center space-x-4">
            {/* Informações do usuário */}
            <div className="hidden md:block text-right">
              <p className="text-sm font-medium text-gray-900">
                {parent?.display_name || 'Pai/Responsável'}
              </p>
              <p className="text-xs text-gray-500">{parent?.email}</p>
            </div>

            {/* Botões de ação */}
            <Link href="/account">
              <Button variant="ghost" size="sm">
                <Settings className="w-4 h-4" />
                <span className="hidden md:inline ml-2">Conta</span>
              </Button>
            </Link>

            <Button
              variant="ghost"
              size="sm"
              onClick={handleLogout}
              disabled={isLoggingOut}
            >
              <LogOut className="w-4 h-4" />
              <span className="hidden md:inline ml-2">
                {isLoggingOut ? 'Saindo...' : 'Sair'}
              </span>
            </Button>
          </div>
        </div>
      </div>

      {/* Overlay para fechar dropdown */}
      {isDropdownOpen && (
        <div
          className="fixed inset-0 z-40"
          onClick={() => setIsDropdownOpen(false)}
        />
      )}
    </nav>
  );
}