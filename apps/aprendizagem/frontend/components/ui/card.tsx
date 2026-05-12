import * as React from 'react';
import { cn } from '@/lib/utils';

const Card = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn(
      'rounded-lg border bg-card text-card-foreground shadow-sm',
      className
    )}
    {...props}
  />
));
Card.displayName = 'Card';

const CardHeader = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('flex flex-col space-y-1.5 p-6', className)}
    {...props}
  />
));
CardHeader.displayName = 'CardHeader';

const CardTitle = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLHeadingElement>
>(({ className, ...props }, ref) => (
  <h3
    ref={ref}
    className={cn(
      'text-2xl font-semibold leading-none tracking-tight',
      className
    )}
    {...props}
  />
));
CardTitle.displayName = 'CardTitle';

const CardDescription = React.forwardRef<
  HTMLParagraphElement,
  React.HTMLAttributes<HTMLParagraphElement>
>(({ className, ...props }, ref) => (
  <p
    ref={ref}
    className={cn('text-sm text-muted-foreground', className)}
    {...props}
  />
));
CardDescription.displayName = 'CardDescription';

const CardContent = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div ref={ref} className={cn('p-6 pt-0', className)} {...props} />
));
CardContent.displayName = 'CardContent';

const CardFooter = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement>
>(({ className, ...props }, ref) => (
  <div
    ref={ref}
    className={cn('flex items-center p-6 pt-0', className)}
    {...props}
  />
));
CardFooter.displayName = 'CardFooter';

// Kid-friendly card variant
const KidCard = React.forwardRef<
  HTMLDivElement,
  React.HTMLAttributes<HTMLDivElement> & {
    colorScheme?: 'sunny' | 'ocean' | 'mint' | 'sunset' | 'grape';
  }
>(({ className, colorScheme = 'sunny', ...props }, ref) => {
  const colorClasses = {
    sunny: 'border-sunny-200 bg-gradient-to-br from-sunny-50 to-sunny-100',
    ocean: 'border-ocean-200 bg-gradient-to-br from-ocean-50 to-ocean-100',
    mint: 'border-mint-200 bg-gradient-to-br from-mint-50 to-mint-100',
    sunset: 'border-sunset-200 bg-gradient-to-br from-sunset-50 to-sunset-100',
    grape: 'border-grape-200 bg-gradient-to-br from-grape-50 to-grape-100',
  };

  return (
    <div
      ref={ref}
      className={cn(
        'rounded-kid-lg border-2 shadow-lg hover:shadow-xl transition-all duration-300 hover:scale-105',
        colorClasses[colorScheme],
        className
      )}
      {...props}
    />
  );
});
KidCard.displayName = 'KidCard';

export { Card, CardHeader, CardFooter, CardTitle, CardDescription, CardContent, KidCard };