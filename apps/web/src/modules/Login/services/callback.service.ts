import { getPublicKeyOfUsername } from '@/modules/Login/services/external.service';
import { selectedImageId } from '@/modules/Initial/data';
import { redirectToOriginalLocation, redirectWithCancel } from '@/modules/Login/services/redirection.service';
import { encodeBase64 } from 'tweetnacl-util';
import { isMobile } from '@/modules/Core/utils/mobile.util';
import { ISocketLoginResult, ISocketSignedAttempt } from 'shared-types/src';
import { verifySignature } from '@/modules/Core/utils/crypto.util';

export const socketCallbackLogin = async (data: ISocketLoginResult) => {
    if (!data.doubleName || !data.signedAttempt) return;

    const pk = await getPublicKeyOfUsername(data.doubleName);
    if (pk.length === 1) {
        console.error(`Public key not found for user ${data.doubleName}`);
        return;
    }

    console.log('[CALLBACK]: PUBLIC KEY', encodeBase64(pk));

    const valid = await verifySignature(data.signedAttempt, pk);
    if (!valid) {
        console.error(`Signature mismatch for ${encodeBase64(pk)} with data ${data.signedAttempt}`);
        return;
    }

    const signedAttempt = JSON.parse(new TextDecoder().decode(valid)) as ISocketSignedAttempt;

    // When using unilinks, no emoji is selected so only check if it is not mobile
    if (signedAttempt.selectedImageId !== selectedImageId.value && !isMobile()) {
        console.error('[CALLBACK]: selectedImageId mismatch');
        return;
    }

    redirectToOriginalLocation(data);
};

export const socketCallbackCancel = () => {
    redirectWithCancel();
};
