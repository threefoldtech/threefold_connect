import axios from 'axios';
import { Config } from '@/modules/Core/configs/config';

export interface RetrieveSeiDto {
    user_id: string;
    verification_code: string;
}

export const getSignedEmailIdentifier = async (emailData: RetrieveSeiDto) => {
    try {
        return (await axios.post(`${Config.API_KYC_URL}verification/verify-email`, emailData))?.data;
    } catch (err) {
        console.error('Error in getSignedEmailIdentifier');
        console.error(err);
        return null;
    }
};

export const getSignedEmailIdentifierSigner = async (sei: string) => {
    try {
        return (
            await axios.post(`${Config.API_KYC_URL}verification/verify-sei`, {
                signedEmailIdentifier: sei,
            })
        )?.data;
    } catch (err) {
        console.error('Error in getSignedEmailIdentifierSigner');
        console.error(err);
        return null;
    }
};

export const setEmailVerified = async (username: string) => {
    try {
        return await axios.post(`/api/users/${username}/email/verified`);
    } catch (err) {
        console.error('Error in setEmailVerified');
        console.error(err);
        return null;
    }
};
