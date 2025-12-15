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
import './assets/styles/global.scss'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)
app.use(vuetify)

setSocketInstance(socket)

const store = useAppStore()

// Socket event listeners are now managed in App.vue via useSocket composable

router.beforeEach((to: RouteLocationNormalized, _from: RouteLocationNormalized, next: NavigationGuardNext) => {
  const publicRoutes = ['initial', 'error', 'verifyemail', 'verifysms', 'sign']
  if (!publicRoutes.includes(to.name as string) && !store.doubleName) {
    next({ name: 'initial' })
  } else {
    next()
  }
})

app.mount('#app')
