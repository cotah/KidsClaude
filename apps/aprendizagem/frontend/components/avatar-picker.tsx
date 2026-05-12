import * as React from 'react';
import { cn } from '@/lib/utils';
import { KidCard } from './ui/card';
import { mockAvatars } from '@/lib/mock/data';
import type { Avatar, AgeGroup } from '@/types/app';

interface AvatarPickerProps {
  selectedId?: string;
  onSelect: (avatarId: string) => void;
  ageGroup?: AgeGroup;
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export const AvatarPicker: React.FC<AvatarPickerProps> = ({
  selectedId,
  onSelect,
  ageGroup,
  size = 'md',
  className,
}) => {
  // Filtrar avatares por faixa etária se especificado
  const availableAvatars = ageGroup
    ? mockAvatars.filter(avatar => avatar.suitable_for.includes(ageGroup))
    : mockAvatars;

  const sizeClasses = {
    sm: 'w-16 h-16',
    md: 'w-24 h-24',
    lg: 'w-32 h-32',
  };

  const gridClasses = {
    sm: 'grid-cols-4 gap-3',
    md: 'grid-cols-3 gap-4',
    lg: 'grid-cols-2 gap-6',
  };

  return (
    <div className={cn('w-full', className)}>
      <div className={cn('grid', gridClasses[size])}>
        {availableAvatars.map((avatar) => (
          <AvatarOption
            key={avatar.id}
            avatar={avatar}
            isSelected={selectedId === avatar.id}
            size={size}
            onClick={() => onSelect(avatar.id)}
          />
        ))}
      </div>
    </div>
  );
};

interface AvatarOptionProps {
  avatar: Avatar;
  isSelected: boolean;
  size: 'sm' | 'md' | 'lg';
  onClick: () => void;
}

const AvatarOption: React.FC<AvatarOptionProps> = ({
  avatar,
  isSelected,
  size,
  onClick,
}) => {
  const sizeClasses = {
    sm: 'w-16 h-16',
    md: 'w-24 h-24',
    lg: 'w-32 h-32',
  };

  return (
    <KidCard
      colorScheme={isSelected ? 'sunny' : undefined}
      className={cn(
        'cursor-pointer transition-all duration-200 hover:scale-110',
        'flex flex-col items-center justify-center p-4 space-y-2',
        isSelected && 'ring-4 ring-sunny-400 border-sunny-400'
      )}
      onClick={onClick}
    >
      <div className={cn('relative', sizeClasses[size])}>
        {/* Placeholder para imagem do avatar - em produção seria um Image component */}
        <div className="w-full h-full rounded-full bg-gradient-to-br from-gray-200 to-gray-300 flex items-center justify-center text-2xl">
          {getAvatarEmoji(avatar.id)}
        </div>
        {isSelected && (
          <div className="absolute -top-1 -right-1 w-6 h-6 bg-sunny-500 rounded-full flex items-center justify-center">
            <span className="text-white text-sm">✓</span>
          </div>
        )}
      </div>
      <span className="text-kid-sm font-medium text-center">{avatar.name}</span>
    </KidCard>
  );
};

// Helper function para emojis dos avatares (placeholder)
function getAvatarEmoji(avatarId: string): string {
  const emojiMap: Record<string, string> = {
    cat: '🐱',
    dog: '🐶',
    unicorn: '🦄',
    robot: '🤖',
    dragon: '🐲',
  };
  return emojiMap[avatarId] || '😊';
}

// Componente para exibir um único avatar (usado em perfis, etc)
interface AvatarDisplayProps {
  avatarId: string;
  size?: 'xs' | 'sm' | 'md' | 'lg' | 'xl';
  className?: string;
}

export const AvatarDisplay: React.FC<AvatarDisplayProps> = ({
  avatarId,
  size = 'md',
  className,
}) => {
  const avatar = mockAvatars.find(a => a.id === avatarId);

  const sizeClasses = {
    xs: 'w-8 h-8',
    sm: 'w-12 h-12',
    md: 'w-16 h-16',
    lg: 'w-24 h-24',
    xl: 'w-32 h-32',
  };

  const textSizeClasses = {
    xs: 'text-sm',
    sm: 'text-base',
    md: 'text-xl',
    lg: 'text-2xl',
    xl: 'text-4xl',
  };

  if (!avatar) {
    return (
      <div className={cn(
        'rounded-full bg-gray-300 flex items-center justify-center',
        sizeClasses[size],
        className
      )}>
        <span className={textSizeClasses[size]}>?</span>
      </div>
    );
  }

  return (
    <div className={cn(
      'rounded-full bg-gradient-to-br from-gray-200 to-gray-300 flex items-center justify-center border-2 border-white shadow-lg',
      sizeClasses[size],
      className
    )}>
      <span className={textSizeClasses[size]}>
        {getAvatarEmoji(avatar.id)}
      </span>
    </div>
  );
};