import { nanoid } from 'nanoid';
import { ISocketJoin, ISocketLeave, ISocketSign } from 'shared-types/src';
import { emitJoin, emitLeave, emitSign } from '@/modules/Core/services/socket.service';
import { appId, redirectUrl, state, username } from '@/modules/Initial/data';
import { dataHash, dataUrl, friendlyName, isJson } from '@/modules/InitialSign/data';
import { getPublicKeyOfUsername } from '@/modules/Login/services/external.service';
import { encrypt } from '@/modules/Core/utils/crypto.util';
import { Config } from '@/modules/Core/configs/config';

export type QueryOptionsSigning = {
    username: string;
    friendlyName: string;
    appId: string;
    isJson: boolean;
    state: string;
    redirectUrl: string;
    dataHash: string;
    dataUrl: string;
};

export const signUserMobile = () => {
    const randomRoom = nanoid().toLowerCase();
    const roomToJoin: ISocketJoin = { room: randomRoom };
    emitJoin(roomToJoin);

    const uniLinkUrl = `${Config.APP_DEEPLINK}sign/?state=${state.value}&appId=${appId.value}&randomRoom=${randomRoom}&dataUrl=${dataUrl.value}&redirecturl=${redirectUrl.value}&dataHash=${dataHash.value}&isJson=${isJson.value}&friendlyName=${friendlyName.value}`;

    window.open(uniLinkUrl);
};

export const signUserWeb = async () => {
    const name = username.value + '.3bot';

    const roomToJoinUser: ISocketJoin = { room: name };
    emitJoin(roomToJoinUser);

    const pk = await getPublicKeyOfUsername(name);

    if (pk.length === 1) return;

    const randomRoom = nanoid();

    const objectToEncrypt = JSON.stringify({
        username: name,
        state: state.value,
        isJson: isJson.value,
        appId: appId.value,
        dataUrl: dataUrl.value,
        randomRoom: randomRoom,
        dataUrlHash: dataHash.value,
        friendlyName: friendlyName.value,
        redirectUrl: redirectUrl.value,
    });

    const encryptedAttempt = encrypt(objectToEncrypt, pk);

    const roomToLeaveUser: ISocketLeave = { room: name };
    emitLeave(roomToLeaveUser);

    const roomToJoinRandom: ISocketJoin = { room: randomRoom };
    emitJoin(roomToJoinRandom);

    const signAttempt: ISocketSign = { username: name, encryptedSignAttempt: encryptedAttempt };
    emitSign(signAttempt);
};
