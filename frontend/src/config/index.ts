import type { AppConfig } from '@/types'

const config: AppConfig = {
  apiurl: import.meta.env.VITE_API_URL || 'http://localhost:5000/',
  deeplink: import.meta.env.VITE_DEEPLINK || 'threefold://'
}

export default config
