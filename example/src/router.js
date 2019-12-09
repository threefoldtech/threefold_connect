import Vue from 'vue'
import Router from 'vue-router'
import login from './views/login'

Vue.use(Router)

export default new Router({
  mode: 'history',
  base: process.env.BASE_URL,
  routes: [
    {
      path: '/',
      name: 'login',
      component: login
    },
    {
      path: '/callback',
      name: 'callback',
      component: () => import(/* webpackChunkName: "about" */ './views/callback')
    },
    {
      path: '/profile',
      name: 'profile',
      component: () => import(/* webpackChunkName: "about" */ './views/profile')
    }
  ]
})
