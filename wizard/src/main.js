import Vue from 'vue'
import vuetify from 'babel!plugins/vuetify'
import App from 'component!App'
import store from 'babel!./store'
import router from 'babel!./router'

new Vue({
  store,
  router,
  vuetify,
  render: h => h(App)
}).$mount('#app')
