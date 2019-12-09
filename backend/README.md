# 3botlogin_backend
The (temporary) backend for 3Bot login.

## Data to save
### User
A user is someone that authenticates using 3botlogin.

| Key | Type | Example | Description |
| --- | --- | --- | --- |
| double_name | String | ivan.coene | The name of the user (case insensitive) | 
| sid | String | EWFWEGFWGWGWDS | Socket ID |
| email | String | ivan.coene@gmail.com | The email of the user (case insensitive) | 
| public_key | string | G1gcbyeTnR2i...H8_3yV3cuF | The public key of the user to verify access |
| device_id | String | abc | The ID of the device where we can send notifications to | 


### Login attempt
When a user tries to log in, an entry is added

| Key | Type | Example | Description |
| --- | --- | --- | --- |
| double_name | String | ivan.coene | The name of the user (case insensitive) |  
| state_hash | String | 1gcbyeTnR2iZSfx6r2qIuvhH8 | The "identifier" of a login-attempt |
| timestamp | Datetime | 2002-12-25 00:00:00-06:39 | The time when this satehash came in |
| scanned | Boolean | false | Flag to keep the QR-scanned state |
| singed_statehash | String | 1gcbyeTnR2iZSfx6r2qIuvhH8 | The signed version of the state hash|

## Run in dev mode
To run the backend in devmode simply execute following command
```
python3 .
```
## SQLite

pip install pysqlite 

sudo apt get install sqlite3

## Config file
Rename config.ini.example to config.ini and add your API key.