import Vue from 'vue'
import App from './App.vue'
import router from './router'
import vuetify from './plugin/vuetify'

Vue.config.productionTip = false

new Vue({
  el: '#app',
  router,
  vuetify,
  render: h => h(App)
}).$mount('#app')
