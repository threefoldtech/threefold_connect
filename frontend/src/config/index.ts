import type { AppConfig } from '@/types'

// Check if config is loaded from public/config.js (production builds)
declare global {
  interface Window {
    config?: AppConfig
  }
}

const config: AppConfig = window.config || {
  apiurl: import.meta.env.VITE_API_URL || 'http://localhost:5000/',
  openkycurl: import.meta.env.VITE_OPENKYC_URL || 'https://openkyc.threefold.me/',
  deeplink: import.meta.env.VITE_DEEPLINK || 'threefold://'
}

export default config
