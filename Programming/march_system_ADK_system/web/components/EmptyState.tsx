import React from 'react';
import { LucideIcon } from 'lucide-react';

interface EmptyStateProps {
  icon?: LucideIcon;
  title: string;
  subtitle?: string;
  action?: {
    label: string;
    onClick: () => void;
  };
}

export function EmptyState({ icon: Icon, title, subtitle, action }: EmptyStateProps) {
  return (
    <div className="flex flex-col items-center justify-center h-64 text-center space-y-4">
      {Icon && (
        <div className="text-5xl text-slate-400 dark:text-slate-600">
          <Icon className="w-16 h-16 mx-auto opacity-40" />
        </div>
      )}
      <div>
        <p className="text-lg font-semibold text-slate-700 dark:text-slate-100">{title}</p>
        {subtitle && (
          <p className="text-sm text-slate-500 dark:text-slate-100 mt-1">{subtitle}</p>
        )}
      </div>
      {action && (
        <button
          onClick={action.onClick}
          className="mt-4 px-4 py-2 bg-gradient-to-r from-teal-500 to-teal-600 hover:from-teal-600 hover:to-teal-700 text-white rounded-lg font-medium text-sm transition-all shadow-sm hover:shadow-md"
        >
          {action.label}
        </button>
      )}
    </div>
  );
}
