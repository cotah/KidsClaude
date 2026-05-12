import * as React from 'react';
import { cva, type VariantProps } from 'class-variance-authority';
import { cn } from '@/lib/utils';

const badgeVariants = cva(
  'inline-flex items-center rounded-full border px-2.5 py-0.5 text-xs font-semibold transition-colors focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2',
  {
    variants: {
      variant: {
        default: 'border-transparent bg-primary text-primary-foreground hover:bg-primary/80',
        secondary: 'border-transparent bg-secondary text-secondary-foreground hover:bg-secondary/80',
        destructive: 'border-transparent bg-destructive text-destructive-foreground hover:bg-destructive/80',
        outline: 'text-foreground',
        // Achievement badge variants
        gold: 'border-sunny-300 bg-gradient-to-r from-sunny-400 to-sunny-500 text-white shadow-lg',
        silver: 'border-gray-300 bg-gradient-to-r from-gray-400 to-gray-500 text-white shadow-lg',
        bronze: 'border-sunset-300 bg-gradient-to-r from-sunset-400 to-sunset-500 text-white shadow-lg',
        success: 'border-mint-300 bg-gradient-to-r from-mint-400 to-mint-500 text-white shadow-lg',
        special: 'border-grape-300 bg-gradient-to-r from-grape-400 to-grape-500 text-white shadow-lg',
      },
      size: {
        default: 'text-xs px-2.5 py-0.5',
        sm: 'text-xs px-2 py-0.5',
        lg: 'text-sm px-3 py-1',
        // Kid-friendly sizes
        kid: 'text-kid-sm px-4 py-2 rounded-kid',
        'kid-lg': 'text-kid-base px-6 py-3 rounded-kid-lg',
      },
    },
    defaultVariants: {
      variant: 'default',
      size: 'default',
    },
  }
);

export interface BadgeProps
  extends React.HTMLAttributes<HTMLDivElement>,
    VariantProps<typeof badgeVariants> {}

function Badge({ className, variant, size, ...props }: BadgeProps) {
  return (
    <div className={cn(badgeVariants({ variant, size }), className)} {...props} />
  );
}

export { Badge, badgeVariants };