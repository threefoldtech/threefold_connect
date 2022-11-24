import { appId, redirectUrl } from '@/modules/Initial/data';
import { ISocketLoginResult } from 'shared-types/src';

export const redirectToOriginalLocation = (signedAttempt: ISocketLoginResult) => {
    console.log('[REDIRECTING] - SIGNED ATTEMPT: ', signedAttempt);

    if (!signedAttempt) return;
    if (!redirectUrl.value) return;

    const encodedSignedAttempt: string = encodeURIComponent(JSON.stringify(signedAttempt));
    if (!encodedSignedAttempt) return;

    console.log('[REDIRECTING] - ENCODED SIGNED ATTEMPT: ', encodedSignedAttempt);

    const safetyUrl = createSafetyUrl();
    const finalUrl = `${safetyUrl}signedAttempt=${encodedSignedAttempt}`;

    console.log('[REDIRECTING] - FINAL URL: ', finalUrl);
    console.log('[REDIRECTING] - REDIRECTING TO: ', finalUrl);

    window.location.href = finalUrl;
    console.log('[REDIRECTING] - REDIRECTED');
};

export const redirectWithCancel = () => {
    if (!redirectUrl.value) return;

    const safeRedirectUrl = redirectUrl.value[0] === '/' ? redirectUrl.value : '/' + redirectUrl.value;
    window.location.href = `//${appId.value}${safeRedirectUrl}?error=CancelledByUser`;
};

export const createSafetyUrl = (): string => {
    if (!redirectUrl.value) return '';

    let union = '?';

    if (redirectUrl.value.indexOf('?') >= 0) {
        union = '&';
    }

    // Evil app could do appId + redirectUrl = wallet.com + .evil.com = wallet.com.evil.com
    // Now its wallet.com/.evil.com
    const safeRedirectUrl = redirectUrl.value[0] === '/' ? redirectUrl.value : '/' + redirectUrl.value;
    return `//${appId.value}${safeRedirectUrl}${union}`;
};
