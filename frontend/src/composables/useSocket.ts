import { onMounted, onUnmounted } from 'vue'
import socket from '@/services/socketClient'
import { useAppStore } from '@/stores/app'
import type { SignedAttemptData } from '@/types'

export function useSocket() {
  const store = useAppStore()
  
  const handlers = {
    connect: () => {},
    disconnect: () => {},
    nameknown: () => store.SOCKET_nameknown(),
    namenotknown: () => store.SOCKET_namenotknown(),
    signedAttempt: (data: SignedAttemptData) => store.SOCKET_signedAttempt(data),
    signedSignDataAttempt: (data: any) => store.SOCKET_signedSignDataAttempt(data),
    emailverified: () => store.SOCKET_emailverified(),
    emailverificationfailed: () => store.SOCKET_emailverificationfailed(),
    smsverified: () => store.SOCKET_smsverified(),
    smsverificationfailed: () => store.SOCKET_smsverificationfailed(),
    phoneverified: () => store.SOCKET_phoneverified(),
    cancelLogin: () => store.SOCKET_cancelLogin(),
    cancelSign: () => store.SOCKET_cancelSign()
  }
  
  onMounted(() => {
    Object.entries(handlers).forEach(([event, handler]) => {
      socket.on(event, handler as any)
    })
  })
  
  onUnmounted(() => {
    Object.entries(handlers).forEach(([event, handler]) => {
      socket.off(event, handler as any)
    })
  })
  
  return {
    socket
  }
}
