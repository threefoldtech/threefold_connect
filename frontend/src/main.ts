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

socket.on('connect', () => store.SOCKET_nameknown?.())
socket.on('nameknown', () => store.SOCKET_nameknown())
socket.on('namenotknown', () => store.SOCKET_namenotknown())

router.beforeEach((to: RouteLocationNormalized, _from: RouteLocationNormalized, next: NavigationGuardNext) => {
  const publicRoutes = ['initial', 'error', 'verifyemail', 'verifysms', 'sign']
  if (!publicRoutes.includes(to.name as string) && !store.doubleName) {
    next({ name: 'initial' })
  } else {
    next()
  }
})

app.mount('#app')
