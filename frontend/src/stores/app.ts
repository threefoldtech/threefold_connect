import { defineStore } from 'pinia'
import { ref } from 'vue'
import socketService from '@/services/socketService'
import cryptoService from '@/services/cryptoService'
import userService from '@/services/userService'
import type { Keys, NameCheckStatus, VerificationStatus } from '@/types'

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
  const doubleName = ref<string | null>(null)
  const nameCheckStatus = ref<NameCheckStatus>({ checked: false, checking: false, available: false })
  const emailVerificationStatus = ref<VerificationStatus>({ checked: false, checking: false, valid: false })
  const smsVerificationStatus = ref<VerificationStatus>({ checked: false, checking: false, valid: false })
  const signedAttempt = ref<any>(null)
  const firstTime = ref<boolean | null>(null)
  const isMobile = ref(false)
  const scope = ref<string | null>(null)
  const appId = ref<string | null>(null)
  const appPublicKey = ref<string | null>(null)
  const randomImageId = ref<number | null>(null)
  const randomRoom = ref<string | null>(null)
  const loginTimeleft = ref(120)

  // Actions
  const setDoubleName = (name: string) => {
    doubleName.value = name.includes('.3bot') ? name : `${name}.3bot`
    socketService.emit('join', { room: doubleName.value })
  }

  const checkName = (name: string) => {
    socketService.emit('checkname', { doubleName: `${name}.3bot` })
  }

  const SOCKET_nameknown = () => {
    nameCheckStatus.value = { checked: true, checking: false, available: false }
  }

  const SOCKET_namenotknown = () => {
    nameCheckStatus.value = { checked: true, checking: false, available: true }
  }

  const loginUser = async (data: { doubleName: string; mobile: boolean; firstTime: boolean }) => {
    setDoubleName(data.doubleName)
    signedAttempt.value = null
    firstTime.value = data.firstTime
    randomImageId.value = Math.floor(Math.random() * 266)
    isMobile.value = data.mobile

    const publicKey = (await userService.getUserData(doubleName.value!)).data.publicKey
    const newRandomRoom = generateUUID()
    const locationId = localStorage.getItem('locationId') || generateUUID()
    localStorage.setItem('locationId', locationId)

    const encryptedLoginAttempt = await cryptoService.encrypt(
      JSON.stringify({
        doubleName: doubleName.value,
        state: _state.value,
        firstTime: data.firstTime,
        scope: scope.value,
        appId: appId.value,
        randomRoom: newRandomRoom,
        appPublicKey: appPublicKey.value,
        randomImageId: !data.firstTime ? randomImageId.value?.toString() : null,
        locationId
      }),
      publicKey
    )

    socketService.emit('leave', { room: doubleName.value })
    randomRoom.value = newRandomRoom
    socketService.emit('join', { room: newRandomRoom })
    socketService.emit('login', { doubleName: doubleName.value, encryptedLoginAttempt })
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

  const SOCKET_signedAttempt = (data: any) => {
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

  return {
    _state, redirectUrl, keys, doubleName, nameCheckStatus, emailVerificationStatus,
    smsVerificationStatus, signedAttempt, firstTime, isMobile, scope, appId, appPublicKey,
    randomImageId, randomRoom, loginTimeleft, 
    setDoubleName, checkName, clearCheckStatus, loginUser, setRandomRoom,
    setState, setScope, setAppId, setAppPublicKey, setRedirectUrl,
    SOCKET_nameknown, SOCKET_namenotknown, SOCKET_signedAttempt,
    SOCKET_emailverified, SOCKET_emailverificationfailed,
    SOCKET_smsverified, SOCKET_smsverificationfailed
  }
})
