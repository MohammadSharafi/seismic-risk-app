/**
 * No default conversation data. When Command API is not configured or a non-command
 * is sent, addMockMessage returns a single hint message. All real data comes from the
 * Command API (VITE_COMMAND_API_URL).
 */

export const mockMessages: Array<{
  id: string;
  role: 'user' | 'assistant';
  content?: string;
  answer?: string;
  evidence?: Record<string, unknown>;
  suggestions?: string;
  widget?: { type: string; data: Record<string, unknown> };
  timestamp: Date;
}> = [];

/**
 * Fallback when Command API is disabled or stream returns no widget.
 * Returns a minimal assistant message (no hardcoded widget data).
 */
export function addMockMessage(userInput: string): {
  id: string;
  role: 'assistant';
  answer: string;
  evidence?: Record<string, unknown>;
  suggestions?: string;
  widget?: undefined;
  timestamp: Date;
} {
  const isCommand = userInput.trim().toLowerCase().startsWith('/');
  return {
    id: `msg-${Date.now()}`,
    role: 'assistant',
    answer: isCommandApiConfigured()
      ? 'Command completed. No widget was returned.'
      : 'Set VITE_COMMAND_API_URL in .env to connect to the Command API and run commands.',
    evidence: { generated: new Date().toLocaleString() },
    suggestions: '/summary, /alerts',
    timestamp: new Date(),
  };
}

function isCommandApiConfigured(): boolean {
  try {
    const url = (import.meta.env?.VITE_COMMAND_API_URL ?? '').toString().trim();
    return url.length > 0;
  } catch {
    return false;
  }
}
