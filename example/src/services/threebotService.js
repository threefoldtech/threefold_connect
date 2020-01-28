import Axios from 'axios'
import config from '../../public/config'
 
export default ({
  getUserData(doubleName) {
    return Axios.get(`${config.botBackend}/api/users/${doubleName}`)
  },

  verifySignedEmailIdentifier(sei) {
    return Axios.post(`${config.kycBackend}/verify`, { signedEmailIdentifier: sei })
  }
})
