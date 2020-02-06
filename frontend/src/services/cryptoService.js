import bip39 from 'bip39'
import { encodeBase64, decodeBase64 } from 'tweetnacl-util'
import userService from './userService'

const sodium = require('libsodium-wrappers')

export default ({
  generateKeys (phrase) {
    return new Promise(async (resolve, reject) => {
      if (!phrase) {
        phrase = bip39.generateMnemonic(256)
      }

      var entropy = bip39.mnemonicToEntropy(phrase)

      const entropyToUint8Array = hexString => new Uint8Array(hexString.match(/.{1,2}/g).map(byte => parseInt(byte, 16)))

      var keys = sodium.crypto_sign_seed_keypair(entropyToUint8Array(entropy))

      resolve({
        phrase,
        privateKey: encodeBase64(keys.privateKey),
        publicKey: encodeBase64(keys.publicKey)
      })
    })
  },
  validateSignature (message, signature, publicKey) {
    return new Promise(async (resolve, reject) => {
      publicKey = decodeBase64(publicKey)
      signature = decodeBase64(signature)
      resolve(sodium.crypto_sign_verify_detached(signature, message, publicKey))
    })
  },
  encrypt (message, publicKey) {
    return new Promise(async (resolve, reject) => {
      await sodium.ready

      publicKey = sodium.crypto_sign_ed25519_pk_to_curve25519(decodeBase64(publicKey))
      var encryptedMessage = encodeBase64(sodium.crypto_box_seal(message, publicKey, 'uint8array'))

      resolve(encryptedMessage)
    })
  }
})
