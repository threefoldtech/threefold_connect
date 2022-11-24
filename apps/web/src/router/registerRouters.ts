import { Router } from 'vue-router';

interface IModule {
    router?: (router: Router) => Promise<void>;
}

const registerModule = async (router: Router, module: IModule) => {
    if (!module.router) {
        return;
    }
    await module.router(router);
};

export const registerModules = async (router: Router, modules: IModule[]) => {
    const promises = modules.map(module => registerModule(router, module));
    return await Promise.all(promises);
};
