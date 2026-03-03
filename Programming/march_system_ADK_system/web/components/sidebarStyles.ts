/**
 * Shared sidebar UI: minimal, professional, consistent.
 * Uses theme palette (background, card, muted, accent, primary, border, foreground).
 */

export const SIDEBAR_WIDTH = 256;

export const sidebar = {
  root: 'flex-shrink-0 w-[256px] h-full flex flex-col bg-card overflow-hidden border-r border-border',
  header: 'flex-shrink-0 flex items-center justify-between gap-1 px-2 py-1.5 border-b border-border bg-card',
  title: 'text-[10px] font-semibold text-foreground truncate uppercase tracking-tight',
  closeButton:
    'flex items-center justify-center w-6 h-6 rounded text-muted-foreground hover:text-foreground hover:bg-accent transition-colors focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-1 focus-visible:ring-offset-background',
  body: 'flex-1 overflow-y-auto min-h-0 overscroll-contain',
  bodyPad: 'px-2 py-1.5',
  sectionLabel: 'text-[8px] font-medium text-muted-foreground uppercase tracking-wider mb-1',
  primaryButton:
    'w-full flex items-center justify-center gap-1 px-2 py-1.5 rounded-md bg-primary text-primary-foreground text-[11px] font-medium hover:opacity-90 transition-opacity focus:outline-none focus-visible:ring-2 focus-visible:ring-primary focus-visible:ring-offset-1 focus-visible:ring-offset-background',
  input:
    'w-full pl-7 pr-2 py-1.5 rounded-md bg-card border border-border text-[11px] placeholder:text-muted-foreground text-foreground focus:outline-none focus:ring-2 focus:ring-primary focus:border-primary',
  card: 'rounded-md bg-card border border-border',
  cardActive: 'rounded-md bg-secondary/50 border border-primary/30',
  rowButton:
    'w-full flex items-center justify-between py-1 px-2 rounded-md text-left text-[11px] text-foreground hover:bg-accent transition-colors',
  rowLink: 'text-primary font-medium text-[11px]',
  doneButton:
    'w-full px-2.5 py-1.5 rounded-md bg-primary text-primary-foreground text-[11px] font-medium hover:opacity-90 transition-opacity',
  pillSolidSelected: 'bg-primary text-primary-foreground border border-primary',
  pillDefault:
    'bg-card border border-border text-foreground hover:bg-accent text-[11px]',
  toggleOn: 'bg-primary',
  toggleOff: 'bg-muted',
  selectionBar: 'bg-primary',
  iconBox:
    'flex-shrink-0 w-6 h-6 rounded bg-muted flex items-center justify-center text-foreground',
  iconBoxTeal:
    'flex-shrink-0 w-6 h-6 rounded-full bg-secondary flex items-center justify-center text-primary',
} as const;
