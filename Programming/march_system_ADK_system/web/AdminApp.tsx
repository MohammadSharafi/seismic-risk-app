import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { AdminLayout } from './components/admin/AdminLayout';
import { AdminOverview } from './components/admin/AdminOverview';
import { AdminRules } from './components/admin/AdminRules';
import { AdminCommandAudit } from './components/admin/AdminCommandAudit';
import { AdminStepAudit } from './components/admin/AdminStepAudit';
import { AdminTools } from './components/admin/AdminTools';
import { AdminRunLookup } from './components/admin/AdminRunLookup';
import { AdminStatus } from './components/admin/AdminStatus';
import { AdminCapabilities } from './components/admin/AdminCapabilities';
import { AdminSystemOverview } from './components/admin/AdminSystemOverview';

export function AdminApp() {
  return (
    <Routes>
      <Route path="/admin" element={<AdminLayout />}>
        <Route index element={<AdminOverview />} />
        <Route path="rules" element={<AdminRules />} />
        <Route path="command-audit" element={<AdminCommandAudit />} />
        <Route path="step-audit" element={<AdminStepAudit />} />
        <Route path="tools" element={<AdminTools />} />
        <Route path="run-lookup" element={<AdminRunLookup />} />
        <Route path="status" element={<AdminStatus />} />
        <Route path="capabilities" element={<AdminCapabilities />} />
        <Route path="system-overview" element={<AdminSystemOverview />} />
        <Route path="*" element={<Navigate to="/admin" replace />} />
      </Route>
    </Routes>
  );
}
