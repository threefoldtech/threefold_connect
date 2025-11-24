import Vue from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import './plugins'
import './style.scss'
import socket from './services/socketClient'

Vue.config.productionTip = false

// Expose Socket.IO client instance on Vue prototype
Vue.prototype.$socket = socket

router.beforeEach((to, from, next) => {
  console.log(`to.name == ${to.name}`)
  if ((to.name !== 'initial' && to.name !== 'error' && to.name !== 'verifyemail' && to.name !== 'verifysms' && to.name !== 'sign') && !store.state.doubleName) {
    next({
      name: 'initial'
    })
  } else {
    next()
  }
})

const vm = new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')

export default vm
