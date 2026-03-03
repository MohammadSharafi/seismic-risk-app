import React from 'react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts';

export function ChartLine({ data }: { data: any }) {
  return (
    <div className="border border-cyan-500/30 dark:border-cyan-500/40 rounded-md sm:rounded-lg overflow-hidden bg-cyan-500/10 dark:bg-cyan-500/10 my-2 sm:my-3">
      <div className="bg-cyan-500/15 dark:bg-cyan-500/20 px-2 sm:px-4 py-1.5 sm:py-2 border-b border-cyan-500/30 dark:border-cyan-500/40">
        <h3 className="text-[10px] sm:text-sm font-medium text-cyan-800 dark:text-cyan-200">{data.title}</h3>
      </div>
      <div className="p-2 sm:p-4 bg-card">
        <ResponsiveContainer width="100%" height={180}>
          <LineChart data={data.points}>
            <CartesianGrid strokeDasharray="3 3" stroke="#e5e7eb" />
            <XAxis
              dataKey="date"
              tick={{ fontSize: 10, fill: '#6b7280' }}
              stroke="#9ca3af"
            />
            <YAxis
              tick={{ fontSize: 10, fill: '#6b7280' }}
              stroke="#9ca3af"
            />
            <Tooltip
              contentStyle={{
                backgroundColor: '#fff',
                border: '1px solid #e5e7eb',
                borderRadius: '6px',
                fontSize: '11px'
              }}
            />
            <Line
              type="monotone"
              dataKey="value"
              stroke="#2563eb"
              strokeWidth={2}
              dot={{ fill: '#2563eb', r: 3 }}
            />
          </LineChart>
        </ResponsiveContainer>
        {data.summary && (
          <div className="mt-2 sm:mt-3 pt-2 sm:pt-3 border-t border-border text-[10px] sm:text-sm text-muted-foreground">
            {data.summary}
          </div>
        )}
      </div>
    </div>
  );
}