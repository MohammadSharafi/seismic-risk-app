import React, { useEffect } from 'react';
import { Link, Outlet, useLocation } from 'react-router-dom';
import {
  Shield,
  ScrollText,
  ListOrdered,
  Wrench,
  LayoutDashboard,
  ArrowLeft,
  Search,
  Activity,
  Layers,
  GitBranch,
  Radio,
} from 'lucide-react';
import { cn } from '../ui/utils';
import { useTrafficStreamOptional } from '../../contexts/TrafficStreamContext';

const nav = [
  { path: '/admin', label: 'Overview', icon: LayoutDashboard },
  { path: '/admin/rules', label: 'Command rules', icon: Shield },
  { path: '/admin/command-audit', label: 'Command audit', icon: ScrollText },
  { path: '/admin/step-audit', label: 'Step audit', icon: ListOrdered },
  { path: '/admin/tools', label: 'Tools', icon: Wrench },
  { path: '/admin/run-lookup', label: 'Run lookup', icon: Search },
  { path: '/admin/status', label: 'System status', icon: Activity },
  { path: '/admin/capabilities', label: 'Capabilities', icon: Layers },
  { path: '/admin/system-overview', label: 'System overview', icon: GitBranch },
  { path: '/admin/traffic-inspector', label: 'Traffic inspector', icon: Radio },
];

export function AdminLayout() {
  const location = useLocation();
  const stream = useTrafficStreamOptional();
  useEffect(() => {
    if (stream) stream.connect();
  }, [stream]);

  return (
    <div className="h-screen flex bg-[#f8f7f5] overflow-hidden">
      <aside className="w-56 flex-shrink-0 bg-[#1c1917] text-stone-200 flex flex-col">
        <div className="p-4 border-b border-stone-700/70">
          <Link
            to="/"
            className="flex items-center gap-2 text-stone-400 hover:text-white text-sm transition-colors"
          >
            <ArrowLeft className="size-4" />
            Back to app
          </Link>
        </div>
        <div className="p-3">
          <div className="text-xs font-semibold uppercase tracking-wider text-stone-500 px-3 py-2">
            Admin
          </div>
          <nav className="space-y-0.5">
            {nav.map(({ path, label, icon: Icon }) => {
              const active = path === '/admin' ? location.pathname === '/admin' : location.pathname.startsWith(path);
              return (
                <Link
                  key={path}
                  to={path}
                  className={cn(
                    'flex items-center gap-3 px-3 py-2.5 rounded-lg text-sm font-medium transition-colors',
                    active
                      ? 'bg-amber-500/20 text-amber-300 border border-amber-500/30'
                      : 'text-stone-400 hover:bg-stone-800 hover:text-stone-200'
                  )}
                >
                  <Icon className="size-4 flex-shrink-0" />
                  {label}
                </Link>
              );
            })}
          </nav>
        </div>
        <div className="mt-auto p-4 border-t border-stone-700/70">
          <div className="text-[10px] uppercase tracking-wider text-stone-600">March Digital System</div>
          <div className="text-xs text-stone-500">Admin panel</div>
        </div>
      </aside>
      <main className="flex-1 min-w-0 min-h-0 overflow-auto">
        <Outlet />
      </main>
    </div>
  );
}
