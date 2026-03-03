// API Configuration
// In production, this will be set from environment variables at build time
// In development, defaults to localhost

const getApiBaseUrl = (): string => {
  // Check if we're in production - use environment variable (baked in at build time)
  let envUrl = (import.meta as any).env?.VITE_API_BASE_URL;
  if (envUrl && (envUrl = envUrl.trim()) !== '') {
    // Ensure base URL ends with /api so paths like /auth/login become /api/auth/login
    return envUrl.endsWith('/api') ? envUrl : envUrl.replace(/\/?$/, '') + '/api';
  }
  
  // Fallback when env not set: use backend URL for known production hosts (Cloud Run or custom domain)
  if (typeof window !== 'undefined' && window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1') {
    const hostname = window.location.hostname;
    if (hostname.includes('run.app') || hostname === 'twincare.march.health' || hostname.endsWith('.march.health')) {
      return 'https://twincare-backend-b6k7kyv5iq-uc.a.run.app/api';
    }
  }
  
  // Development default
  return 'http://localhost:8080/api';
};

export const API_BASE_URL = getApiBaseUrl();
