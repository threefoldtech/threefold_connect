import { Router } from 'vue-router';
import Login from '@/modules/Login/views/Login.vue';

export const loginRoutes = [
    {
        name: 'login',
        path: '/login',
        component: Login,
    },
];

export default async (router: Router) => {
    for (const route of loginRoutes) {
        router.addRoute(route);
    }
};
