# Boilerplate backend

## Package.json

### :exclamation: Change project name :exclamation:

In package.json you beed to change the package name and optional the version

## Flagsmith

The google and azure ad strategies are enabled if configs are found and enabled in flagsmith.

## Google

Add a feature in flagsmith named `google-auth` and add a config like this:

```json
{
    "clientID": "745904402777-qcf4b2o48dfsjl1ra6ho1f7cjf2demm2.apps.googleusercontent.com",
    "clientSecret": "SuperSecret",
    "callbackURL": "http://localhost:3001/api/auth/google/redirect",
    "scope": ["email", "profile"]
}
```

Route to login and register: `/api/auth/google`

## Azure AD

Add a feature in flagsmith named `azure-ad-auth` and add a config like this:

```json
{
    "clientID": "e0fecd36-0ddf-42e4-912e-9842e4f9f345",
    "clientSecret": "SuperSecret",
    "callbackURL": "http://localhost:3001/api/auth/azure-ad/redirect",
    "tenant": "5659f351-b607-4770-bdf8-b991ab2e4660"
}
```

Route to login and register: `/api/auth/azure-ad`

## Local

You can also register with username/password using the `/api/auth/register`. ex:

```json
{
    "username": "this needs to be an email",
    "password": "this is a password",
    "firstName": "optional",
    "lastName": "optional"
}
```

## AccessToken

Using any of the above methods will return an `access_token` which is an JWT and has a lifespan of 5 minutes.

## RefreshToken

When login in you also receive a `refresh_token`. This is used to renew the accesstoken.  
Use `/api/auth/refresh?token=&user_id=`.

## Roles
