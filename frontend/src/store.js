import Vue from 'vue'
import Vuex from 'vuex'
import socketService from './services/socketService'
import cryptoService from './services/cryptoService'
import axios from 'axios'
import config from '../public/config'
import { uuid } from 'vue-uuid'

Vue.use(Vuex)

export default new Vuex.Store({
  state: {
    hash: null,
    redirectUrl: null,
    keys: {},
    doubleName: null,
    nameCheckStatus: {
      checked: false,
      checking: false,
      available: false
    },
    emailVerificationStatus: {
      checked: false,
      checking: false,
      valid: false
    },
    scannedFlagUp: false,
    cancelLoginUp: false,
    signed: null,
    firstTime: null,
    isMobile: false,
    scope: null,
    appId: null,
    appPublicKey: null,
    randomImageId: null
  },
  mutations: {
    setNameCheckStatus (state, status) {
      state.nameCheckStatus = status
    },
    setKeys (state, keys) {
      state.keys = keys
    },
    setDoubleName (state, name) {
      console.log(`Setting doubleName to ${name}`)
      state.doubleName = name
    },
    setHash (state, hash) {
      state.hash = hash
    },
    setRedirectUrl (state, redirectUrl) {
      state.redirectUrl = redirectUrl
    },
    setScannedFlagUp (state, scannedFlagUp) {
      state.scannedFlagUp = scannedFlagUp
    },
    setCancelLoginUp (state, cancelLoginUp) {
      state.cancelLoginUp = cancelLoginUp
    },
    setSigned (state, signed) {
      state.signed = signed
    },
    setFirstTime (state, firstTime) {
      state.firstTime = firstTime
    },
    setEmailVerificationStatus (state, status) {
      state.emailVerificationStatus = status
    },
    setScope (state, scope) {
      let parsedScope = JSON.parse(scope)
      state.scope = JSON.stringify(parsedScope)
    },
    setAppId (state, appId) {
      state.appId = appId
    },
    setAppPublicKey (state, appPublicKey) {
      state.appPublicKey = appPublicKey
    },
    setRandomImageId (state) {
      state.randomImageId = Math.floor(Math.random() * 266)
    },
    setIsMobile (state, isMobile) {
      state.isMobile = isMobile
    }
  },
  actions: {
    setDoubleName (context, doubleName) {
      if (doubleName.indexOf('.3bot') < 0) {
        doubleName = `${doubleName}.3bot`
      }
      context.commit('setDoubleName', doubleName)
      socketService.emit('join', { room: doubleName })
    },
    setSignedRoom (context, signedRoom) {
      socketService.emit('join', { room: signedRoom })
    },
    setAttemptCanceled (context, payload) {
      context.commit('setCancelLoginUp', payload)
    },
    SOCKET_connect (context, payload) {
      // context.dispatch('forceRefetchStatus')
      console.log(`hi, connected with SOCKET_connect`)
    },
    saveState (context, payload) {
      context.commit('setHash', payload.hash)
      context.commit('setRedirectUrl', payload.redirectUrl)
    },
    clearCheckStatus (context) {
      context.commit('setNameCheckStatus', {
        checked: false,
        checking: false,
        available: false
      })
    },
    checkName (context, doubleName) {
      doubleName = `${doubleName}.3bot`
      socketService.emit('checkname', { doubleName })
      context.commit('setNameCheckStatus', {
        checked: false,
        checking: false,
        available: false
      })
    },
    SOCKET_nameknown (context) {
      context.commit('setNameCheckStatus', {
        checked: true,
        checking: false,
        available: false
      })
    },
    SOCKET_namenotknown (context) {
      context.commit('setNameCheckStatus', {
        checked: true,
        checking: false,
        available: true
      })
    },
    async generateKeys (context) {
      context.commit('setKeys', await cryptoService.generateKeys())
    },
    SOCKET_cancelLogin (context) {
      console.log('f')
      context.commit('setCancelLoginUp', true)
    },
    SOCKET_signed (context, data) {
      console.log('signed', data)
      console.log('context.getters.firstTime', context.getters.firstTime)
      console.log('context.getters.isMobile', context.getters.isMobile)
      console.log('context.getters.randomImageId', context.getters.randomImageId)
      if (data.selectedImageId && !context.getters.firstTime && !context.getters.isMobile && data.selectedImageId !== context.getters.randomImageId) {
        console.log('Resending notification!')
        context.dispatch('resendNotification')
      } else {
        console.log('Setting signed!')
        context.commit('setSigned', data)
      }
    },
    loginUser (context, data) {
      console.log(`LoginUser`)
      context.dispatch('setDoubleName', data.doubleName)
      context.commit('setSigned', null)
      context.commit('setFirstTime', data.firstTime)
      context.commit('setRandomImageId')
      context.commit('setIsMobile', data.mobile)
      socketService.emit('login', {
        doubleName: context.getters.doubleName,
        state: context.getters.hash,
        firstTime: data.firstTime,
        mobile: data.mobile,
        scope: context.getters.scope,
        appId: context.getters.appId,
        appPublicKey: context.getters.appPublicKey,
        randomImageId: !data.firstTime ? context.getters.randomImageId.toString() : null,
        logintoken: (data.logintoken || null)
      })
    },
    loginUserMobile (context, data) {
      context.commit('setSigned', null)
      context.commit('setFirstTime', data.firstTime)
      context.commit('setRandomImageId')
      context.commit('setIsMobile', data.mobile)
    },
    resendNotification (context) {
      context.commit('setRandomImageId')
      socketService.emit('resend', {
        doubleName: context.getters.doubleName,
        state: context.getters.hash,
        scope: context.getters.scope,
        appId: context.getters.appId,
        appPublicKey: context.getters.appPublicKey,
        randomImageId: context.getters.randomImageId.toString()
      })
    },
    // forceRefetchStatus (context) {
    //   if (context.getters.hash) {
    //     // console.log(`Forcerefetching for ${context.getters.doubleName}`)
    //     axios.get(`${config.apiurl}api/forcerefetch?hash=${context.getters.hash}`).then(response => {
    //       if (response.data.scanned) context.commit('setScannedFlagUp', response.data.scanned)
    //       if (response.data.signed) context.commit('setSigned', response.data.signed)
    //     }).catch(e => {
    //       alert(e)
    //     })
    //   }
    // },
    // deleteLoginAttempt (context) {
    //   if (context.getters.hash) {
    //     console.log(`Deleting login attempt for`)
    //     axios.delete(`${config.apiurl}api/attempts/${context.getters.hash}`).then(response => {
    //       console.log(response)
    //     }).catch(e => {
    //       alert(e)
    //     })
    //   }
    // },
    sendValidationEmail (context, data) {
      var callbackUrl = `${window.location.protocol}//${window.location.host}/verifyemail`

      callbackUrl += `?hash=${context.getters.hash}`
      callbackUrl += `&redirecturl=${window.btoa(context.getters.redirectUrl)}`
      callbackUrl += `&doublename=${context.getters.doubleName}`

      if (context.getters.scope) callbackUrl += `&scope=${encodeURIComponent(context.getters.scope)}`
      if (context.getters.appPublicKey) callbackUrl += `&publickey=${context.getters.appPublicKey}`
      callbackUrl += (context.getters.appId) ? `&appid=${context.getters.appId}` : `&appid=${window.location.hostname}`

      axios.post(`${config.openkycurl}users`, {
        'user_id': context.getters.doubleName,
        'email': data.email,
        'callback_url': callbackUrl,
        'public_key': context.getters.keys.publicKey
      }).then(x => {
        console.log(`Mail has been sent`)
      }).catch(e => {
        alert(e)
      })
    },
    validateEmail (context, data) {
      console.log(`Validating email`, data)
      if (data && data.userId && data.verificationCode) {
        context.commit('setEmailVerificationStatus', {
          checked: false,
          checking: true,
          valid: false
        })
        axios.post(`${config.openkycurl}users/${data.userId}/verify`, {
          verification_code: data.verificationCode
        }).then(message => {
          axios.post(`${config.openkycurl}verify`, {
            signedEmailIdentifier: message.data
          }).then(response => {
            if (response.data.identifier === data.userId) {
              axios.post(`${config.apiurl}api/users/${data.userId}/emailverified`)
              context.commit('setEmailVerificationStatus', {
                checked: true,
                checking: false,
                valid: true
              })
            }
          })
          // axios.get(`${config.openkycurl}publickey`).then(async publickey => {
          //   // console.log(`Validating signature`)
          //   // cryptoService.validateSignature(message.data, message.data, publickey.data.public_key).then(() => {
          //   //   axios.post(`${config.apiurl}api/users/${data.userId}/emailverified`)
          //   //   context.commit('setEmailVerificationStatus', {
          //   //     checked: true,
          //   //     checking: false,
          //   //     valid: true
          //   //   })
          //   // }).catch(e => {
          //   //   context.commit('setEmailVerificationStatus', {
          //   //     checked: true,
          //   //     checking: false,
          //   //     valid: false
          //   //   })
          //   // })
          // }).catch(e => {
          //   context.commit('setEmailVerificationStatus', {
          //     checked: true,
          //     checking: false,
          //     valid: false
          //   })
          // })
        }).catch(e => {
          context.commit('setEmailVerificationStatus', {
            checked: true,
            checking: false,
            valid: false
          })
        })
      }
    },
    SOCKET_emailverified (context) {
      context.commit('setEmailVerificationStatus', {
        checked: true,
        checking: false,
        valid: true
      })
    },
    setScope (context, scope) {
      context.commit('setScope', scope)
    },
    setAppId (context, appId) {
      context.commit('setAppId', appId)
    },
    setAppPublicKey (context, appPublicKey) {
      context.commit('setAppPublicKey', appPublicKey)
    },
    setHash (context, hash) {
      context.commit('setHash', hash)
    }
  },
  getters: {
    doubleName: state => state.doubleName,
    nameCheckStatus: state => state.nameCheckStatus,
    keys: state => state.keys,
    hash: state => state.hash,
    redirectUrl: state => state.redirectUrl,
    scannedFlagUp: state => state.scannedFlagUp,
    cancelLoginUp: state => state.cancelLoginUp,
    signed: state => state.signed,
    firstTime: state => state.firstTime,
    emailVerificationStatus: state => state.emailVerificationStatus,
    scope: state => state.scope,
    appId: state => state.appId,
    appPublicKey: state => state.appPublicKey,
    isMobile: state => state.isMobile,
    randomImageId: state => state.randomImageId
  }
})
