export interface ISocketLeave {
    room: string;
}

export interface ISocketJoin {
    room: string;
    app?: boolean;
}

export interface ISocketLogin {
    username: string;
    encryptedLoginAttempt: string;
    created?: number;
    type?: string;
}

export interface ISocketSign {
    username: string;
    encryptedSignAttempt: string;
    created?: number;
    type?: string;
}

export interface ISocketCheckName {
    username: string;
}

export interface ISocketLoginResult {
    doubleName: string;
    signedAttempt: string;
}

export interface ISocketSignResult {
    doubleName: string;
    signedAttempt: string;
}

export interface ISocketSignedAttempt {
    username: string;
    signedState: string;
    data: ISocketSignedData;
    room: string;
    appId: string;
    selectedImageId: number;
}

export interface ISocketSignedData {
    nonce: string;
    ciphertext: string;
}
