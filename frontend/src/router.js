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
    path: '/verifyemail',
    name: 'verifyemail',
    component: () => import(/* webpackChunkName: "verifyemail-page" */ './views/VerifyEmail')
  }, {
    path: '/verifysms',
    name: 'verifysms',
    component: () => import(/* webpackChunkName: "verifysms-page" */ './views/VerifySms')
  }, {
    path: '/sign',
    name: 'sign',
    component: () => import(/* webpackChunkName: "sign-page" */ './views/Sign')
  },
    {
      path: '/error',
      name: 'error',
      component: () => import(/* webpackChunkName: "error-page" */ './views/Errorpage')
    }]
})
