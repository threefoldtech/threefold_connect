import type { Socket } from 'socket.io-client'

let socketInstance: Socket | null = null

export const setSocketInstance = (socket: Socket): void => {
  socketInstance = socket
}

export const emit = (type: string, message: any): void => {
  if (socketInstance) {
    socketInstance.emit(type, message)
  } else {
    setTimeout(() => {
      emit(type, message)
    }, 100)
  }
}

export default {
  emit,
  setSocketInstance
}
