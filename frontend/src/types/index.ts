export interface AppConfig {
  apiurl: string
  openkycurl: string
  deeplink: string
}

export interface Keys {
  phrase?: string
  privateKey?: string
  publicKey?: string
}

export interface NameCheckStatus {
  checked: boolean
  checking: boolean
  available: boolean
}

export interface VerificationStatus {
  checked: boolean
  checking: boolean
  valid: boolean
}

export interface SignedAttemptData {
  signedAttempt: string
  doubleName: string
  selectedImageId?: number
  state?: string
  appId?: string
  scope?: string
  [key: string]: any
}

export interface SignedAttempt {
  signedAttempt: string
  data: {
    doubleName: string
    [key: string]: any
  }
}
