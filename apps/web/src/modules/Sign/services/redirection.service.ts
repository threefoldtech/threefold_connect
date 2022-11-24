import { ISocketSignResult } from 'shared-types/src';
import { redirectUrl } from '@/modules/Initial/data';
import { createSafetyUrl } from '@/modules/Login/services/redirection.service';

export const redirectToOriginalLocationForSigning = (signedSignAttempt: ISocketSignResult) => {
    console.log('[REDIRECTING] - SIGNED ATTEMPT: ', signedSignAttempt);

    if (!signedSignAttempt) return;
    if (!redirectUrl.value) return;

    const encodedSignedSignAttempt: string = encodeURIComponent(JSON.stringify(signedSignAttempt));
    if (!encodedSignedSignAttempt) return;

    console.log('[REDIRECTING] - ENCODED SIGNED ATTEMPT: ', encodedSignedSignAttempt);

    const safetyUrl = createSafetyUrl();
    const finalUrl = `${safetyUrl}signedAttempt=${encodedSignedSignAttempt}`;

    console.log('[REDIRECTING] - FINAL URL: ', finalUrl);
    console.log('[REDIRECTING] - REDIRECTING TO: ', finalUrl);

    window.location.href = finalUrl;
    console.log('[REDIRECTING] - REDIRECTED');
};
