import Vue from 'vue'
import Router from 'vue-router'
import initial from './views/Initial'

Vue.use(Router)

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [{
    path: '/',
    name: 'initial',
    component: initial
  }, {
    path: '/login',
    name: 'login',
    component: () => import(/* webpackChunkName: "login-page" */ './views/Login')
  }, {
    // path: '/embeddedlogin',
    // name: 'embeddedlogin',
    // component: () => import(/* webpackChunkName: "login-page" */ './views/EmbeddedLogin')
  // }, {
    path: '/verifyemail',
    name: 'verifyemail',
    component: () => import(/* webpackChunkName: "verifyemail-page" */ './views/VerifyEmail')
  }, {
    path: '/error',
    name: 'error',
    component: () => import(/* webpackChunkName: "error-page" */ './views/Errorpage')
  } ]
})
