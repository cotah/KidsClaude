'use client';

import * as React from 'react';
import * as ProgressPrimitive from '@radix-ui/react-progress';
import { useLocale } from 'next-intl';
import { cn } from '@/lib/utils';

const Progress = React.forwardRef<
  React.ElementRef<typeof ProgressPrimitive.Root>,
  React.ComponentPropsWithoutRef<typeof ProgressPrimitive.Root>
>(({ className, value, ...props }, ref) => (
  <ProgressPrimitive.Root
    ref={ref}
    className={cn(
      'relative h-4 w-full overflow-hidden rounded-full bg-secondary',
      className
    )}
    {...props}
  >
    <ProgressPrimitive.Indicator
      className="h-full w-full flex-1 bg-primary transition-all"
      style={{ transform: `translateX(-${100 - (value || 0)}%)` }}
    />
  </ProgressPrimitive.Root>
));
Progress.displayName = ProgressPrimitive.Root.displayName;

// Kid-friendly progress bar with animations
interface XPProgressProps {
  current: number;
  max: number;
  level: number;
  showAnimation?: boolean;
  colorScheme?: 'sunny' | 'ocean' | 'mint' | 'sunset' | 'grape';
}

const XPProgress = React.forwardRef<
  HTMLDivElement,
  XPProgressProps & React.HTMLAttributes<HTMLDivElement>
>(({ current, max, level, showAnimation = false, colorScheme = 'sunny', className, ...props }, ref) => {
  const locale = useLocale();
  const percentage = Math.min((current / max) * 100, 100);
  const percentRounded = Math.round(percentage);

  const colorClasses = {
    sunny: 'bg-sunny-500',
    ocean: 'bg-ocean-500',
    mint: 'bg-mint-500',
    sunset: 'bg-sunset-500',
    grape: 'bg-grape-500',
  };

  // JS puro - sem ICU, sem t() (componente UI generico, evita acoplar
  // ao namespace de i18n da pagina que usa o XPProgress).
  const levelLabel = locale === 'en' ? `Level ${level}` : `Nível ${level}`;
  const toNextLabel = locale === 'en'
    ? `${percentRounded}% to next level`
    : `${percentRounded}% para o próximo nível`;

  return (
    <div ref={ref} className={cn('space-y-2', className)} {...props}>
      <div className="flex items-center justify-between text-kid-sm font-semibold">
        <span>{levelLabel}</span>
        <span>{current}/{max} XP</span>
      </div>
      <div className="relative h-6 w-full overflow-hidden rounded-kid bg-gray-200">
        <div
          className={cn(
            'h-full transition-all duration-1000 ease-out rounded-kid',
            colorClasses[colorScheme],
            showAnimation && 'animate-pulse'
          )}
          style={{ width: `${percentage}%` }}
        />
        <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent" />
      </div>
      <div className="text-center text-kid-sm text-gray-600">
        {toNextLabel}
      </div>
    </div>
  );
});
XPProgress.displayName = 'XPProgress';

// Simple circular progress for streaks
interface StreakProgressProps {
  days: number;
  maxDisplay?: number;
}

const StreakProgress: React.FC<StreakProgressProps> = ({ days, maxDisplay = 7 }) => {
  const displayDays = Math.min(days, maxDisplay);
  const percentage = (displayDays / maxDisplay) * 100;

  return (
    <div className="relative w-16 h-16">
      <svg className="w-16 h-16 transform -rotate-90" viewBox="0 0 36 36">
        {/* Background circle */}
        <path
          className="text-gray-200"
          stroke="currentColor"
          strokeWidth="3"
          fill="transparent"
          d="M18 2.0845
            a 15.9155 15.9155 0 0 1 0 31.831
            a 15.9155 15.9155 0 0 1 0 -31.831"
        />
        {/* Progress circle */}
        <path
          className="text-sunset-500"
          stroke="currentColor"
          strokeWidth="3"
          strokeDasharray={`${percentage}, 100`}
          strokeLinecap="round"
          fill="transparent"
          d="M18 2.0845
            a 15.9155 15.9155 0 0 1 0 31.831
            a 15.9155 15.9155 0 0 1 0 -31.831"
        />
      </svg>
      <div className="absolute inset-0 flex items-center justify-center">
        <span className="text-kid-base font-bold text-sunset-600">{days}</span>
      </div>
    </div>
  );
};

export { Progress, XPProgress, StreakProgress };