import {
    getSignedEmailIdentifier,
    getSignedEmailIdentifierSigner,
    RetrieveSeiDto,
    setEmailVerified,
} from '@/modules/Mail/services/external.service';

// Status 0: CHECKING
// Status 1: SUCCESS
// Status 2: FAILURE
export const validateEmail = async (username: string, code: string): Promise<number> => {
    if (!username || !code) {
        console.error(`No username or code available: [${username}, ${code}]`);
        return 2;
    }

    const emailData: RetrieveSeiDto = {
        user_id: username,
        verification_code: code,
    };

    const signedEmailIdentifier = await getSignedEmailIdentifier(emailData);
    if (!signedEmailIdentifier) {
        console.error('No signed email identifier found');
        return 2;
    }

    const signer = await getSignedEmailIdentifierSigner(signedEmailIdentifier);
    if (!signer) {
        console.error(`Couldn't verify the signedEmailIdentifier`);
        return 2;
    }

    if (signer.identifier !== username) {
        console.error(`Identifier mismatch: ${signer.identifier} and ${username}`);
        return 2;
    }

    const verified = await setEmailVerified(username);
    if (!verified) {
        console.error(`Couldn't set the email verified`);
        return 2;
    }

    console.log('Successfully validated email');
    return 1;
};
