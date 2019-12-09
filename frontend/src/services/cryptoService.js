import bip39 from 'bip39'
import { encodeBase64, decodeBase64 } from 'tweetnacl-util'
const sodium = require('libsodium-wrappers')

export default ({
  generateKeys (phrase) {
    return new Promise(async (resolve, reject) => {
      console.log(`phrase`, phrase)
      if (!phrase) phrase = bip39.generateMnemonic(256)
      console.log(`phrase`, phrase)
      var ken = bip39.mnemonicToEntropy(phrase)

      const fromHexString = hexString => new Uint8Array(hexString.match(/.{1,2}/g).map(byte => parseInt(byte, 16)))

      var keys = sodium.crypto_sign_seed_keypair(fromHexString(ken))
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
      console.log(`message`, message)
      resolve(sodium.crypto_sign_verify_detached(signature, message, publicKey))
    })
  }
})
