export type Configuration = {
    DEBOUNCE_NAME_SOCKET: number;
    API_KYC_URL: string;
    SUPPORT_URL: string;
    APP_DEEPLINK: string;
};

export const Config: Configuration = {
    DEBOUNCE_NAME_SOCKET: 500,
    API_KYC_URL: 'https://openkyc.live/',
    SUPPORT_URL: 'https://support.grid.tf/',
    APP_DEEPLINK: 'threebot://',
};
