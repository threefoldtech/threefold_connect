# ThreeFold Connect Login Example

A comprehensive example application demonstrating ThreeFold Connect authentication and signing flows using Vue 3 and Vite.

## Features

- **Login Examples**: Multiple authentication flows with different scopes (email, derived seed)
- **Sign Example**: Data signing flow demonstration
- **Modern Stack**: Vue 3.4, Vite 5, TypeScript 5

## Project Setup

```bash
npm install
```

### Development

Run the development server with hot-reload:

```bash
npm run dev
```

The app will be available at `http://localhost:8080`

### Production Build

```bash
npm run build
```

### Serve Production Build

After building, serve the production files:

```bash
npm start
```

## Usage

### Login Flow

1. Navigate to the home page
2. Choose a login scope option
3. A popup will open with the ThreeFold Connect authentication
4. Complete authentication in the popup
5. The profile data will be displayed on the home page

### Sign Flow

1. Click "Go to Sign Example" on the home page
2. Enter the data you want to sign
3. Toggle "Data is JSON" if applicable
4. Click "Request Signature"
5. Complete signing in the popup
6. The signed data will be displayed

## Configuration

Edit `src/config/config.ts` to configure:

- `threefoldBackend`: ThreeFold login backend URL
- `kycBackend`: KYC backend URL  
- `appId`: Your application ID (defaults to current host)
- `redirect_url`: Callback URL for login flow
- `sign_redirect_url`: Callback URL for sign flow

**Important**: The `appId` must be registered in the ThreeFold backend with matching redirect URLs.

## Deployment

For SPA routing to work in production, ensure your web server redirects all routes to `index.html`. Configuration files are provided for:

- Netlify/Vercel: `public/_redirects`
- Nginx: `nginx.conf`
- Apache: `.htaccess`

See `DEPLOYMENT.md` for detailed instructions.

## Routes

- `/` - Home page with login examples
- `/callback` - Login callback handler
- `/sign` - Sign flow example
- `/sign-callback` - Sign callback handler
