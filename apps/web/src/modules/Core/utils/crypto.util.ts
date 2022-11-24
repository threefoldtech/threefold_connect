import sodium from 'libsodium-wrappers';
import { decodeBase64, encodeBase64 } from 'tweetnacl-util';

export const verifySignature = async (signedData: string, publicKey: Uint8Array) => {
    try {
        return sodium.crypto_sign_open(decodeBase64(signedData), publicKey);
    } catch (e) {
        console.error(`Couldn't verify signature for ${signedData} with publicKey ${publicKey}`);
        return null;
    }
};

export const encrypt = (message: string, publicKey: Uint8Array): string => {
    const encryptionKey: Uint8Array = sodium.crypto_sign_ed25519_pk_to_curve25519(publicKey);
    return encodeBase64(sodium.crypto_box_seal(message, encryptionKey, 'uint8array'));
};
