import { MessageSquare } from 'lucide-react';
import { Patient } from '../App';

interface ClinicalDiscussionPreviewProps {
  patient: Patient;
  visitId?: string | null;
  onOpenFull: () => void;
}

export function ClinicalDiscussionPreview({ patient, visitId, onOpenFull }: ClinicalDiscussionPreviewProps) {
  // Chat messages are ephemeral - no history to load
  // Always show the empty state with a nice UI
  
  return (
    <div>
      <div className="flex items-center gap-2 mb-4">
        <MessageSquare className="w-4 h-4 text-gray-400" />
        <p className="text-sm font-medium text-gray-700">Clinical Discussion</p>
      </div>
      
      <div className="text-center py-8 bg-gradient-to-br from-blue-50 to-purple-50 rounded-lg border border-blue-100">
        <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-blue-100 mb-4">
          <MessageSquare className="w-8 h-8 text-blue-600" />
        </div>
        <h3 className="text-lg font-semibold text-gray-800 mb-2">Start a Clinical Discussion</h3>
        <p className="text-sm text-gray-600 mb-6 max-w-sm mx-auto px-4">
          Have a conversation with the AI Clinical Assistant about this patient. Messages are private and ephemeral.
        </p>
        <button 
          onClick={onOpenFull}
          className="px-6 py-3 bg-blue-600 text-white font-medium rounded-lg hover:bg-blue-700 transition-colors shadow-sm hover:shadow-md text-sm">
          Open Chat
        </button>
      </div>
    </div>
  );
}
