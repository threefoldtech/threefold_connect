import type { Socket } from 'socket.io-client'

let socketInstance: Socket | null = null

export const setSocketInstance = (socket: Socket): void => {
  socketInstance = socket
}

export const emit = (type: string, message: any, retries = 0): void => {
  if (socketInstance) {
    socketInstance.emit(type, message)
  } else if (retries < 50) {  // Max 5 seconds (50 * 100ms)
    setTimeout(() => {
      emit(type, message, retries + 1)
    }, 100)
  } else {
    console.error(`Failed to emit '${type}' after ${retries} retries - socket not connected`)
  }
}

export default {
  emit,
  setSocketInstance
}
