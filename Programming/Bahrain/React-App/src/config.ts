// API Configuration
// In production, this will be set from environment variables at build time
// In development, defaults to localhost

const getApiBaseUrl = (): string => {
  // Check if we're in production (Cloud Run) - use environment variable (baked in at build time)
  const envUrl = (import.meta as any).env?.VITE_API_BASE_URL;
  if (envUrl && envUrl.trim() !== '') {
    return envUrl;
  }
  
  // Check if we're in production but env var not set (try to detect from window.location)
  if (typeof window !== 'undefined' && window.location.hostname !== 'localhost' && window.location.hostname !== '127.0.0.1') {
    const hostname = window.location.hostname;
    
    // For Cloud Run deployment, use known backend URL
    if (hostname.includes('run.app')) {
      // Use the live backend URL
      return 'https://twincare-backend-b6k7kyv5iq-uc.a.run.app/api';
    }
  }
  
  // Development default
  return 'http://localhost:8080/api';
};

export const API_BASE_URL = getApiBaseUrl();
