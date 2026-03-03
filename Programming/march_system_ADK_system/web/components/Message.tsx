import React, { useRef } from 'react';
import * as Widgets from './widgets';
import { Copy, Download, Check, RotateCw, BarChart3, Clock, Zap, Bookmark } from 'lucide-react';

interface MessageProps {
  message: any;
  density: string;
  showEvidence: boolean;
  showThinking?: boolean;
  onRetryCommand?: (command: string) => void;
  onSavePrompt?: (title: string, prompt: string) => void;
  onRemoveSavedPrompt?: (prompt: string) => void;
  isPromptSaved?: (prompt: string) => boolean;
}

// Helper function to extract text from widget data
function extractTextFromWidget(widget: any): string {
  if (!widget || !widget.data) return '';
  
  const data = widget.data;
  let text = '';
  
  switch (widget.type) {
    case 'W_SUMMARY_CLINICAL':
      text = data.summary || '';
      if (data.keyPoints) {
        text += '\n\nKey Points:\n' + data.keyPoints.map((p: string) => `• ${p}`).join('\n');
      }
      break;
    case 'W_RISK_PROFILE':
      text = `Risk Level: ${data.level}\nScore: ${data.score}\n`;
      if (data.factors) {
        text += '\nFactors:\n' + data.factors.map((f: any) => `• ${f.name}: ${f.value}`).join('\n');
      }
      break;
    case 'W_NOTE_DRAFT':
      if (data.sections) {
        text = data.sections.map((s: any) => `${s.heading}\n${s.content}`).join('\n\n');
      }
      break;
    case 'W_PLAN_DRAFT':
      if (data.phases) {
        text = data.phases.map((p: any) => `${p.name}\n${p.description || ''}`).join('\n\n');
      }
      break;
    case 'W_TWIN_SNAPSHOT':
      text = `Status: ${data.status}\n`;
      if (data.metrics) {
        text += '\nMetrics:\n' + Object.entries(data.metrics).map(([k, v]) => `${k}: ${v}`).join('\n');
      }
      break;
    case 'W_TWIN_SIMULATION':
      text = `Baseline Risk: ${data.baselineRisk}%\nScenario Risk: ${data.scenarioRisk}%\nDelta: ${data.delta}%\n`;
      break;
    case 'W_ALERT_DETAIL':
      text = `${data.title || ''}\n${data.description || ''}\n`;
      if (data.recommendations) {
        text += '\nRecommendations:\n' + data.recommendations.map((r: string) => `• ${r}`).join('\n');
      }
      break;
    case 'W_ASSESS_OVERVIEW':
    case 'W_ASSESS_DETAIL':
      if (data.summary) text = data.summary;
      if (data.findings) {
        text += '\n\nFindings:\n' + data.findings.map((f: any) => `• ${f.label}: ${f.value}`).join('\n');
      }
      break;
    case 'W_ASSESS_REDFLAGS':
      if (data.flags) {
        text = data.flags.map((f: any) => `• ${f.title || f.label}: ${f.description || f.value || ''}`).join('\n');
      }
      break;
    case 'W_RISK_DRIVERS':
      if (data.drivers) {
        text = data.drivers.map((d: any) => `• ${d.name || d.label}: ${d.value || d.impact || ''}`).join('\n');
      }
      break;
    case 'W_ALERT_INBOX':
      if (data.alerts) {
        text = data.alerts.map((a: any) => `• ${a.title || a.id}: ${a.description || a.message || ''}`).join('\n');
      }
      break;
    case 'W_PLAN_DIFF':
      if (data.changes) {
        text = data.changes.map((c: any) => `• ${c.type || 'Change'}: ${c.description || c.detail || ''}`).join('\n');
      }
      break;
    case 'W_SIMULATION_HISTORY':
      if (data.simulations) {
        text = data.simulations.map((s: any) => `• ${s.id || s.date}: ${s.description || s.result || ''}`).join('\n');
      }
      break;
    case 'W_AUDIT':
      if (data.entries) {
        text = data.entries.map((e: any) => `• ${e.action || e.type}: ${e.description || e.detail || ''}`).join('\n');
      }
      break;
    case 'W_FILE_PDF':
      text = `File: ${data.filename || data.name || 'PDF Document'}\n`;
      if (data.description) text += data.description;
      break;
    case 'W_EXPORT_LIST':
      if (data.exports && Array.isArray(data.exports)) {
        text = data.exports.map((e: any) => `• ${e.filename ?? e.exportId ?? 'export'} (${e.type ?? ''}) ${e.timestamp ?? ''}`).join('\n');
      }
      break;
    case 'W_CHART_LINE':
      text = `Chart: ${data.title || 'Data Chart'}\n`;
      if (data.description) text += data.description + '\n';
      if (data.points && Array.isArray(data.points)) {
        text += `Data Points: ${data.points.length}\n`;
        if (data.points.length > 0) {
          const first = data.points[0];
          const last = data.points[data.points.length - 1];
          text += `Range: ${first.date || first.x} to ${last.date || last.x}\n`;
        }
      }
      break;
    case 'W_FHIR_PATIENT':
      if (data.configured && data.found) {
        text = `FHIR Patient: ${data.name ?? data.fhirId ?? data.patientId}\n`;
        if (data.birthDate) text += `Birth date: ${data.birthDate}\n`;
        if (data.gender) text += `Gender: ${data.gender}\n`;
      } else {
        text = data.message ?? 'FHIR patient data not available.';
      }
      break;
    default:
      // Fallback: try to extract any text-like properties
      if (typeof data === 'object') {
        const textProps = Object.entries(data)
          .filter(([_, v]) => typeof v === 'string' && v.length > 0)
          .map(([k, v]) => `${k}: ${v}`)
          .join('\n');
        text = textProps;
      }
  }
  
  return text;
}

// Helper function to check if message has copyable content
function hasCopyableContent(message: any): boolean {
  if (message.answer && message.answer.trim()) return true;
  if (message.widget) {
    const widgetText = extractTextFromWidget(message.widget);
    if (widgetText.trim()) return true;
  }
  return false;
}

export function Message({ message, density, showEvidence, showThinking = true, onRetryCommand, onSavePrompt, onRemoveSavedPrompt, isPromptSaved }: MessageProps) {
  const [isHovered, setIsHovered] = React.useState(false);
  const [isCopied, setIsCopied] = React.useState(false);
  const messageRef = useRef<HTMLDivElement>(null);

  // Helper function to convert widget data to comprehensive HTML
  function widgetToHTML(widget: any): string {
    if (!widget || !widget.data) return '';
    
    const data = widget.data;
    let html = '';
    
    switch (widget.type) {
      case 'W_SUMMARY_CLINICAL':
        html += `<h3>Clinical Summary</h3>`;
        if (data.summary) {
          html += `<p>${data.summary.replace(/\n/g, '<br>')}</p>`;
        }
        if (data.keyPoints && Array.isArray(data.keyPoints)) {
          html += `<h4>Key Points</h4><ul>`;
          data.keyPoints.forEach((p: string) => {
            html += `<li>${p}</li>`;
          });
          html += `</ul>`;
        }
        break;
        
      case 'W_RISK_PROFILE':
        html += `<h3>Risk Profile</h3>`;
        html += `<table><tr><th>Category</th><th>Level</th><th>Description</th></tr>`;
        html += `<tr><td><strong>Overall Risk</strong></td><td>${data.overall || data.level || ''}</td><td>Overall risk assessment</td></tr>`;
        if (data.categories && Array.isArray(data.categories)) {
          data.categories.forEach((cat: any) => {
            html += `<tr><td>${cat.name || ''}</td><td>${cat.level || ''}</td><td>${cat.description || ''}</td></tr>`;
          });
        }
        if (data.factors && Array.isArray(data.factors)) {
          data.factors.forEach((f: any) => {
            html += `<tr><td>${f.name || ''}</td><td>${f.value || ''}</td><td>${f.description || ''}</td></tr>`;
          });
        }
        html += `</table>`;
        break;
        
      case 'W_RISK_DRIVERS':
        html += `<h3>Risk Drivers</h3>`;
        html += `<table><tr><th>Driver</th><th>Contribution</th><th>Trend</th><th>Current</th><th>Baseline</th></tr>`;
        if (data.drivers && Array.isArray(data.drivers)) {
          data.drivers.forEach((driver: any) => {
            html += `<tr>
              <td><strong>${driver.name || ''}</strong><br><small>${driver.description || ''}</small></td>
              <td>${driver.contribution || driver.value || ''}%</td>
              <td>${driver.trend === 'up' ? '↑' : driver.trend === 'down' ? '↓' : '—'}</td>
              <td>${driver.values?.current || driver.current || ''}</td>
              <td>${driver.values?.baseline || driver.baseline || ''}</td>
            </tr>`;
          });
        }
        html += `</table>`;
        break;
        
      case 'W_ALERT_INBOX':
        html += `<h3>Active Alerts (${data.alerts?.length || 0})</h3>`;
        html += `<table><tr><th>ID</th><th>Title</th><th>Severity</th><th>Description</th><th>Category</th><th>Timestamp</th></tr>`;
        if (data.alerts && Array.isArray(data.alerts)) {
          data.alerts.forEach((alert: any) => {
            html += `<tr>
              <td><code>${alert.id || ''}</code></td>
              <td><strong>${alert.title || ''}</strong></td>
              <td>${alert.severity || ''}</td>
              <td>${alert.description || alert.message || ''}</td>
              <td>${alert.category || ''}</td>
              <td>${alert.timestamp || ''}</td>
            </tr>`;
          });
        }
        html += `</table>`;
        break;
        
      case 'W_ALERT_DETAIL':
        html += `<h3>Alert Details</h3>`;
        html += `<table><tr><th>Property</th><th>Value</th></tr>`;
        Object.entries(data).forEach(([key, value]) => {
          if (key !== 'recommendations') {
            html += `<tr><td><strong>${key}</strong></td><td>${typeof value === 'object' ? JSON.stringify(value) : value}</td></tr>`;
          }
        });
        if (data.recommendations && Array.isArray(data.recommendations)) {
          html += `<tr><td><strong>Recommendations</strong></td><td><ul>`;
          data.recommendations.forEach((r: string) => {
            html += `<li>${r}</li>`;
          });
          html += `</ul></td></tr>`;
        }
        html += `</table>`;
        break;
        
      case 'W_ASSESS_OVERVIEW':
        html += `<h3>Assessment Overview</h3>`;
        html += `<table><tr><th>Metric</th><th>Score</th><th>Trend</th></tr>`;
        html += `<tr><td><strong>Overall Score</strong></td><td>${data.overallScore || ''}/100</td><td>${data.trend || ''} ${data.trendValue || ''}</td></tr>`;
        html += `<tr><td>Status</td><td colspan="2">${data.status || ''}</td></tr>`;
        html += `<tr><td>ID</td><td colspan="2"><code>${data.id || ''}</code></td></tr>`;
        html += `<tr><td>Timestamp</td><td colspan="2">${data.timestamp || ''}</td></tr>`;
        if (data.metrics && Array.isArray(data.metrics)) {
          data.metrics.forEach((metric: any) => {
            html += `<tr>
              <td>${metric.name || ''}</td>
              <td>${metric.score || ''}/100</td>
              <td>${metric.trend || ''}</td>
            </tr>`;
          });
        }
        html += `</table>`;
        break;
        
      case 'W_ASSESS_DETAIL':
        html += `<h3>Assessment Detail</h3>`;
        if (data.summary) {
          html += `<p><strong>Summary:</strong> ${data.summary}</p>`;
        }
        if (data.findings && Array.isArray(data.findings)) {
          html += `<table><tr><th>Finding</th><th>Value</th></tr>`;
          data.findings.forEach((f: any) => {
            html += `<tr><td>${f.label || f.name || ''}</td><td>${f.value || ''}</td></tr>`;
          });
          html += `</table>`;
        }
        // Add all other properties
        html += `<h4>All Parameters</h4><table><tr><th>Parameter</th><th>Value</th></tr>`;
        Object.entries(data).forEach(([key, value]) => {
          if (key !== 'summary' && key !== 'findings') {
            html += `<tr><td><strong>${key}</strong></td><td>${typeof value === 'object' ? JSON.stringify(value, null, 2) : value}</td></tr>`;
          }
        });
        html += `</table>`;
        break;
        
      case 'W_ASSESS_REDFLAGS':
        html += `<h3>Red Flags</h3>`;
        html += `<table><tr><th>ID</th><th>Title</th><th>Description</th><th>Metric</th><th>Timestamp</th><th>Requires Acknowledgement</th></tr>`;
        if (data.flags && Array.isArray(data.flags)) {
          data.flags.forEach((flag: any) => {
            html += `<tr>
              <td><code>${flag.id || ''}</code></td>
              <td><strong>${flag.title || flag.label || ''}</strong></td>
              <td>${flag.description || ''}</td>
              <td>${flag.metric || ''}</td>
              <td>${flag.timestamp || ''}</td>
              <td>${flag.requiresAck ? 'Yes' : 'No'}</td>
            </tr>`;
          });
        }
        html += `</table>`;
        break;
        
      case 'W_TWIN_SNAPSHOT':
        html += `<h3>Digital Twin Snapshot</h3>`;
        html += `<table><tr><th>Property</th><th>Value</th></tr>`;
        html += `<tr><td><strong>Status</strong></td><td>${data.status || ''}</td></tr>`;
        if (data.metrics && typeof data.metrics === 'object') {
          Object.entries(data.metrics).forEach(([key, value]) => {
            html += `<tr><td>${key}</td><td>${value}</td></tr>`;
          });
        }
        // Add all other properties
        Object.entries(data).forEach(([key, value]) => {
          if (key !== 'status' && key !== 'metrics') {
            html += `<tr><td><strong>${key}</strong></td><td>${typeof value === 'object' ? JSON.stringify(value, null, 2) : value}</td></tr>`;
          }
        });
        html += `</table>`;
        break;
        
      case 'W_TWIN_SIMULATION':
        html += `<h3>Simulation Result</h3>`;
        html += `<table><tr><th>Metric</th><th>Value</th></tr>`;
        html += `<tr><td>Baseline Risk</td><td>${data.baselineRisk || ''}%</td></tr>`;
        html += `<tr><td>Scenario Risk</td><td>${data.scenarioRisk || ''}%</td></tr>`;
        html += `<tr><td>Delta</td><td>${data.delta || ''}%</td></tr>`;
        html += `<tr><td>Confidence</td><td>${data.confidence || ''}%</td></tr>`;
        html += `<tr><td>Completeness</td><td>${data.completeness || ''}%</td></tr>`;
        if (data.horizon) html += `<tr><td>Horizon</td><td>${data.horizon}</td></tr>`;
        if (data.doseAdjustment) {
          html += `<tr><td colspan="2"><strong>Dose Adjustment:</strong> ${data.doseAdjustment}</td></tr>`;
        }
        if (data.sources && Array.isArray(data.sources)) {
          html += `<tr><td colspan="2"><strong>Sources:</strong> ${data.sources.join(', ')}</td></tr>`;
        }
        html += `</table>`;
        break;
        
      case 'W_SIMULATION_HISTORY':
        html += `<h3>Simulation History</h3>`;
        html += `<table><tr><th>SIM-ID</th><th>Scenario</th><th>Horizon</th><th>Key Delta</th><th>Timestamp</th></tr>`;
        if (data.simulations && Array.isArray(data.simulations)) {
          data.simulations.forEach((sim: any) => {
            html += `<tr>
              <td><code>${sim.id || ''}</code></td>
              <td>${sim.scenario || ''}</td>
              <td>${sim.horizon || ''}</td>
              <td>${sim.delta || ''}</td>
              <td>${sim.timestamp || ''}</td>
            </tr>`;
          });
        }
        html += `</table>`;
        break;
        
      case 'W_NOTE_DRAFT':
        html += `<h3>Clinical Note Draft</h3>`;
        html += `<table><tr><th>Property</th><th>Value</th></tr>`;
        html += `<tr><td>Type</td><td>${data.type || ''}</td></tr>`;
        html += `<tr><td>Patient</td><td>${data.patientName || ''}</td></tr>`;
        html += `<tr><td>Date</td><td>${data.date || ''}</td></tr>`;
        if (data.noteId) html += `<tr><td>Note ID</td><td><code>${data.noteId}</code></td></tr>`;
        html += `</table>`;
        if (data.sections && Array.isArray(data.sections)) {
          html += `<h4>Sections</h4>`;
          data.sections.forEach((section: any, idx: number) => {
            html += `<div style="margin: 15px 0; padding: 10px; border-left: 3px solid #3b82f6;">`;
            html += `<h5>${section.heading || `Section ${idx + 1}`}</h5>`;
            html += `<p style="white-space: pre-wrap;">${section.content || ''}</p>`;
            html += `</div>`;
          });
        }
        break;
        
      case 'W_PLAN_DRAFT':
        html += `<h3>Treatment Plan Draft</h3>`;
        html += `<table><tr><th>Property</th><th>Value</th></tr>`;
        Object.entries(data).forEach(([key, value]) => {
          if (key !== 'phases') {
            html += `<tr><td><strong>${key}</strong></td><td>${typeof value === 'object' ? JSON.stringify(value) : value}</td></tr>`;
          }
        });
        html += `</table>`;
        if (data.phases && Array.isArray(data.phases)) {
          html += `<h4>Phases</h4>`;
          data.phases.forEach((phase: any, idx: number) => {
            html += `<div style="margin: 15px 0; padding: 10px; border-left: 3px solid #10b981;">`;
            html += `<h5>${phase.name || `Phase ${idx + 1}`}</h5>`;
            if (phase.description) html += `<p>${phase.description}</p>`;
            if (phase.duration) html += `<p><strong>Duration:</strong> ${phase.duration}</p>`;
            if (phase.medications && Array.isArray(phase.medications)) {
              html += `<ul>`;
              phase.medications.forEach((med: any) => {
                html += `<li>${typeof med === 'string' ? med : JSON.stringify(med)}</li>`;
              });
              html += `</ul>`;
            }
            html += `</div>`;
          });
        }
        break;
        
      case 'W_PLAN_DIFF':
        html += `<h3>Plan Changes</h3>`;
        html += `<table><tr><th>Type</th><th>Description</th><th>Details</th></tr>`;
        if (data.changes && Array.isArray(data.changes)) {
          data.changes.forEach((change: any) => {
            html += `<tr>
              <td>${change.type || ''}</td>
              <td>${change.description || change.detail || ''}</td>
              <td>${typeof change === 'object' ? JSON.stringify(change, null, 2) : change}</td>
            </tr>`;
          });
        }
        html += `</table>`;
        break;
        
      case 'W_AUDIT':
        html += `<h3>Action Audit</h3>`;
        html += `<table><tr><th>Property</th><th>Value</th></tr>`;
        html += `<tr><td>Action</td><td><strong>${data.action || ''}</strong></td></tr>`;
        if (data.target) html += `<tr><td>Target</td><td>${data.target}</td></tr>`;
        if (data.user) html += `<tr><td>User</td><td>${data.user}</td></tr>`;
        if (data.timestamp) html += `<tr><td>Timestamp</td><td>${data.timestamp}</td></tr>`;
        if (data.auditId) html += `<tr><td>Audit ID</td><td><code>${data.auditId}</code></td></tr>`;
        if (data.details && Array.isArray(data.details)) {
          data.details.forEach((detail: any) => {
            html += `<tr><td>${detail.label || ''}</td><td>${detail.value || ''}</td></tr>`;
          });
        }
        html += `</table>`;
        break;
        
      case 'W_FILE_PDF':
        html += `<h3>PDF Document</h3>`;
        html += `<table><tr><th>Property</th><th>Value</th></tr>`;
        Object.entries(data).forEach(([key, value]) => {
          html += `<tr><td><strong>${key}</strong></td><td>${typeof value === 'object' ? JSON.stringify(value) : value}</td></tr>`;
        });
        html += `</table>`;
        break;
        
      case 'W_CHART_LINE':
        html += `<h3>Chart: ${data.title || 'Data Chart'}</h3>`;
        if (data.description) html += `<p>${data.description}</p>`;
        if (data.points && Array.isArray(data.points)) {
          html += `<table><tr><th>Date</th><th>Value</th></tr>`;
          data.points.forEach((point: any) => {
            html += `<tr>
              <td>${point.date || point.x || ''}</td>
              <td>${point.value || point.y || ''}</td>
            </tr>`;
          });
          html += `</table>`;
        }
        break;
      case 'W_FHIR_PATIENT':
        html += `<h3>FHIR Patient</h3>`;
        if (data.configured && data.found) {
          if (data.name) html += `<p><strong>Name:</strong> ${data.name}</p>`;
          if (data.fhirId) html += `<p><strong>FHIR ID:</strong> <code>${data.fhirId}</code></p>`;
          if (data.birthDate) html += `<p><strong>Birth date:</strong> ${data.birthDate}</p>`;
          if (data.gender) html += `<p><strong>Gender:</strong> ${data.gender}</p>`;
          html += `<p><strong>Patient ID:</strong> <code>${data.patientId}</code></p>`;
        } else {
          html += `<p>${data.message ?? 'FHIR patient data not available.'}</p>`;
        }
        break;
        
      default:
        // For any other widget type, create a comprehensive table of all data
        html += `<h3>${widget.type.replace(/_/g, ' ')}</h3>`;
        html += `<table><tr><th>Parameter</th><th>Value</th></tr>`;
        const flattenObject = (obj: any, prefix = ''): Array<[string, any]> => {
          const result: Array<[string, any]> = [];
          for (const key in obj) {
            if (obj.hasOwnProperty(key)) {
              const newKey = prefix ? `${prefix}.${key}` : key;
              if (typeof obj[key] === 'object' && obj[key] !== null && !Array.isArray(obj[key])) {
                result.push(...flattenObject(obj[key], newKey));
              } else if (Array.isArray(obj[key])) {
                obj[key].forEach((item: any, idx: number) => {
                  if (typeof item === 'object' && item !== null) {
                    result.push(...flattenObject(item, `${newKey}[${idx}]`));
                  } else {
                    result.push([`${newKey}[${idx}]`, item]);
                  }
                });
              } else {
                result.push([newKey, obj[key]]);
              }
            }
          }
          return result;
        };
        flattenObject(data).forEach(([key, value]) => {
          html += `<tr><td><strong>${key}</strong></td><td>${typeof value === 'object' ? JSON.stringify(value, null, 2) : String(value)}</td></tr>`;
        });
        html += `</table>`;
    }
    
    return html;
  }

  const handleDownload = async () => {
    // Get the message element
    const messageElement = messageRef.current;
    if (!messageElement) return;

    // Create comprehensive HTML content for PDF
    let htmlContent = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="UTF-8">
          <title>Message Export - ${new Date().toLocaleDateString()}</title>
          <style>
            @media print {
              body { margin: 0; padding: 15px; }
              .page-break { page-break-after: always; }
            }
            body { 
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
              padding: 20px; 
              color: #333; 
              max-width: 800px;
              margin: 0 auto;
            }
            h1 { font-size: 20px; margin-bottom: 15px; border-bottom: 2px solid #333; padding-bottom: 10px; }
            h2 { font-size: 16px; margin-top: 25px; margin-bottom: 12px; color: #555; border-bottom: 1px solid #ddd; padding-bottom: 5px; }
            h3 { font-size: 14px; margin-top: 20px; margin-bottom: 10px; color: #666; }
            h4 { font-size: 13px; margin-top: 15px; margin-bottom: 8px; color: #777; }
            h5 { font-size: 12px; margin-top: 12px; margin-bottom: 6px; color: #888; }
            p { margin: 10px 0; line-height: 1.6; }
            .evidence { 
              font-size: 12px; 
              color: #666; 
              margin-top: 20px; 
              padding: 15px; 
              border-top: 2px solid #ddd; 
              background: #f9f9f9;
            }
            .widget { 
              margin: 25px 0; 
              padding: 20px; 
              border: 1px solid #ddd; 
              border-radius: 8px; 
              background: #f9f9f9; 
              page-break-inside: avoid;
            }
            table { 
              width: 100%; 
              border-collapse: collapse; 
              margin: 15px 0; 
              font-size: 12px;
              page-break-inside: avoid;
            }
            th, td { 
              padding: 10px; 
              text-align: left; 
              border: 1px solid #ddd; 
            }
            th { 
              background: #f0f0f0; 
              font-weight: 600; 
              color: #333;
            }
            tr:nth-child(even) { background: #fafafa; }
            code { 
              background: #f4f4f4; 
              padding: 2px 6px; 
              border-radius: 3px; 
              font-family: 'Monaco', 'Courier New', monospace;
              font-size: 11px;
            }
            ul, ol { margin: 10px 0; padding-left: 25px; }
            li { margin: 5px 0; line-height: 1.5; }
            pre { 
              white-space: pre-wrap; 
              font-family: 'Monaco', 'Courier New', monospace;
              background: #f4f4f4;
              padding: 10px;
              border-radius: 4px;
              overflow-x: auto;
            }
          </style>
        </head>
        <body>
    `;

    // Add answer text
    if (message.answer) {
      htmlContent += `<h1>Response</h1><p>${message.answer.replace(/\n/g, '<br>')}</p>`;
    }

    // Add widget content with all parameters, tables, and data
    if (message.widget) {
      htmlContent += `<div class="widget">`;
      htmlContent += widgetToHTML(message.widget);
      
      // Also include raw JSON data for complete reference
      htmlContent += `<h4>Complete Data (JSON)</h4>`;
      htmlContent += `<pre>${JSON.stringify(message.widget.data, null, 2)}</pre>`;
      
      htmlContent += `</div>`;
    }

    // Add suggestions
    if (message.suggestions) {
      htmlContent += `<div style="margin: 20px 0; padding: 15px; background: #e3f2fd; border-left: 4px solid #2196f3; border-radius: 4px;">`;
      htmlContent += `<h3>Next Steps</h3>`;
      htmlContent += `<p>${message.suggestions}</p>`;
      htmlContent += `</div>`;
    }

    // Add evidence with all parameters
    if (showEvidence && message.evidence) {
      htmlContent += `<div class="evidence">`;
      htmlContent += `<h3>Evidence & Metadata</h3>`;
      htmlContent += `<table><tr><th>Property</th><th>Value</th></tr>`;
      Object.entries(message.evidence).forEach(([key, value]) => {
        htmlContent += `<tr><td><strong>${key}</strong></td><td>${value}</td></tr>`;
      });
      htmlContent += `</table>`;
      htmlContent += `</div>`;
    }

    // Add complete message metadata
    htmlContent += `<div class="evidence" style="margin-top: 30px;">`;
    htmlContent += `<h3>Message Metadata</h3>`;
    htmlContent += `<table><tr><th>Property</th><th>Value</th></tr>`;
    htmlContent += `<tr><td>Message ID</td><td><code>${message.id || 'N/A'}</code></td></tr>`;
    htmlContent += `<tr><td>Role</td><td>${message.role || 'assistant'}</td></tr>`;
    if (message.timestamp) {
      htmlContent += `<tr><td>Timestamp</td><td>${new Date(message.timestamp).toLocaleString()}</td></tr>`;
    }
    htmlContent += `</table>`;
    htmlContent += `</div>`;

    htmlContent += `
        </body>
      </html>
    `;

    // Create a new window with the HTML content for printing/saving as PDF
    const printWindow = window.open('', '_blank');
    if (printWindow) {
      printWindow.document.write(htmlContent);
      printWindow.document.close();
      
      // Wait for content to load, then trigger print dialog (which allows saving as PDF)
      printWindow.onload = () => {
        setTimeout(() => {
          printWindow.print();
        }, 500);
      };
      
      // Also set up a fallback timeout
      setTimeout(() => {
        if (printWindow && !printWindow.closed) {
          printWindow.print();
        }
      }, 1000);
    } else {
      // Fallback: download as HTML file (can be opened and saved as PDF)
      const blob = new Blob([htmlContent], { type: 'text/html' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `message-${Date.now()}.html`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      setTimeout(() => URL.revokeObjectURL(url), 1000);
    }
  };

  const handleCopy = async () => {
    let content = '';
    
    // Add answer text
    if (message.answer) {
      content += message.answer + '\n\n';
    }
    
    // Add widget text
    if (message.widget) {
      const widgetText = extractTextFromWidget(message.widget);
      if (widgetText) {
        content += widgetText + '\n\n';
      }
    }
    
    // If no content, try to extract from DOM
    if (!content.trim() && messageRef.current) {
      const textContent = messageRef.current.innerText || messageRef.current.textContent || '';
      if (textContent.trim()) {
        content = textContent;
      }
    }
    
    if (!content.trim()) {
      console.warn('No copyable content found');
      return;
    }
    
    try {
      // Try modern clipboard API first
      if (navigator.clipboard && navigator.clipboard.writeText) {
        await navigator.clipboard.writeText(content.trim());
      } else {
        // Fallback for older browsers or restricted contexts
        const textArea = document.createElement('textarea');
        textArea.value = content.trim();
        textArea.style.position = 'fixed';
        textArea.style.left = '-999999px';
        textArea.style.top = '-999999px';
        document.body.appendChild(textArea);
        textArea.focus();
        textArea.select();
        
        try {
          document.execCommand('copy');
        } finally {
          document.body.removeChild(textArea);
        }
      }
      
      setIsCopied(true);
      setTimeout(() => setIsCopied(false), 2000);
    } catch (err) {
      console.error('Failed to copy:', err);
      // Still show the copied state briefly to indicate the attempt
      setIsCopied(true);
      setTimeout(() => setIsCopied(false), 1000);
    }
  };

  const canCopy = hasCopyableContent(message);

  if (message.role === 'user') {
    const userContent = (message.content || '').trim();
    const saved = isPromptSaved?.(userContent) ?? false;
    return (
      <div
        data-testid="message-user"
        className="flex justify-end relative group"
        onMouseEnter={() => setIsHovered(true)}
        onMouseLeave={() => setIsHovered(false)}
      >
        {isHovered && userContent && (onSavePrompt || onRemoveSavedPrompt) && (
          <div className="absolute -top-2 right-0 flex items-center gap-0.5 bg-card border border-border rounded-lg px-1.5 py-1 z-10 shadow-lg">
            {saved ? (
              <button
                type="button"
                onClick={() => onRemoveSavedPrompt?.(userContent)}
                className="p-1.5 hover:bg-accent rounded transition-colors text-primary"
                title="Remove from saved prompts"
                aria-label="Remove from saved prompts"
              >
                <Bookmark className="w-4 h-4 fill-current" />
              </button>
            ) : (
              <button
                type="button"
                onClick={() => onSavePrompt?.(userContent.slice(0, 40) + (userContent.length > 40 ? '…' : ''), userContent)}
                className="p-1.5 hover:bg-accent rounded transition-colors text-muted-foreground"
                title="Add to saved prompts"
                aria-label="Add to saved prompts"
              >
                <Bookmark className="w-4 h-4" />
              </button>
            )}
          </div>
        )}
        <div className="bg-gradient-to-br from-teal-500 to-teal-600 dark:from-teal-600 dark:to-teal-700 rounded-2xl px-4 py-3 max-w-2xl shadow-sm hover:shadow-md transition-shadow">
          <div className="text-sm text-white leading-relaxed font-medium">{message.content}</div>
        </div>
      </div>
    );
  }

  return (
    <div
      data-testid="message-assistant"
      ref={messageRef}
      className="space-y-3 relative group"
      onMouseEnter={() => setIsHovered(true)}
      onMouseLeave={() => setIsHovered(false)}
    >
      {/* Download/Copy buttons (ChatGPT-style) */}
      {isHovered && (
        <div className="absolute -top-2 right-0 flex items-center gap-0.5 bg-card border border-border rounded-lg px-1.5 py-1 z-10 shadow-lg">
          {canCopy && (
            <button
              onClick={handleCopy}
              className="p-1.5 hover:bg-slate-50 hover:bg-accent rounded transition-colors text-muted-foreground"
              title={isCopied ? "Copied!" : "Copy to clipboard"}
            >
              {isCopied ? (
                <Check className="w-4 h-4 text-emerald-600 dark:text-emerald-200" />
              ) : (
                <Copy className="w-4 h-4" />
              )}
            </button>
          )}
          <button
            onClick={handleDownload}
            className="p-1.5 hover:bg-slate-50 hover:bg-accent rounded transition-colors text-muted-foreground"
            title="Download as PDF"
          >
            <Download className="w-4 h-4" />
          </button>
        </div>
      )}

      {/* Main message content card */}
      <div className="bg-card rounded-2xl border border-border p-4 shadow-sm hover:shadow-md transition-all">
        {showThinking && message.thinkingText && (
          <div className="mb-3 rounded-lg border border-amber-200 bg-amber-50/70 dark:bg-amber-900/20 dark:border-amber-800 p-3">
            <div className="mb-1 text-[11px] font-semibold uppercase tracking-wide text-amber-700 dark:text-amber-300">
              Thinking {message.streamPhase === 'thinking' ? '(live)' : ''}
            </div>
            <pre className="whitespace-pre-wrap text-xs text-amber-900 dark:text-amber-100 font-sans leading-relaxed m-0">
              {String(message.thinkingText)}
            </pre>
          </div>
        )}

        {message.isStreaming && (
          <div className="mb-2 text-[11px] text-muted-foreground">
            {message.streamPhase === 'thinking' ? 'Streaming thinking in real time…' : 'Streaming final answer…'}
          </div>
        )}

        {/* Three-line preface */}
        {message.answer && (
          <div className="text-sm sm:text-base text-slate-800 dark:text-slate-100 leading-relaxed mb-3 font-medium">{message.answer}</div>
        )}
        
        {showEvidence && message.evidence && (
          <div className="text-[11px] sm:text-xs text-slate-500 dark:text-slate-100 flex items-center gap-2 sm:gap-3 flex-wrap pb-2 border-b border-border mb-3">
            <div className="flex items-center gap-1">
              <BarChart3 className="w-3.5 h-3.5" />
              <span>{message.evidence.sources} sources</span>
            </div>
            <span>•</span>
            <div className="flex items-center gap-1">
              <Clock className="w-3.5 h-3.5" />
              <span>Generated {message.evidence.generated}</span>
            </div>
            {message.evidence.completeness && (
              <>
                <span>•</span>
                <div className="flex items-center gap-1">
                  <Check className="w-3.5 h-3.5" />
                  <span>Completeness {message.evidence.completeness}%</span>
                </div>
              </>
            )}
            {message.evidence.confidence && (
              <>
                <span>•</span>
                <div className="flex items-center gap-1">
                  <Zap className="w-3.5 h-3.5" />
                  <span>Confidence {message.evidence.confidence}%</span>
                </div>
              </>
            )}
            {message.evidence.runId && (
              <>
                <span>•</span>
                <span className="font-mono text-[9px] sm:text-xs bg-muted px-2 py-1 rounded">ID: {message.evidence.runId.slice(0, 8)}</span>
              </>
            )}
          </div>
        )}

        {message.suggestions && (
          <div className="text-sm text-muted-foreground italic bg-muted px-3 py-2 rounded-lg mb-3 flex items-start gap-2">
            <Zap className="w-4 h-4 flex-shrink-0 mt-0.5" />
            <span>Next: {message.suggestions}</span>
          </div>
        )}

        {message.retryCommand && onRetryCommand && (
          <div className="mt-3 pt-3 border-t border-border">
            <button
              type="button"
              onClick={() => onRetryCommand(message.retryCommand)}
              className="inline-flex items-center gap-2 px-3 py-2 text-sm font-medium text-white bg-gradient-to-r from-teal-500 to-teal-600 hover:from-teal-600 hover:to-teal-700 rounded-lg transition-all shadow-sm hover:shadow-md"
            >
              <RotateCw className="w-4 h-4" />
              Retry Command
            </button>
          </div>
        )}
      </div>

      {/* Widget rendering */}
      {message.widget && (
        <div className="mt-4 mb-4">
          {renderWidget(message.widget)}
        </div>
      )}
    </div>
  );
}

function renderWidget(widget: any) {
  switch (widget.type) {
    case 'W_SUMMARY_CLINICAL':
      return <Widgets.SummaryClinical data={widget.data} />;
    case 'W_RISK_PROFILE':
      return <Widgets.RiskProfile data={widget.data} />;
    case 'W_RISK_DRIVERS':
      return <Widgets.RiskDrivers data={widget.data} />;
    case 'W_ALERT_INBOX':
      return <Widgets.AlertInbox data={widget.data} />;
    case 'W_ALERT_DETAIL':
      return <Widgets.AlertDetail data={widget.data} />;
    case 'W_ASSESS_OVERVIEW':
      return <Widgets.AssessOverview data={widget.data} />;
    case 'W_ASSESS_DETAIL':
      return <Widgets.AssessDetail data={widget.data} />;
    case 'W_ASSESS_REDFLAGS':
      return <Widgets.AssessRedFlags data={widget.data} />;
    case 'W_TWIN_SNAPSHOT':
      return <Widgets.TwinSnapshot data={widget.data} />;
    case 'W_TWIN_SIMULATION':
      return <Widgets.TwinSimulation data={widget.data} />;
    case 'W_SIMULATION_HISTORY':
      return <Widgets.SimulationHistory data={widget.data} />;
    case 'W_PLAN_DRAFT':
      return <Widgets.PlanDraft data={widget.data} />;
    case 'W_PLAN_DIFF':
      return <Widgets.PlanDiff data={widget.data} />;
    case 'W_NOTE_DRAFT':
      return <Widgets.NoteDraft data={widget.data} />;
    case 'W_AUDIT':
      return <Widgets.Audit data={widget.data} />;
    case 'W_FILE_PDF':
      return <Widgets.FilePdf data={widget.data} />;
    case 'W_EXPORT_LIST':
      return <Widgets.ExportList data={widget.data} />;
    case 'W_CHART_LINE':
      return <Widgets.ChartLine data={widget.data} />;
    case 'W_FHIR_PATIENT':
      return <Widgets.FhirPatient data={widget.data} />;
    default:
      return null;
  }
}