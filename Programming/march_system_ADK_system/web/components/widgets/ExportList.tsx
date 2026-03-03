import React from 'react';
import { FileText, Download } from 'lucide-react';
import { isCommandApiEnabled, getExportDownloadUrl } from '../../api/commandApi';

export function ExportList({ data }: { data: any }) {
  const exports = Array.isArray(data?.exports) ? data.exports : [];
  const canDownload = isCommandApiEnabled();
  return (
    <div className="border border-border rounded-md sm:rounded-lg overflow-hidden bg-card my-2 sm:my-3">
      <div className="bg-accent/50 px-2 sm:px-4 py-1.5 sm:py-2.5 border-b border-border">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <FileText className="w-3 h-3 sm:w-4 sm:h-4 text-muted-foreground" />
          <h3 className="text-[10px] sm:text-sm font-medium text-foreground">Recent Exports</h3>
        </div>
      </div>
      <div className="p-2 sm:p-4">
        {exports.length === 0 ? (
          <div className="text-[10px] sm:text-sm text-muted-foreground py-2">No exports yet.</div>
        ) : (
          <ul className="space-y-2 sm:space-y-3">
            {exports.map((exp: any, i: number) => (
              <li
                key={i}
                className="flex items-center gap-2 sm:gap-3 p-2 sm:p-3 bg-accent/50 rounded-md border border-border"
              >
                <div className="w-8 h-8 sm:w-9 sm:h-9 bg-red-500/15 dark:bg-red-500/20 border border-red-500/40 rounded flex items-center justify-center flex-shrink-0">
                  <FileText className="w-4 h-4 text-red-600 dark:text-red-400" />
                </div>
                <div className="flex-1 min-w-0">
                  <div className="text-[10px] sm:text-sm font-medium text-foreground truncate">
                    {exp?.filename ?? 'export'}
                  </div>
                  <div className="flex items-center gap-1.5 sm:gap-2 text-[9px] sm:text-xs text-muted-foreground flex-wrap">
                    <span className="font-mono">{exp?.exportId ?? ''}</span>
                    {exp?.type && (
                      <>
                        <span>•</span>
                        <span className="uppercase">{exp.type}</span>
                      </>
                    )}
                    {exp?.timestamp && (
                      <>
                        <span>•</span>
                        <span>{exp.timestamp}</span>
                      </>
                    )}
                  </div>
                </div>
                {canDownload && (exp?.exportId) ? (
                  <a
                    href={getExportDownloadUrl(exp.exportId)}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="p-1.5 sm:p-2 text-muted-foreground hover:text-foreground hover:bg-accent rounded flex-shrink-0"
                    title="Download"
                    aria-label="Download"
                  >
                    <Download className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
                  </a>
                ) : (
                  <span className="p-1.5 sm:p-2 text-muted-foreground/50 cursor-not-allowed" title="Download (connect backend to enable)">
                    <Download className="w-3.5 h-3.5 sm:w-4 sm:h-4" />
                  </span>
                )}
              </li>
            ))}
          </ul>
        )}
      </div>
    </div>
  );
}
