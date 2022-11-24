import { Router } from 'vue-router';
import Phone from '@/modules/Phone/views/Phone.vue';

export const phoneRoutes = [
    {
        name: 'phone',
        path: '/verifysms',
        component: Phone,
        meta: {
            requiredParameters: ['verificationCode', 'userId'],
        },
    },
];

export default async (router: Router) => {
    for (const route of phoneRoutes) {
        router.addRoute(route);
    }
};
