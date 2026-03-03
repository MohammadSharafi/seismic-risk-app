import React, { useState, useEffect } from 'react';
import {
  listRules,
  createRule,
  updateRule,
  deleteRule,
  type RuleItem,
} from '../../api/adminApi';
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from '../ui/card';
import { Button } from '../ui/button';
import { Input } from '../ui/input';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '../ui/table';
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '../ui/dialog';
import { Plus, Pencil, Trash2, Loader2 } from 'lucide-react';

export function AdminRules() {
  const [rules, setRules] = useState<RuleItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [createOpen, setCreateOpen] = useState(false);
  const [editRule, setEditRule] = useState<RuleItem | null>(null);
  const [deleteId, setDeleteId] = useState<number | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [formCommand, setFormCommand] = useState('');
  const [formRoles, setFormRoles] = useState('');
  const [formTenantId, setFormTenantId] = useState('');

  const load = async () => {
    setLoading(true);
    setError(null);
    try {
      const list = await listRules();
      setRules(list);
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Failed to load rules');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    load();
  }, []);

  const openCreate = () => {
    setFormCommand('');
    setFormRoles('');
    setFormTenantId('');
    setCreateOpen(true);
  };

  const openEdit = (r: RuleItem) => {
    setEditRule(r);
    setFormCommand(r.command);
    setFormRoles(r.allowedRoles || '');
    setFormTenantId(r.tenantId || '');
  };

  const handleCreate = async () => {
    if (!formCommand.trim()) return;
    setSubmitting(true);
    try {
      await createRule({
        command: formCommand.trim(),
        allowedRoles: formRoles.trim(),
        tenantId: formTenantId.trim() || null,
      });
      setCreateOpen(false);
      load();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Create failed');
    } finally {
      setSubmitting(false);
    }
  };

  const handleUpdate = async () => {
    if (!editRule) return;
    setSubmitting(true);
    try {
      await updateRule(editRule.id, formRoles.trim());
      setEditRule(null);
      load();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Update failed');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!confirm('Delete this rule?')) return;
    setSubmitting(true);
    try {
      await deleteRule(id);
      setDeleteId(null);
      load();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Delete failed');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="p-8">
      <div className="mb-6">
        <h1 className="text-2xl font-semibold text-stone-900 tracking-tight">Command rules</h1>
        <p className="text-stone-600 text-sm mt-1">
          Control which roles can run which commands. Special rule <code className="bg-stone-100 px-1 rounded">_audit_view</code> controls who can view audit logs.
        </p>
      </div>

      {error && (
        <div className="mb-4 p-3 rounded-lg bg-red-50 border border-red-200 text-red-800 text-sm">
          {error}
        </div>
      )}

      <Card className="border-stone-200/80 bg-white">
        <CardHeader className="pb-4">
          <div className="flex items-center justify-between">
            <div>
              <CardTitle className="text-base">Rules</CardTitle>
              <CardDescription>Add, edit, or remove command–role rules. Changes take effect after cache TTL.</CardDescription>
            </div>
            <Button onClick={openCreate} size="sm" className="bg-amber-600 hover:bg-amber-700 text-white">
              <Plus className="size-4 mr-1.5" />
              Add rule
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="flex items-center gap-2 py-8 text-stone-500">
              <Loader2 className="size-5 animate-spin" />
              Loading…
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow className="border-stone-200">
                  <TableHead className="text-stone-600">Command</TableHead>
                  <TableHead className="text-stone-600">Allowed roles</TableHead>
                  <TableHead className="text-stone-600">Tenant</TableHead>
                  <TableHead className="text-stone-600 w-24">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {rules.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={4} className="text-stone-500 py-8 text-center">
                      No rules. Add one to restrict commands by role.
                    </TableCell>
                  </TableRow>
                ) : (
                  rules.map((r) => (
                    <TableRow key={r.id} className="border-stone-100">
                      <TableCell className="font-medium text-stone-900">{r.command}</TableCell>
                      <TableCell className="text-stone-700">{r.allowedRoles || '—'}</TableCell>
                      <TableCell className="text-stone-600">{r.tenantId || 'global'}</TableCell>
                      <TableCell>
                        <div className="flex items-center gap-1">
                          <Button variant="ghost" size="icon" className="size-8" onClick={() => openEdit(r)} aria-label="Edit">
                            <Pencil className="size-4" />
                          </Button>
                          <Button variant="ghost" size="icon" className="size-8 text-red-600 hover:text-red-700" onClick={() => setDeleteId(r.id)} aria-label="Delete">
                            <Trash2 className="size-4" />
                          </Button>
                        </div>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>

      {/* Create dialog */}
      <Dialog open={createOpen} onOpenChange={setCreateOpen}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Add rule</DialogTitle>
            <DialogDescription>Command (e.g. /simulate or _audit_view) and comma-separated roles.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-2">
            <div>
              <label className="text-sm font-medium text-stone-700">Command</label>
              <Input
                className="mt-1"
                value={formCommand}
                onChange={(e) => setFormCommand(e.target.value)}
                placeholder="/simulate or _audit_view"
              />
            </div>
            <div>
              <label className="text-sm font-medium text-stone-700">Allowed roles</label>
              <Input
                className="mt-1"
                value={formRoles}
                onChange={(e) => setFormRoles(e.target.value)}
                placeholder="clinician,admin"
              />
            </div>
            <div>
              <label className="text-sm font-medium text-stone-700">Tenant (optional)</label>
              <Input
                className="mt-1"
                value={formTenantId}
                onChange={(e) => setFormTenantId(e.target.value)}
                placeholder="Leave empty for global"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setCreateOpen(false)}>Cancel</Button>
            <Button onClick={handleCreate} disabled={submitting || !formCommand.trim()} className="bg-amber-600 hover:bg-amber-700">
              {submitting ? <Loader2 className="size-4 animate-spin" /> : 'Create'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Edit dialog */}
      <Dialog open={!!editRule} onOpenChange={(open) => !open && setEditRule(null)}>
        <DialogContent className="sm:max-w-md">
          <DialogHeader>
            <DialogTitle>Edit rule</DialogTitle>
            <DialogDescription>Update allowed roles for {editRule?.command}.</DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-2">
            <div>
              <label className="text-sm font-medium text-stone-700">Allowed roles</label>
              <Input
                className="mt-1"
                value={formRoles}
                onChange={(e) => setFormRoles(e.target.value)}
                placeholder="clinician,admin"
              />
            </div>
          </div>
          <DialogFooter>
            <Button variant="outline" onClick={() => setEditRule(null)}>Cancel</Button>
            <Button onClick={handleUpdate} disabled={submitting} className="bg-amber-600 hover:bg-amber-700">
              {submitting ? <Loader2 className="size-4 animate-spin" /> : 'Save'}
            </Button>
          </DialogFooter>
        </DialogContent>
      </Dialog>

      {/* Delete confirm */}
      {deleteId !== null && (
        <Dialog open onOpenChange={(open) => !open && setDeleteId(null)}>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Delete rule?</DialogTitle>
              <DialogDescription>This cannot be undone. Rule changes are audited.</DialogDescription>
            </DialogHeader>
            <DialogFooter>
              <Button variant="outline" onClick={() => setDeleteId(null)}>Cancel</Button>
              <Button variant="destructive" onClick={() => handleDelete(deleteId)} disabled={submitting}>
                {submitting ? <Loader2 className="size-4 animate-spin" /> : 'Delete'}
              </Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}
    </div>
  );
}
