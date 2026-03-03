import React from 'react';
import { CheckCircle, AlertCircle, Clock, Info } from 'lucide-react';

type BadgeVariant = 'default' | 'secondary' | 'success' | 'warning' | 'danger' | 'info';
type BadgeSize = 'sm' | 'md' | 'lg';

interface BadgeProps {
  children: React.ReactNode;
  variant?: BadgeVariant;
  size?: BadgeSize;
  icon?: React.ReactNode;
}

const variantClasses: Record<BadgeVariant, string> = {
  default: 'bg-slate-100 bg-muted text-foreground border border-border',
  secondary: 'bg-teal-100 dark:bg-teal-900/30 text-teal-700 dark:text-teal-100 border border-teal-200 dark:border-teal-800',
  success: 'bg-emerald-100 dark:bg-emerald-900/30 text-emerald-700 dark:text-emerald-100 border border-emerald-200 dark:border-emerald-800',
  warning: 'bg-amber-100 dark:bg-amber-900/30 text-amber-700 dark:text-amber-100 border border-amber-200 dark:border-amber-800',
  danger: 'bg-red-100 dark:bg-red-900/30 text-red-700 dark:text-red-100 border border-red-200 dark:border-red-800',
  info: 'bg-cyan-100 dark:bg-cyan-900/30 text-cyan-700 dark:text-cyan-100 border border-cyan-200 dark:border-cyan-800'
};

const sizeClasses: Record<BadgeSize, string> = {
  sm: 'px-2 py-1 text-xs font-medium rounded',
  md: 'px-2.5 py-1.5 text-sm font-semibold rounded-md',
  lg: 'px-3 py-2 text-base font-semibold rounded-lg'
};

export function Badge({ children, variant = 'default', size = 'md', icon }: BadgeProps) {
  return (
    <span className={`inline-flex items-center gap-1.5 ${variantClasses[variant]} ${sizeClasses[size]}`}>
      {icon}
      {children}
    </span>
  );
}

export function StatusBadge({ status }: { status: 'success' | 'error' | 'pending' | 'info' }) {
  const variants: Record<string, BadgeVariant> = {
    success: 'success',
    error: 'danger',
    pending: 'warning',
    info: 'info'
  };

  const config: Record<string, { label: string; icon: React.ReactNode }> = {
    success: { label: 'Success', icon: <CheckCircle className="w-3.5 h-3.5" /> },
    error: { label: 'Error', icon: <AlertCircle className="w-3.5 h-3.5" /> },
    pending: { label: 'Pending', icon: <Clock className="w-3.5 h-3.5" /> },
    info: { label: 'Info', icon: <Info className="w-3.5 h-3.5" /> }
  };

  const item = config[status];
  return <Badge variant={variants[status]} size="sm" icon={item.icon}>{item.label}</Badge>;
}
