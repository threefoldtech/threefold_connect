import { ISocketSignResult } from 'shared-types/src';
import { getPublicKeyOfUsername } from '@/modules/Login/services/external.service';
import { encodeBase64 } from 'tweetnacl-util';
import { verifySignature } from '@/modules/Core/utils/crypto.util';
import { redirectWithCancel } from '@/modules/Login/services/redirection.service';
import { redirectToOriginalLocationForSigning } from '@/modules/Sign/services/redirection.service';

export const socketCallbackSign = async (data: ISocketSignResult) => {
    if (!data.doubleName || !data.signedAttempt) return;

    const pk = await getPublicKeyOfUsername(data.doubleName);
    if (pk.length === 1) return;

    console.log('[CALLBACK]: PUBLIC KEY', encodeBase64(pk));

    const valid = await verifySignature(data.signedAttempt, pk);
    if (!valid) {
        return;
    }

    redirectToOriginalLocationForSigning(data);
};

export const redirectWithCancelForSigning = () => {
    redirectWithCancel();
};
