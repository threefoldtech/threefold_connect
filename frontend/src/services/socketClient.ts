import { io, Socket } from 'socket.io-client'
import config from '@/config'

const socket: Socket = io(config.apiurl, {
  transports: ['websocket', 'polling'],
  withCredentials: true
})

export default socket
