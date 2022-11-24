import {
    getSignedPhoneIdentifier,
    getSignedPhoneIdentifierSigner,
    RetrieveSpiDto,
    setPhoneVerified,
} from '@/modules/Phone/services/external.service';

// Status 0: CHECKING
// Status 1: SUCCESS
// Status 2: FAILURE
export const validatePhone = async (username: string, code: string): Promise<number> => {
    if (!username || !code) {
        console.error(`No username or code available: [${username}, ${code}]`);
        return 2;
    }

    const phoneData: RetrieveSpiDto = {
        user_id: username,
        verification_code: code,
    };

    const signedPhoneIdentifier = await getSignedPhoneIdentifier(phoneData);
    if (!signedPhoneIdentifier) {
        console.error('No signed phone identifier found');
        return 2;
    }

    const signer = await getSignedPhoneIdentifierSigner(signedPhoneIdentifier);
    if (!signer) {
        console.error(`Couldn't verify the signedPhoneIdentifier`);
        return 2;
    }

    if (signer.identifier !== username) {
        console.error(`Identifier mismatch: ${signer.identifier} and ${username}`);
        return 2;
    }

    const verified = await setPhoneVerified(username);
    if (!verified) {
        console.error(`Couldn't set the phone verified`);
        return 2;
    }

    console.log('Successfully validated phone');
    return 1;
};
