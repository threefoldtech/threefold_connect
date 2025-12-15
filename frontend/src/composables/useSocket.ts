import { onMounted, onUnmounted } from 'vue'
import socket from '@/services/socketClient'
import { useAppStore } from '@/stores/app'
import type { SignedAttemptData } from '@/types'

export function useSocket() {
  const store = useAppStore()
  
  const handlers = {
    connect: () => console.log('Socket connected'),
    disconnect: () => console.log('Socket disconnected'),
    nameknown: () => store.SOCKET_nameknown(),
    namenotknown: () => store.SOCKET_namenotknown(),
    signedAttempt: (data: SignedAttemptData) => store.SOCKET_signedAttempt(data),
    emailverified: () => store.SOCKET_emailverified(),
    emailverificationfailed: () => store.SOCKET_emailverificationfailed(),
    smsverified: () => store.SOCKET_smsverified(),
    smsverificationfailed: () => store.SOCKET_smsverificationfailed(),
    cancelLogin: () => store.SOCKET_cancelLogin()
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
