import axios from 'axios';
import { Config } from '@/modules/Core/configs/config';
import { Router } from 'vue-router';

export const initializeConfiguration = async (router: Router) => {
    let t;

    try {
        t = (await axios.get('/api/env')).data;

        Config.DEBOUNCE_NAME_SOCKET = t['debounce-name-socket'].value;
        Config.SUPPORT_URL = t['support-url'].value;
        Config.API_KYC_URL = t['openkyc-url'].value;
        Config.APP_DEEPLINK = t['app-deep-link'].value;
    } catch (e) {
        console.error(e);
        console.error('Could not get flagsmith configs of backend');

        await router.push({ name: 'failed', params: { reason: 'flagsmith' } });
    }

    console.table(t);
};
