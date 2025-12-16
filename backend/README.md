# ThreeFold Connect Backend

Modern Python backend for ThreeFold Connect authentication and digital twin management.

## Quick Start

### Prerequisites

- Python 3.11+
- Poetry (for dependency management)
- Docker (optional, for containerized deployment)

### Local Development

```bash
# Install dependencies
poetry install

# Run the backend
poetry run python __main__.py
```

Or activate the virtual environment:

```bash
poetry shell
python __main__.py
```

The backend will start on `http://localhost:5000`

### Docker Development

```bash
# Build the image
docker build -t threefold-connect .

# Run the container
docker run -d -p 5000:5000 \
  -v $(pwd)/pythonsqlite.db:/usr/share/nginx/backend/pythonsqlite.db \
  -v $(pwd)/config.ini:/usr/share/nginx/backend/config.ini \
  threefold-connect
```

## Data to save

### User

A user is someone that authenticates using 3botlogin.

| Key         | Type    |  Example                  | Description                                             |
| ----------- | ------- | ------------------------- | ------------------------------------------------------- |
| double_name |  String | ivan.coene                | The name of the user (case insensitive)                 |
| sid         |  String | EWFWEGFWGWGWDS            | Socket ID                                               |
| email       |  String | <ivan.coene@gmail.com>    | The email of the user (case insensitive)                |
| public_key  |  string | G1gcbyeTnR2i...H8_3yV3cuF | The public key of the user to verify access             |
| device_id   |  String | abc                       | The ID of the device where we can send notifications to |

### Login attempt

When a user tries to log in, an entry is added

| Key              | Type     |  Example                   | Description                             |
| ---------------- | -------- | -------------------------- | --------------------------------------- |
| double_name      |  String  | ivan.coene                 | The name of the user (case insensitive) |
| state_hash       | String   | 1gcbyeTnR2iZSfx6r2qIuvhH8  |  The "identifier" of a login-attempt    |
|  timestamp       | Datetime |  2002-12-25 00:00:00-06:39 | The time when this satehash came in     |
| scanned          | Boolean  | false                      | Flag to keep the QR-scanned state       |
| singed_statehash | String   | 1gcbyeTnR2iZSfx6r2qIuvhH8  |  The signed version of the state hash   |

## Run in dev mode

- Check [configurations](##config-file)
- To run the backend in devmode simply execute following command

```bash
python3 .
```

## SQLite

pip install pysqlite

sudo apt-get install sqlite3

## Config file

Rename config.ini.example to config.ini and add your API key.
