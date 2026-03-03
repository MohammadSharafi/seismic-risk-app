import React from 'react';
import { Link } from 'react-router-dom';
import { Shield, ScrollText, ListOrdered, Wrench, Search, Activity, Layers, GitBranch, Radio, ArrowRight } from 'lucide-react';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../ui/card';
import { Button } from '../ui/button';

const sections = [
  { path: '/admin/rules', label: 'Command rules', desc: 'Manage who can run which commands (roles and tenants).', icon: Shield },
  { path: '/admin/command-audit', label: 'Command audit', desc: 'Recent command runs, tools, and status. Filter and export.', icon: ScrollText },
  { path: '/admin/step-audit', label: 'Step audit', desc: 'HTTP, command, and admin step traces. Filter and export.', icon: ListOrdered },
  { path: '/admin/tools', label: 'Tools', desc: 'Registered tools (name, description, schema). Search by name.', icon: Wrench },
  { path: '/admin/run-lookup', label: 'Run lookup', desc: 'Look up a command run by run ID.', icon: Search },
  { path: '/admin/status', label: 'System status', desc: 'Command API health and availability.', icon: Activity },
  { path: '/admin/capabilities', label: 'Capabilities', desc: 'Catalog of commands by category (data vs agent/simulation).', icon: Layers },
  { path: '/admin/system-overview', label: 'System overview', desc: 'Mermaid diagram and table: status and workload of each part of the app.', icon: GitBranch },
  { path: '/admin/traffic-inspector', label: 'Traffic inspector', desc: 'Live topology and Wireshark-style request stream with distributed tracing.', icon: Radio },
];

export function AdminOverview() {
  return (
    <div className="p-8 max-w-4xl">
      <div className="mb-8">
        <h1 className="text-2xl font-semibold text-stone-900 tracking-tight">Admin</h1>
        <p className="text-stone-600 mt-1">Manage rules, view audit logs, and inspect tools.</p>
      </div>
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {sections.map(({ path, label, desc, icon: Icon }) => (
          <Link key={path} to={path}>
            <Card className="h-full border-stone-200/80 bg-white hover:border-amber-300/60 hover:shadow-md transition-all">
              <CardHeader className="pb-2">
                <div className="flex items-center justify-between">
                  <CardTitle className="text-base flex items-center gap-2">
                    <Icon className="size-4 text-amber-600" />
                    {label}
                  </CardTitle>
                  <ArrowRight className="size-4 text-stone-400" />
                </div>
                <CardDescription className="text-sm">{desc}</CardDescription>
              </CardHeader>
            </Card>
          </Link>
        ))}
      </div>
      <div className="mt-8">
        <Link to="/">
          <Button variant="outline" size="sm">← Back to clinician app</Button>
        </Link>
      </div>
    </div>
  );
}
