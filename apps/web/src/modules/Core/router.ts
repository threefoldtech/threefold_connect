import { Router } from 'vue-router';
import PathNotFound from '@/modules/Core/views/404.vue';
import ErrorPage from '@/modules/Core/views/Error.vue';
import FailedPage from '@/modules/Core/views/FailedPage.vue';
import { hasRequiredParameters } from '@/modules/Initial/services/query.service';
import { setLocalStorageDataForLogin, setLocalStorageDataForSigning } from '@/modules/Core/services/storage.service';
import { appId } from '@/modules/Initial/data';
import { RequiredParameterRoutes } from 'shared-types/src';
const coreRoutes = [
    {
        path: '/404',
        name: '404',
        component: PathNotFound,
        props: true,
    },
    {
        path: '/error',
        name: 'error',
        component: ErrorPage,
        props: true,
    },
    {
        path: '/failed',
        name: 'failed',
        component: FailedPage,
        props: true,
    },
    {
        path: '/:pathMatch(.*)',
        component: PathNotFound,
    },
];

export default async (router: Router) => {
    router.beforeEach((to, from, next) => {
        // @TODO: can this be cleaner?
        if (to.name === RequiredParameterRoutes.INITIAL) {
            setLocalStorageDataForLogin(to);
        }

        if (to.name === RequiredParameterRoutes.SIGN) {
            setLocalStorageDataForSigning(to);
        }

        if (to.name === RequiredParameterRoutes.LOGIN) {
            appId.value ? next() : next('/error');
        }

        const { requiredParameters } = to.meta;
        hasRequiredParameters(to, requiredParameters) === true ? next() : next('/error');
    });

    coreRoutes.forEach(route => {
        router.addRoute(route);
    });
};
