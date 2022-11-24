import { Router } from 'vue-router';
import InitialSign from '@/modules/InitialSign/views/InitialSign.vue';

export const initialSignRoutes = [
    {
        name: 'sign',
        path: '/sign',
        component: InitialSign,
        meta: {
            requiredParameters: ['friendlyName', 'appId', 'isJson', 'state', 'redirectUrl', 'dataHash'],
        },
    },
];

export default async (router: Router) => {
    for (const route of initialSignRoutes) {
        router.addRoute(route);
    }
};
