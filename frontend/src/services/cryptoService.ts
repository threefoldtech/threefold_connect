import bip39 from 'bip39'
import { encodeBase64, decodeBase64 } from 'tweetnacl-util'
import sodium from 'libsodium-wrappers'
import type { Keys } from '@/types'

interface CryptoService {
  generateKeys(phrase?: string): Promise<Keys>
  validateSignature(message: string, signature: string, publicKey: string): Promise<boolean>
  validateSignedAttempt(signedAttempt: string, publicKey: string): Promise<Uint8Array>
  encrypt(message: string, publicKey: string): Promise<string>
}

const cryptoService: CryptoService = {
  async generateKeys(phrase?: string): Promise<Keys> {
    await sodium.ready
    
    if (!phrase) {
      phrase = bip39.generateMnemonic(256)
    }

    const entropy = bip39.mnemonicToEntropy(phrase)
    const entropyToUint8Array = (hexString: string): Uint8Array => 
      new Uint8Array(hexString.match(/.{1,2}/g)!.map(byte => parseInt(byte, 16)))

    const keys = sodium.crypto_sign_seed_keypair(entropyToUint8Array(entropy))

    return {
      phrase,
      privateKey: encodeBase64(keys.privateKey),
      publicKey: encodeBase64(keys.publicKey)
    }
  },

  async validateSignature(message: string, signature: string, publicKey: string): Promise<boolean> {
    await sodium.ready
    const pubKey = decodeBase64(publicKey)
    const sig = decodeBase64(signature)
    return sodium.crypto_sign_verify_detached(sig, message, pubKey)
  },

  async validateSignedAttempt(signedAttempt: string, publicKey: string): Promise<Uint8Array> {
    await sodium.ready
    const pubKey = decodeBase64(publicKey)
    const attempt = decodeBase64(signedAttempt)
    const signResult = sodium.crypto_sign_open(attempt, pubKey)

    if (!signResult) {
      throw new Error('Invalid signature.')
    }

    return signResult
  },

  async encrypt(message: string, publicKey: string): Promise<string> {
    await sodium.ready
    const pubKey = sodium.crypto_sign_ed25519_pk_to_curve25519(decodeBase64(publicKey))
    const encryptedMessage = encodeBase64(sodium.crypto_box_seal(message, pubKey, 'uint8array'))
    return encryptedMessage
  }
}

export default cryptoService
