export const findUserByUsernameQuery = (username: string) => {
    return {
        where: {
            username: username,
        },
    };
};

export const findUserByPublicKeyQuery = (publicKey: string) => {
    return {
        where: {
            mainPublicKey: publicKey,
        },
    };
};

export const updateEmailOfUserQuery = (userId: string, email: string) => {
    return {
        data: {
            email: email,
        },
        where: {
            userId: userId,
        },
    };
};
