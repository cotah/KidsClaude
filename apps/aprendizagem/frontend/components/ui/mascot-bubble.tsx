import * as React from 'react';
import { cn } from '@/lib/utils';

export type MascotBubbleVariant =
  | 'default'
  | 'thinking'
  | 'excited'
  | 'encouraging'
  | 'cheerful'
  | 'warning';

interface MascotBubbleProps {
  children: React.ReactNode;
  variant?: MascotBubbleVariant;
  showTail?: boolean;
  className?: string;
}

export const MascotBubble: React.FC<MascotBubbleProps> = ({
  children,
  variant = 'default',
  showTail = true,
  className,
}) => {
  const variantClasses: Record<MascotBubbleVariant, string> = {
    default: 'bg-white border-gray-200',
    thinking: 'bg-grape-50 border-grape-200',
    excited: 'bg-sunny-50 border-sunny-200',
    encouraging: 'bg-mint-50 border-mint-200',
    cheerful: 'bg-sunset-50 border-sunset-200',
    warning: 'bg-sunset-100 border-sunset-300',
  };

  return (
    <div className={cn('relative', className)}>
      <div
        className={cn(
          'rounded-kid-lg border-2 p-6 shadow-lg',
          variantClasses[variant]
        )}
      >
        <div className="text-kid-base text-gray-800 leading-relaxed">
          {children}
        </div>
      </div>
      {showTail && (
        <div className="absolute -bottom-2 left-8">
          <div
            className={cn(
              'w-4 h-4 border-b-2 border-r-2 transform rotate-45',
              variantClasses[variant]
            )}
          />
        </div>
      )}
    </div>
  );
};

// Animated mascot component placeholder
interface MascotProps {
  expression?: 'happy' | 'thinking' | 'excited' | 'sleeping';
  size?: 'sm' | 'md' | 'lg';
  className?: string;
}

export const Mascot: React.FC<MascotProps> = ({
  expression = 'happy',
  size = 'md',
  className,
}) => {
  const sizeClasses = {
    sm: 'w-16 h-16',
    md: 'w-24 h-24',
    lg: 'w-32 h-32',
  };

  const expressionClasses = {
    happy: 'text-sunny-500',
    thinking: 'text-grape-500',
    excited: 'text-sunset-500',
    sleeping: 'text-gray-400',
  };

  return (
    <div
      className={cn(
        'flex items-center justify-center rounded-full bg-white border-4 shadow-lg',
        sizeClasses[size],
        expressionClasses[expression],
        expression === 'excited' && 'animate-bounce-gentle',
        className
      )}
    >
      {/* Placeholder for mascot illustration - será substituído por SVG real */}
      <div className="text-4xl">🤖</div>
    </div>
  );
};