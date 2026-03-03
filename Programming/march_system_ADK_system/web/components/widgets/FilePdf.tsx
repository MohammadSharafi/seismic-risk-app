import React from 'react';
import { FileText, Download } from 'lucide-react';
import { isCommandApiEnabled, getExportDownloadUrl, commandApiBase } from '../../api/commandApi';

export function FilePdf({ data }: { data: any }) {
  const filename = data?.filename ?? 'export.pdf';
  const exportId = data?.exportId ?? '';
  const size = data?.size ?? '';
  const timestamp = data?.timestamp ?? '';
  const sections = Array.isArray(data?.sections) ? data.sections : [];
  const timeWindow = data?.timeWindow ?? '';
  const rawDownloadUrl = data?.downloadUrl;
  const canDownload = isCommandApiEnabled() && (!!exportId || !!rawDownloadUrl);
  const href = rawDownloadUrl
    ? (rawDownloadUrl.startsWith('http') ? rawDownloadUrl : commandApiBase() + rawDownloadUrl)
    : exportId
      ? getExportDownloadUrl(exportId)
      : '#';
  return (
    <div className="border border-border rounded-md sm:rounded-lg overflow-hidden bg-card my-2 sm:my-3">
      <div className="bg-slate-50 bg-muted/50 px-2 sm:px-4 py-1.5 sm:py-2.5 border-b border-border">
        <div className="flex items-center gap-1.5 sm:gap-2">
          <FileText className="w-3 h-3 sm:w-4 sm:h-4 text-gray-600" />
          <h3 className="text-[10px] sm:text-sm font-medium text-gray-900">Export PDF Result</h3>
        </div>
      </div>
      <div className="p-2 sm:p-4">
        {/* File Info */}
        <div className="flex items-start gap-2 sm:gap-3 mb-2 sm:mb-4">
          <div className="w-8 h-10 sm:w-10 sm:h-12 bg-red-50 border border-red-200 rounded flex items-center justify-center flex-shrink-0">
            <FileText className="w-4 h-4 sm:w-5 sm:h-5 text-red-600" />
          </div>
          <div className="flex-1 min-w-0">
            <div className="text-[10px] sm:text-sm font-medium text-gray-900 mb-0.5 sm:mb-1">{filename}</div>
            <div className="flex items-center gap-1.5 sm:gap-2 text-[9px] sm:text-xs text-slate-500 text-muted-foreground flex-wrap">
              <span className="font-mono">{exportId}</span>
              <span>•</span>
              <span>{size}</span>
              <span>•</span>
              <span>{timestamp}</span>
            </div>
            {canDownload && (
              <a
                href={href}
                target="_blank"
                rel="noopener noreferrer"
                className="mt-1.5 sm:mt-2 inline-flex items-center gap-1 sm:gap-1.5 text-[10px] sm:text-xs text-teal-600 hover:text-blue-800 font-medium"
              >
                <Download className="w-3 h-3 sm:w-4 sm:h-4" />
                Download
              </a>
            )}
          </div>
        </div>

        {/* Included Sections */}
        {sections.length > 0 && (
          <div className="mb-2 sm:mb-3">
            <div className="text-[9px] sm:text-xs font-medium text-slate-500 text-muted-foreground mb-1.5 sm:mb-2">
              Included sections
            </div>
            <div className="flex flex-wrap gap-1 sm:gap-1.5">
              {sections.map((section: string, i: number) => (
                <span key={i} className="px-1.5 sm:px-2 py-0.5 sm:py-1 bg-muted text-muted-foreground border border-border rounded text-[9px] sm:text-xs">
                  {section}
                </span>
              ))}
            </div>
          </div>
        )}

        {/* Time Window */}
        {timeWindow && (
          <div className="text-[9px] sm:text-xs text-slate-600 text-muted-foreground">
            <span className="text-slate-500 text-muted-foreground">Time window:</span> {timeWindow}
          </div>
        )}
      </div>
    </div>
  );
}
