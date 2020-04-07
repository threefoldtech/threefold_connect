import home from './views/home'
import Router from 'vue-router'
export default new Router({
  mode: 'history',
  base: '/wizard',
  routes: [{
    path: '/',
    name: 'home',
    component: home
  }]
})
