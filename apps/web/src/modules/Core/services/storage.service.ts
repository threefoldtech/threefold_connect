import { QueryOptionsLogin } from '@/modules/Initial/services/query.service';
import { RouteLocationNormalizedLoaded } from 'vue-router';
import { appId, appPublicKey, redirectUrl, scope, state, username } from '@/modules/Initial/data';
import { QueryOptionsSigning } from '@/modules/InitialSign/services/sign.service';
import { dataHash, dataUrl, friendlyName, isJson } from '@/modules/InitialSign/data';

export const setLocalStorageDataForLogin = (route: RouteLocationNormalizedLoaded) => {
    const queryParams: QueryOptionsLogin = route.query as QueryOptionsLogin;

    if (queryParams.username) {
        username.value = queryParams.username;
    }

    appId.value = queryParams.appid;
    scope.value = queryParams.scope;
    state.value = queryParams.state;
    appPublicKey.value = queryParams.publickey;
    redirectUrl.value = queryParams.redirecturl;
};

export const setLocalStorageDataForSigning = (route: RouteLocationNormalizedLoaded) => {
    //@ts-ignore
    const queryParams: QueryOptionsSigning = route.query as QueryOptionsSigning;

    if (queryParams.username) {
        username.value = queryParams.username;
    }

    friendlyName.value = queryParams.friendlyName;
    appId.value = queryParams.appId;
    state.value = queryParams.state;
    dataHash.value = queryParams.dataHash;
    redirectUrl.value = queryParams.redirectUrl;
    isJson.value = queryParams.isJson;
    dataUrl.value = queryParams.dataUrl;
};
