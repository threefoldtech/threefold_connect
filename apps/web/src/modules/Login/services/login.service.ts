import { getPublicKeyOfUsername } from '@/modules/Login/services/external.service';
import { emitJoin, emitLeave, emitLogin } from '@/modules/Core/services/socket.service';
import { nanoid } from 'nanoid';
import {
    appId,
    appPublicKey,
    locationId,
    redirectUrl,
    scope,
    selectedImageId,
    state,
    username,
} from '@/modules/Initial/data';
import { ISocketJoin, ISocketLeave, ISocketLogin } from 'shared-types/src';
import { encrypt } from '@/modules/Core/utils/crypto.util';
import { Config } from '@/modules/Core/configs/config';

export const loginUserWeb = async () => {
    const name = username.value + '.3bot';

    const roomToJoinUser: ISocketJoin = { room: name };
    emitJoin(roomToJoinUser);

    const pk = await getPublicKeyOfUsername(name);

    if (pk.length === 1) {
        console.error(`Public key not found for user ${name}`);
        return;
    }

    const objectToEncrypt = JSON.stringify({
        username: name,
        state: state.value,
        scope: scope.value,
        appId: appId.value,
        room: name,
        appPublicKey: appPublicKey.value,
        randomImageId: selectedImageId.value.toString(),
        locationId: locationId.value,
        isMobile: false,
    });

    const encryptedAttempt = encrypt(objectToEncrypt, pk);

    const roomToLeaveUser: ISocketLeave = { room: name };
    emitLeave(roomToLeaveUser);

    const roomToJoinRandom: ISocketJoin = { room: name };
    emitJoin(roomToJoinRandom);

    const loginAttempt: ISocketLogin = { username: name, encryptedLoginAttempt: encryptedAttempt };
    emitLogin(loginAttempt);
};

export const loginUserMobile = async () => {
    const randomRoom = nanoid().toLowerCase();
    const roomToJoin: ISocketJoin = { room: randomRoom };
    emitJoin(roomToJoin);

    const uniLinkUrl = `${Config.APP_DEEPLINK}login/?state=${state.value}&scope=${scope.value}&appId=${appId.value}&room=${randomRoom}&appPublicKey=${appPublicKey.value}&redirectUrl=${redirectUrl.value}`;

    window.open(uniLinkUrl);
};
