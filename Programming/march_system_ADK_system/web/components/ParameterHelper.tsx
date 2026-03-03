import React from 'react';
import { Info } from 'lucide-react';
import { Command } from './CommandPalette';

interface ParameterHelperProps {
  command: Command;
}

export function ParameterHelper({ command }: ParameterHelperProps) {
  const requiredParams = command.parameters.filter(p => p.required);
  const optionalParams = command.parameters.filter(p => !p.required);

  if (command.parameters.length === 0) {
    return null;
  }

  return (
    <div className="mt-1.5 sm:mt-2 px-2 sm:px-3 py-1.5 sm:py-2 bg-teal-50 border border-blue-100 rounded-md sm:rounded-lg">
      <div className="flex items-start gap-1.5 sm:gap-2">
        <Info className="w-3 h-3 sm:w-4 sm:h-4 text-teal-500 flex-shrink-0 mt-0.5" />
        <div className="flex-1 min-w-0">
          <div className="text-[10px] sm:text-sm text-blue-900">
            <code className="font-mono font-medium">{command.name}</code>
            {requiredParams.length > 0 && (
              <span className="ml-1 sm:ml-2">
                requires: 
                {requiredParams.map((param, i) => (
                  <span key={param.name}>
                    {i > 0 && ', '}
                    <code className="font-mono text-orange-600 ml-0.5 sm:ml-1">{param.name}</code>
                  </span>
                ))}
              </span>
            )}
          </div>
          {optionalParams.length > 0 && (
            <div className="text-[9px] sm:text-xs text-teal-700 mt-0.5 sm:mt-1">
              Optional: {optionalParams.map(p => p.name).join(', ')}
            </div>
          )}
          <div className="text-[9px] sm:text-xs text-teal-600 mt-0.5 sm:mt-1 flex items-center gap-1 flex-wrap">
            <span className="text-blue-400">Example:</span>
            <code className="font-mono bg-teal-100 px-1 sm:px-1.5 py-0.5 rounded text-[8px] sm:text-xs">
              {command.example}
            </code>
          </div>
        </div>
      </div>
    </div>
  );
}
