export const threefoldBackend = 'https://login.staging.jimber.io';
export const kycBackend = 'https://openkyc.staging.jimber.org';

// For local development, use localhost. For production, use your actual domain
export const redirect_url = `${window.location.origin}/callback`;
export const sign_redirect_url = `${window.location.origin}/sign-callback`;

// Note: The appId must be registered in the ThreeFold backend with the matching redirect_url
// For local development, you may need to use 'localhost:8080' or register your local URL
export const appId = window.location.host;

export const seedPhrase = 'calm science teach foil burst until next mango hole sponsor fold bottom cousin push focus track truly tornado turtle over tornado teach large fiscal';
