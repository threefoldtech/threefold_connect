import type { AppConfig } from '@/types'

const config: AppConfig = {
  apiurl: import.meta.env.VITE_API_URL || 'http://localhost:5000/',
  openkycurl: import.meta.env.VITE_OPENKYC_URL || 'https://openkyc.threefold.me/',
  deeplink: import.meta.env.VITE_DEEPLINK || 'threebot://'
}

export default config
