export const findAllTwinsQuery = {
    select: {
        yggdrasilIp: true,
        appId: true,
        derivedPublicKey: true,
        user: {
            select: {
                username: true,
            },
        },
    },
};

export const findAllTwinsByUsernameQuery = userId => {
    return {
        select: {
            user: {
                select: {
                    username: true,
                },
            },
            yggdrasilIp: true,
            appId: true,
            derivedPublicKey: true,
            id: true,
        },
        where: {
            user: {
                userId: userId,
            },
        },
    };
};

export const findTwinByUsernameAndAppIdQuery = (username: string, appId: string) => {
    return {
        select: {
            user: {
                select: {
                    username: true,
                },
            },
            yggdrasilIp: true,
            appId: true,
            derivedPublicKey: true,
            id: true,
        },
        where: {
            appId: appId,
            user: {
                username: username,
            },
        },
    };
};

export const updateTwinYggdrasilIpQuery = (yggdrasilIp: string, twinId: string) => {
    return {
        data: {
            yggdrasilIp: yggdrasilIp,
        },
        where: {
            id: twinId,
        },
    };
};

export const getTwinByPublicKeyQuery = (derivedPublicKey: string) => {
    return {
        select: {
            derivedPublicKey: true,
        },
        where: {
            derivedPublicKey: derivedPublicKey,
        },
    };
};
