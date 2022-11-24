import { createApp } from 'vue';
import App from './App.vue';
import './index.css';

import '@/components/global';
import { createVueRouter } from '@/router';
import { registerModules } from '@/router/registerRouters';

import InitModule from '@/modules/Initial';
import LoginModule from '@/modules/Login';
import CoreModule from '@/modules/Core';
import MailModule from '@/modules/Mail';
import PhoneModule from '@/modules/Phone';
import InitialSignModule from '@/modules/InitialSign';
import sodium from 'libsodium-wrappers';
import socketIo from '@/plugins/SocketIo';
import { registerGlobalComponent } from '@/components/global';
import { initializeConfiguration } from '@/modules/Core/services/flag.service';

const initApplication = async () => {
    await sodium.ready;

    const app = createApp(App);
    app.use(socketIo, {
        connection: `${window.location.origin}`,
        options: {
            allowEI03: true,
            reconnection: true,
            reconnectionDelay: 500,
            reconnectionAttempts: 10,
        },
        reconnection: true,
        transports: ['websocket', 'polling'],
    });

    const router = createVueRouter();
    await registerModules(router, [CoreModule, InitModule, LoginModule, MailModule, PhoneModule, InitialSignModule]);
    app.use(router);

    registerGlobalComponent(app);

    await initializeConfiguration(router);

    app.mount('#app');
};

initApplication().then(_ => {
    console.log('Application loaded');
});
