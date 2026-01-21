import { Status } from '../App';

interface StatusChipProps {
  status: Status;
}

export function StatusChip({ status }: StatusChipProps) {
  const colorClasses = {
    'Monitoring': 'bg-blue-100 text-blue-800',
    'Needs Review': 'bg-orange-100 text-orange-800',
    'Action Taken': 'bg-green-100 text-green-800'
  };

  return (
    <span className={`inline-flex px-3 py-1 text-xs font-medium rounded-full ${colorClasses[status]}`}>
      {status}
    </span>
  );
}
