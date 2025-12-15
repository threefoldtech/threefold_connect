import { defineStore } from 'pinia'
import { ref } from 'vue'
import socketService from '@/services/socketService'
import cryptoService from '@/services/cryptoService'
import userService from '@/services/userService'
import axios from 'axios'
import config from '@/config'
import type { Keys, NameCheckStatus, VerificationStatus, SignedAttemptData } from '@/types'

const generateUUID = (): string => {
  let d = new Date().getTime()
  let d2 = (performance?.now() * 1000) || 0
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    let r = Math.random() * 16
    if (d > 0) {
      r = (d + r) % 16 | 0
      d = Math.floor(d / 16)
    } else {
      r = (d2 + r) % 16 | 0
      d2 = Math.floor(d2 / 16)
    }
    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16)
  })
}

export const useAppStore = defineStore('app', () => {
  // State
  const _state = ref<string | null>(null)
  const redirectUrl = ref<string | null>(null)
  const keys = ref<Keys>({})
  const doubleName = ref<string | null>(localStorage.getItem('doubleName') || null)
  const nameCheckStatus = ref<NameCheckStatus>({ checked: false, checking: false, available: false })
  const emailVerificationStatus = ref<VerificationStatus>({ checked: false, checking: false, valid: false })
  const smsVerificationStatus = ref<VerificationStatus>({ checked: false, checking: false, valid: false })
  const signedAttempt = ref<SignedAttemptData | null>(null)
  const firstTime = ref<boolean | null>(null)
  const isMobile = ref(false)
  const scope = ref<string | null>(null)
  const appId = ref<string | null>(null)
  const appPublicKey = ref<string | null>(null)
  const randomImageId = ref<number | null>(null)
  const randomRoom = ref<string | null>(null)
  const loginTimeleft = ref(120)
  const loginTimestamp = ref<number | null>(null)
  const loginTimeout = ref<number | null>(null)
  const loginInterval = ref<number | null>(null)
  const cancelLoginUp = ref(false)
  const attemptCanceled = ref(false)
  const scannedFlagUp = ref(false)
  const cancelSignUp = ref(false)
  const signAttemptOnGoing = ref(false)
  const signedSignAttempt = ref<any>(null)
  const isJson = ref(false)
  const dataUrl = ref<string | null>(null)
  const friendlyName = ref<string | null>(null)
  const dataUrlHash = ref<string | null>(null)

  // Actions
  const setDoubleName = (name: string) => {
    doubleName.value = name.includes('.3bot') ? name : `${name}.3bot`
    localStorage.setItem('doubleName', doubleName.value)
    socketService.emit('join', { room: doubleName.value })
  }

  const checkName = (name: string) => {
    socketService.emit('checkname', { doubleName: `${name}.3bot` })
  }

  const SOCKET_nameknown = () => {
    console.log('Socket: name is known (user exists)')
    nameCheckStatus.value = { checked: true, checking: false, available: false }
  }

  const SOCKET_namenotknown = () => {
    console.log('Socket: name is not known (user does not exist)')
    nameCheckStatus.value = { checked: true, checking: false, available: true }
  }

  const loginUser = async (data: { doubleName: string; mobile: boolean; firstTime: boolean }) => {
    try {
      console.log('loginUser called with:', data)
      setDoubleName(data.doubleName)
      signedAttempt.value = null
      firstTime.value = data.firstTime
      randomImageId.value = Math.floor(Math.random() * 266)
      console.log('🎯 Generated randomImageId:', randomImageId.value)
      console.log('🎯 firstTime:', data.firstTime)
      isMobile.value = data.mobile

      console.log('Fetching user public key for:', doubleName.value)
      const userData = await userService.getUserData(doubleName.value!)
      const publicKey = userData.data.publicKey
      console.log('Got public key:', publicKey)

      const newRandomRoom = generateUUID()
      const locationId = localStorage.getItem('locationId') || generateUUID()
      localStorage.setItem('locationId', locationId)

      const loginData = {
        doubleName: doubleName.value,
        state: _state.value,
        firstTime: data.firstTime,
        scope: scope.value,
        appId: appId.value,
        randomRoom: newRandomRoom,
        appPublicKey: appPublicKey.value,
        randomImageId: !data.firstTime ? randomImageId.value?.toString() : null,
        locationId
      }
      console.log('🎯 Sending randomImageId to mobile app:', loginData.randomImageId)
      console.log('Login data to encrypt:', loginData)

      const encryptedLoginAttempt = await cryptoService.encrypt(
        JSON.stringify(loginData),
        publicKey
      )
      console.log('State:', _state.value)
      console.log('Encrypted login attempt:', encryptedLoginAttempt)

      socketService.emit('leave', { room: doubleName.value })
      setRandomRoom(newRandomRoom)
      socketService.emit('login', { doubleName: doubleName.value, encryptedLoginAttempt })
    } catch (error) {
      console.error('Error in loginUser:', error)
      throw error
    }
  }

  const clearCheckStatus = () => {
    nameCheckStatus.value = { checked: false, checking: false, available: false }
  }

  const setRandomRoom = (room: string) => {
    randomRoom.value = room
    console.log(`joining ${room}`)
    socketService.emit('join', { room })
  }

  const setState = (state: string) => {
    _state.value = state
  }

  const setScope = (newScope: string) => {
    scope.value = newScope
  }

  const setAppId = (id: string) => {
    appId.value = id
  }

  const setAppPublicKey = (key: string) => {
    appPublicKey.value = key
  }

  const setRedirectUrl = (url: string) => {
    redirectUrl.value = url
  }

  const SOCKET_signedAttempt = async (data: SignedAttemptData) => {
    console.log('signedAttempt', data.signedAttempt)
    console.log('signedAttempt', data.doubleName)
    console.log('context.getters.firstTime', firstTime.value)
    console.log('context.getters.isMobile', isMobile.value)
    console.log('context.getters.randomImageId', randomImageId.value)

    try {
      const publicKey = (await userService.getUserData(data.doubleName)).data.publicKey

      // Decode the signed attempt to get the actual data
      const decodedAttempt = await cryptoService.validateSignedAttempt(
        data.signedAttempt,
        publicKey
      )

      if (!decodedAttempt) {
        console.log('Something went wrong ... ')
        return
      }

      // Convert Uint8Array to string and parse JSON
      const utf8ArrayToStr = (array: Uint8Array): string => {
        const decoder = new TextDecoder('utf-8')
        return decoder.decode(array)
      }

      const signedAttemptData = JSON.parse(utf8ArrayToStr(decodedAttempt))

      // Check if wrong emoji was selected (Vue 2 logic)
      if (
        signedAttemptData.selectedImageId &&
        !firstTime.value &&
        !isMobile.value &&
        signedAttemptData.selectedImageId !== randomImageId.value
      ) {
        console.log('Resending notification!')
        await resendNotification()
      } else {
        console.log('Setting signedAttempt!')
        signedAttempt.value = data
      }
    } catch (error) {
      console.error('Error processing signedAttempt:', error)
    }
  }

  const SOCKET_emailverified = () => {
    emailVerificationStatus.value = { checked: true, checking: false, valid: true }
  }

  const SOCKET_emailverificationfailed = () => {
    emailVerificationStatus.value = { checked: true, checking: false, valid: false }
  }

  const SOCKET_smsverified = () => {
    smsVerificationStatus.value = { checked: true, checking: false, valid: true }
  }

  const SOCKET_smsverificationfailed = () => {
    smsVerificationStatus.value = { checked: true, checking: false, valid: false }
  }

  const SOCKET_cancelLogin = () => {
    cancelLoginUp.value = true
  }

  const resetTimer = () => {
    if (loginInterval.value) {
      clearInterval(loginInterval.value)
    }

    loginTimestamp.value = Date.now()
    loginInterval.value = window.setInterval(() => {
      loginTimeleft.value = Math.round(
        120 - (Date.now() - loginTimestamp.value!) / 1000
      )
      if (loginTimeleft.value <= 0) {
        clearInterval(loginInterval.value!)
      }
    }, 1000)
  }

  const resendNotification = async () => {
    try {
      randomImageId.value = Math.floor(Math.random() * 266)
      console.log('🔄 Resend - New randomImageId:', randomImageId.value)
      
      const publicKey = (await userService.getUserData(doubleName.value!)).data.publicKey
      console.log('Public key:', publicKey)
      
      const newRandomRoom = generateUUID()
      let locationId = localStorage.getItem('locationId')
      if (locationId === null) {
        locationId = generateUUID()
        localStorage.setItem('locationId', locationId)
      }
      console.log('locationId UUID:', locationId)
      
      const loginData = {
        doubleName: doubleName.value,
        randomRoom: newRandomRoom,
        state: _state.value,
        scope: scope.value,
        appId: appId.value,
        appPublicKey: appPublicKey.value,
        randomImageId: randomImageId.value?.toString(),
        locationId
      }
      
      const encryptedLoginAttempt = await cryptoService.encrypt(
        JSON.stringify(loginData),
        publicKey
      )
      
      socketService.emit('leave', { room: randomRoom.value })
      setRandomRoom(newRandomRoom)
      resetTimer()
      socketService.emit('login', { 
        doubleName: doubleName.value, 
        encryptedLoginAttempt 
      })
    } catch (error) {
      console.error('Error in resendNotification:', error)
      throw error
    }
  }

  const setAttemptCanceled = (canceled: boolean) => {
    attemptCanceled.value = canceled
    if (canceled) {
      if (loginTimeout.value) clearTimeout(loginTimeout.value)
      if (loginInterval.value) clearInterval(loginInterval.value)
    }
  }

  const loginUserMobile = (data: { mobile: boolean; firstTime: boolean }) => {
    signedAttempt.value = null
    firstTime.value = data.firstTime
    randomImageId.value = Math.floor(Math.random() * 266)
    isMobile.value = data.mobile
  }

  const signUserMobile = (data: any) => {
    appId.value = data.appId
    isJson.value = data.isJson
    dataUrlHash.value = data.dataUrlHash
    dataUrl.value = data.dataUrl
    friendlyName.value = data.friendlyName
    redirectUrl.value = data.redirectUrl
    _state.value = data.state
  }

  const signDataUser = async (data: any) => {
    setDoubleName(data.doubleName)
    appId.value = data.appId
    isJson.value = data.isJson
    dataUrlHash.value = data.dataUrlHash
    dataUrl.value = data.dataUrl
    friendlyName.value = data.friendlyName
    redirectUrl.value = data.redirectUrl
    _state.value = data.state

    console.log('THIS IS THE STATE')
    console.log(data.state)

    const publicKey = (await userService.getUserData(doubleName.value!)).data.publicKey
    const newRandomRoom = generateUUID()
    socketService.emit('leave', { room: doubleName.value })
    setRandomRoom(newRandomRoom)
    
    const encryptedSignAttempt = await cryptoService.encrypt(
      JSON.stringify({
        state: _state.value,
        doubleName: doubleName.value,
        isJson: isJson.value,
        dataUrlHash: dataUrlHash.value,
        dataUrl: dataUrl.value,
        friendlyName: friendlyName.value,
        appId: appId.value,
        randomRoom: newRandomRoom,
        redirectUrl: redirectUrl.value
      }),
      publicKey
    )

    socketService.emit('sign', {
      doubleName: doubleName.value,
      encryptedSignAttempt
    })

    signAttemptOnGoing.value = true
  }

  const resendSignNotification = async () => {
    const publicKey = (await userService.getUserData(doubleName.value!)).data.publicKey
    const newRandomRoom = generateUUID()
    socketService.emit('leave', { room: doubleName.value })
    setRandomRoom(newRandomRoom)
    
    const encryptedSignAttempt = await cryptoService.encrypt(
      JSON.stringify({
        state: _state.value,
        doubleName: doubleName.value,
        isJson: isJson.value,
        dataUrlHash: dataUrlHash.value,
        friendlyName: friendlyName.value,
        dataUrl: dataUrl.value,
        appId: appId.value,
        randomRoom: newRandomRoom,
        redirectUrl: redirectUrl.value
      }),
      publicKey
    )

    socketService.emit('sign', {
      doubleName: doubleName.value,
      encryptedSignAttempt
    })

    signAttemptOnGoing.value = true
  }

  const SOCKET_signedSignDataAttempt = async (data: any) => {
    console.log('signedSignDataAttempt', data.signedAttempt)
    console.log('signedSignDataAttempt', data.doubleName)

    const publicKey = (await userService.getUserData(data.doubleName)).data.publicKey
    const signedAttemptDecoded = await cryptoService.validateSignedAttempt(
      data.signedAttempt,
      publicKey
    )
    console.log('decoded', signedAttemptDecoded)
    const string = new TextDecoder().decode(signedAttemptDecoded)
    console.log('in string', string)

    signedSignAttempt.value = data
    console.log(data)
  }

  const SOCKET_cancelSign = () => {
    console.log('Cancel sign attempt')
    cancelSignUp.value = true
    signAttemptOnGoing.value = false
  }

  const setSignAttemptCanceled = (canceled: boolean) => {
    cancelSignUp.value = canceled
  }

  const generateKeys = async () => {
    keys.value = await cryptoService.generateKeys()
  }

  const saveState = (payload: { _state: string; redirectUrl: string }) => {
    _state.value = payload._state
    redirectUrl.value = payload.redirectUrl
  }

  const sendValidationEmail = (data: { email: string }) => {
    let callbackUrl = `${window.location.protocol}//${window.location.host}/verifyemail`

    callbackUrl += `?state=${_state.value}`
    callbackUrl += `&redirecturl=${window.btoa(redirectUrl.value!)}`
    callbackUrl += `&doublename=${doubleName.value}`

    if (scope.value) {
      callbackUrl += `&scope=${encodeURIComponent(scope.value)}`
    }
    if (appPublicKey.value) {
      callbackUrl += `&publickey=${appPublicKey.value}`
    }
    callbackUrl += appId.value
      ? `&appid=${appId.value}`
      : `&appid=${window.location.hostname}`

    axios
      .post(`${config.openkycurl}verification/send-email`, {
        user_id: doubleName.value,
        email: data.email,
        callback_url: callbackUrl,
        public_key: keys.value.publicKey
      })
      .then(() => {
        console.log('Mail has been sent')
      })
      .catch((e) => {
        alert(e)
      })
  }

  const sendValidationSms = (data: { phone: string }) => {
    let callbackUrl = `${window.location.protocol}//${window.location.host}/verifysms`

    callbackUrl += `?state=${_state.value}`
    callbackUrl += `&redirecturl=${window.btoa(redirectUrl.value!)}`
    callbackUrl += `&doublename=${doubleName.value}`

    if (scope.value) {
      callbackUrl += `&scope=${encodeURIComponent(scope.value)}`
    }
    if (appPublicKey.value) {
      callbackUrl += `&publickey=${appPublicKey.value}`
    }
    callbackUrl += appId.value
      ? `&appid=${appId.value}`
      : `&appid=${window.location.hostname}`

    axios
      .post(`${config.openkycurl}verification/send-sms`, {
        user_id: doubleName.value,
        phone: data.phone,
        callback_url: callbackUrl,
        public_key: keys.value.publicKey
      })
      .then(() => {
        console.log('sms has been sent')
      })
      .catch(() => {
        alert('Failed to send SMS')
      })
  }

  const validateEmail = (data: { userId: string; verificationCode: string }) => {
    console.log('Validating email', data)
    if (data && data.userId && data.verificationCode) {
      emailVerificationStatus.value = {
        checked: false,
        checking: true,
        valid: false
      }
      axios
        .post(`${config.openkycurl}verification/verify-email`, {
          user_id: data.userId,
          verification_code: data.verificationCode
        })
        .then((message) => {
          axios
            .post(`${config.openkycurl}verification/verify-sei`, {
              signedEmailIdentifier: message.data
            })
            .then((response) => {
              if (response.data.identifier === data.userId) {
                axios.post(
                  `${config.apiurl}api/users/${data.userId}/emailverified`
                )
                emailVerificationStatus.value = {
                  checked: true,
                  checking: false,
                  valid: true
                }
              }
            })
        })
        .catch(() => {
          emailVerificationStatus.value = {
            checked: true,
            checking: false,
            valid: false
          }
        })
    }
  }

  const validateSms = (data: { userId: string; verificationCode: string }) => {
    if (data && data.userId && data.verificationCode) {
      smsVerificationStatus.value = {
        checked: false,
        checking: true,
        valid: false
      }
      axios
        .post(`${config.openkycurl}verification/verify-sms`, {
          user_id: data.userId,
          verification_code: data.verificationCode
        })
        .then((message) => {
          axios
            .post(`${config.openkycurl}verification/verify-spi`, {
              signedPhoneIdentifier: message.data
            })
            .then((response) => {
              if (response.data.identifier === data.userId) {
                axios.post(
                  `${config.apiurl}api/users/${data.userId}/smsverified`
                )
                smsVerificationStatus.value = {
                  checked: true,
                  checking: false,
                  valid: true
                }
              }
            })
        })
        .catch(() => {
          smsVerificationStatus.value = {
            checked: true,
            checking: false,
            valid: false
          }
        })
    }
  }

  const SOCKET_phoneverified = () => {
    smsVerificationStatus.value = {
      checked: true,
      checking: false,
      valid: true
    }
  }

  return {
    _state, redirectUrl, keys, doubleName, nameCheckStatus, emailVerificationStatus,
    smsVerificationStatus, signedAttempt, firstTime, isMobile, scope, appId, appPublicKey,
    randomImageId, randomRoom, loginTimeleft, loginTimestamp, loginTimeout, loginInterval,
    cancelLoginUp, attemptCanceled, scannedFlagUp, cancelSignUp, signAttemptOnGoing,
    signedSignAttempt, isJson, dataUrl, friendlyName, dataUrlHash,
    setDoubleName, checkName, clearCheckStatus, loginUser, loginUserMobile, setRandomRoom,
    setState, setScope, setAppId, setAppPublicKey, setRedirectUrl, resetTimer,
    resendNotification, setAttemptCanceled, signUserMobile, signDataUser, resendSignNotification,
    setSignAttemptCanceled, generateKeys, saveState,
    sendValidationEmail, sendValidationSms, validateEmail, validateSms,
    SOCKET_nameknown, SOCKET_namenotknown, SOCKET_signedAttempt,
    SOCKET_emailverified, SOCKET_emailverificationfailed,
    SOCKET_smsverified, SOCKET_smsverificationfailed, SOCKET_cancelLogin,
    SOCKET_signedSignDataAttempt, SOCKET_cancelSign, SOCKET_phoneverified
  }
})
