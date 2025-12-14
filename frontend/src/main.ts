import { createApp } from 'vue'
import { createPinia } from 'pinia'
import type { RouteLocationNormalized, NavigationGuardNext } from 'vue-router'
import App from './App.vue'
import router from './router'
import vuetify from './plugins/vuetify'
import socket from './services/socketClient'
import { setSocketInstance } from './services/socketService'
import { useAppStore } from './stores/app'
import './style.scss'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(vuetify)

setSocketInstance(socket)

const store = useAppStore()

// Socket event listeners
socket.on('connect', () => console.log('Socket connected'))
socket.on('disconnect', () => console.log('Socket disconnected'))
socket.on('nameknown', () => store.SOCKET_nameknown())
socket.on('namenotknown', () => store.SOCKET_namenotknown())
socket.on('signedAttempt', (data: any) => store.SOCKET_signedAttempt(data))
socket.on('emailverified', () => store.SOCKET_emailverified())
socket.on('emailverificationfailed', () => store.SOCKET_emailverificationfailed())
socket.on('smsverified', () => store.SOCKET_smsverified())
socket.on('smsverificationfailed', () => store.SOCKET_smsverificationfailed())
socket.on('cancelLogin', () => store.SOCKET_cancelLogin())

router.beforeEach((to: RouteLocationNormalized, _from: RouteLocationNormalized, next: NavigationGuardNext) => {
  const publicRoutes = ['initial', 'error', 'verifyemail', 'verifysms', 'sign']
  if (!publicRoutes.includes(to.name as string) && !store.doubleName) {
    next({ name: 'initial' })
  } else {
    next()
  }
})

app.mount('#app')
