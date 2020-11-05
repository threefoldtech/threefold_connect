## Code examples 

### How to integrate 3Bot Connect app as decentralized login mechanism

#### Python

https://github.com/threefoldtech/Threefold-Circles/blob/production/taiga/threebot/api.py#L42

#### php

https://github.com/freeflowpages/freeflow-threebot-login/blob/master/authclient/ThreebotAuth.php#L26

https://github.com/freeflowpages/freeflow-threebot-login/blob/master/controllers/user/UserController.php#L43

#### Crystal lang

https://github.com/crystaluniverse/kemal-threebot

#### Go

See lines 137-179 as well as SignIn and VerifyCallback function in : 
https://github.com/threefoldtech/tf-gitea/blob/b63f8429483290e96fadbc7a9ca0bf9ff9c1232a/routers/user/auth.go

#### Python extra tooling 

##### Proxy for Redirection

A proxy written in python where u can talk to, using any language using http client. 
It can help you for url redirection for 3bot connect. You can define the call back in your application at any point, then get then same parameters sent by 3bot connect to your endpoint to this proxy to decrypt data for you. 
So you can verify whether the user has logged in, get his 3Bot name, e-mail etc. 

https://github.com/threefoldtech/threefold-forums/tree/master/3bot

##### Library

pyncal

Keys can be generated using 
`
import nacl.signing
nacl.signing.SigningKey.generate().encode(nacl.encoding.Base64Encoder)
`