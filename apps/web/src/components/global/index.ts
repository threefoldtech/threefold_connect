import { App } from 'vue';

// @ts-ignore
const modules = import.meta.globEager('./*.vue');

export const registerGlobalComponent = (app: App<Element>) => {
    for (const path in modules) {
        app.component(path.replace('./', '').replace('.vue', ''), modules[path].default);
    }
};
