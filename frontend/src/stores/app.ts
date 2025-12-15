import { defineStore } from 'pinia'
import { ref } from 'vue'
import socketService from '@/services/socketService'
import cryptoService from '@/services/cryptoService'
import userService from '@/services/userService'
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
      randomImageId.value = Math.floor(Math.random() * 266) + 1
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
      console.log('Encrypted login attempt created')

      socketService.emit('leave', { room: doubleName.value })
      randomRoom.value = newRandomRoom
      socketService.emit('join', { room: newRandomRoom })
      console.log('Emitting login event to room:', newRandomRoom)
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

  const SOCKET_signedAttempt = (data: SignedAttemptData) => {
    console.log('Received signedAttempt:', data)
    signedAttempt.value = data
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
    loginTimeleft.value = 120
    loginTimestamp.value = Date.now()
    randomImageId.value = Math.floor(Math.random() * 266) + 1
    console.log('🔄 Resend - New randomImageId:', randomImageId.value)

    if (loginTimeout.value) {
      clearTimeout(loginTimeout.value)
    }
    if (loginInterval.value) {
      clearInterval(loginInterval.value)
    }

    loginTimeout.value = window.setTimeout(() => {
      loginTimeleft.value = 0
      if (loginInterval.value) {
        clearInterval(loginInterval.value)
      }
    }, 120000)

    loginInterval.value = window.setInterval(() => {
      if (loginTimestamp.value) {
        const diff = Date.now() - loginTimestamp.value
        loginTimeleft.value = Math.max(0, 120 - Math.floor(diff / 1000))
      }
    }, 1000)
  }

  const resendNotification = async () => {
    try {
      resetTimer() // This regenerates randomImageId
      
      console.log('Resending notification with new randomImageId:', randomImageId.value)
      
      const publicKey = (await userService.getUserData(doubleName.value!)).data.publicKey
      const newRandomRoom = generateUUID()
      const locationId = localStorage.getItem('locationId') || generateUUID()
      
      const loginData = {
        doubleName: doubleName.value,
        state: _state.value,
        firstTime: firstTime.value,
        scope: scope.value,
        appId: appId.value,
        randomRoom: newRandomRoom,
        appPublicKey: appPublicKey.value,
        randomImageId: randomImageId.value?.toString(),
        locationId
      }
      
      const encryptedLoginAttempt = await cryptoService.encrypt(
        JSON.stringify(loginData),
        publicKey
      )
      
      socketService.emit('leave', { room: randomRoom.value })
      randomRoom.value = newRandomRoom
      socketService.emit('join', { room: newRandomRoom })
      console.log('Emitting new login event to room:', newRandomRoom)
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
    randomImageId.value = Math.floor(Math.random() * 266) + 1
    isMobile.value = data.mobile
  }

  return {
    _state, redirectUrl, keys, doubleName, nameCheckStatus, emailVerificationStatus,
    smsVerificationStatus, signedAttempt, firstTime, isMobile, scope, appId, appPublicKey,
    randomImageId, randomRoom, loginTimeleft, loginTimestamp, loginTimeout, loginInterval,
    cancelLoginUp, attemptCanceled,
    setDoubleName, checkName, clearCheckStatus, loginUser, loginUserMobile, setRandomRoom,
    setState, setScope, setAppId, setAppPublicKey, setRedirectUrl, resetTimer,
    resendNotification, setAttemptCanceled,
    SOCKET_nameknown, SOCKET_namenotknown, SOCKET_signedAttempt,
    SOCKET_emailverified, SOCKET_emailverificationfailed,
    SOCKET_smsverified, SOCKET_smsverificationfailed, SOCKET_cancelLogin
  }
})
