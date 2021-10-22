import Axios from 'axios'
import config from '../../public/config'

export default ({
  getUserData(doubleName) {
    return Axios.get(`${config.botBackend}/api/users/${doubleName}`)
  },

  verifySignedEmailIdentifier(sei) {
    return Axios.post(`${config.kycBackend}/verification/verify-sei`, {signedEmailIdentifier: sei})
  },

  verifySignedPhoneIdentifier(spi) {
    return Axios.post(`${config.kycBackend}/verification/verify-spi`, {signedPhoneIdentifier: spi})
  },

  verifySignedIdentityIdentifier(identifier, signedIdentifier) {
    return Axios.post(`${config.kycBackend}/verification/verify-identity-identifier?identifier=${identifier}`, {
      identifier: signedIdentifier,
    })
  }
})
