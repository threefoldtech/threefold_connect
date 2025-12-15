import type { AppConfig } from '@/types'

const config: AppConfig = {
  apiurl: import.meta.env.VITE_API_URL || 'http://localhost:5000/',
  openkycurl: import.meta.env.VITE_OPENKYC_URL || 'https://openkyc.threefold.me/',
  deeplink: import.meta.env.VITE_DEEPLINK || 'threefold://'
}

console.log('=== Config Loading ===')
console.log('Using config:', config)
console.log('API URL:', config.apiurl)
console.log('OpenKYC URL:', config.openkycurl)
console.log('Deep link:', config.deeplink)
console.log('======================')

export default config
