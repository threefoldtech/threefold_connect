# ThreeFold Connect

## Introduction

Threefold Connect is a mobile app that serves as your main gateway to the Threefold Grid and various other Threefold products and services. 

It contains an ultra secure 2FA authenticator for authenticating through third party applications.

Inside the app, you can manage your Threefold Tokens(TFT).

## Features

#### Threefold news

Inside the app, there is a "News" section where you can find all the latest Threefold news!

#### Wallet

In the Threefold Connect app, it is possible to manage your TFT and view your transaction history on the TF chain.

#### Farmers

If you own a Threefold node, you can manage your farm here.

#### Support

If you have Threefold related questions, we provide a support chat where we will answer your questions as soon as possible!

#### Planetary network

It is possible to have a a planetary network IPv6 address. Here you can enable the planety network connection and your phone will automatically be connected to the p2p network.

#### Identity

When you are using the secure 2FA authentication, some third party apps require certain information (eg. phone number). In this tab you can verify your email, phone number and identity to provide this data to the third party application. This allows you total granular control over which data you choose to share or not share.

## Local development

### External repositories

Threefold News: https://github.com/threefoldtech/threefold_connect_news

Wallet v3: https://github.com/threefoldtech/wallet-next

Farmer: https://github.com/threefoldtech/wallet-next

Support: https://github.com/threefoldtech/tfsupport

## Frontend

Make sure the correct configuration is inside config.js. After that start the frontend by doing:

`yarn && yarn serve`


## Backend

Go inside virtual environement:

`source ./venv/bin/activate 
`

Start UWSGI backend:

` uwsgi --http :5000 --gevent 1000 --http-websockets --master --wsgi-file __main__.py --callable app -s 0.0.0.0:3030
: 1643024584:0;uwsgi --http :5000 --gevent 1000 --http-websockets --master --wsgi-file __main__.py --callable app -s 0.0.0.0:3030`


## App

Make sure you have at least Flutter 2.8.1 installed. If everything is installed properly, execute the following commands: 

Copy the file in /lib/app_config_local.template into /lib/app_config_local.dart and change the configuration to your local IP's

After that, use the build.sh script to set up the right environement

`./build.sh --init && ./build.sh --switch --local`

Connect your phone / start an emulator and everything should work properly.

