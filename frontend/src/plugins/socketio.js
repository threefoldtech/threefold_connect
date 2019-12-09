import Vue from 'vue'
import store from '../store'
import VueSocketIO from 'vue-socket.io/dist/vue-socketio'
import config from '../../public/config'

Vue.use(new VueSocketIO({
  debug: true,
  secure: true,
  connection: config.apiurl,
  vuex: {
    store,
    actionPrefix: 'SOCKET_'
  }
}))
