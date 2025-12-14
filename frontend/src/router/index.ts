import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'

const routes: RouteRecordRaw[] = [
  {
    path: '/',
    name: 'initial',
    component: () => import('@/views/Initial/index.vue')
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('@/views/Login/index.vue')
  },
  {
    path: '/verifyemail',
    name: 'verifyemail',
    component: () => import('@/views/VerifyEmail/index.vue')
  },
  {
    path: '/verifysms',
    name: 'verifysms',
    component: () => import('@/views/VerifySms/index.vue')
  },
  {
    path: '/sign',
    name: 'sign',
    component: () => import('@/views/Sign/index.vue')
  },
  {
    path: '/error',
    name: 'error',
    component: () => import('@/views/Errorpage/index.vue')
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

export default router
