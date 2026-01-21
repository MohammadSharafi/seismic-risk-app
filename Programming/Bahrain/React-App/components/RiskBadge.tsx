import { RiskTier } from '../App';

interface RiskBadgeProps {
  tier: RiskTier;
  size?: 'sm' | 'md' | 'lg';
}

export function RiskBadge({ tier, size = 'md' }: RiskBadgeProps) {
  const sizeClasses = {
    sm: 'px-2 py-1 text-xs',
    md: 'px-3 py-1 text-sm',
    lg: 'px-4 py-2 text-base'
  };

  const colorClasses = {
    Critical: 'bg-red-900 text-white border-red-950',
    High: 'bg-red-100 text-red-800 border-red-200',
    Medium: 'bg-amber-100 text-amber-800 border-amber-200',
    Low: 'bg-green-100 text-green-800 border-green-200'
  };

  const getDisplayName = (tier: RiskTier): string => {
    switch (tier) {
      case 'Critical': return 'Critical Alert';
      case 'High': return 'High Alert';
      case 'Medium': return 'Moderate Alert';
      case 'Low': return 'Low Alert';
      default: return 'Moderate Alert';
    }
  };

  return (
    <span className={`inline-flex items-center font-medium rounded border ${sizeClasses[size]} ${colorClasses[tier]}`}>
      <span className={`w-2 h-2 rounded-full mr-2 ${tier === 'Critical' ? 'bg-red-900' : tier === 'High' ? 'bg-red-500' : tier === 'Medium' ? 'bg-amber-500' : 'bg-green-500'}`}></span>
      {getDisplayName(tier)}
    </span>
  );
}
