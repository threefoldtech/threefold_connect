import { RouteLocationNormalizedLoaded } from 'vue-router';

export type QueryOptionsLogin = {
    appid: string;
    publickey: string;
    state: string;
    redirecturl: string;
    username: string;
    scope: any;
};

export const hasRequiredParameters = (route: RouteLocationNormalizedLoaded, requiredParams: any) => {
    if (!requiredParams) return true;

    const q = Object.keys(route.query);

    const required = requiredParams.map((e: string) => e.toUpperCase()).sort();
    const given = q.map((e: string) => e.toUpperCase()).sort();

    return required.every((e: string) => given.includes(e));
};
