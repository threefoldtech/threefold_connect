from database import create_table

sql_create_table = """
CREATE TABLE `digitaltwin_dns` (
        `id` INTEGER PRIMARY KEY AUTOINCREMENT,
        `name` varchar(100) NOT NULL,
        `public_key` varchar(100) NOT NULL,
        `app_id` varchar(100) NOT NULL,
        `ip` varchar(100) NULL
    );
"""

create_table(sql_create_table)

# When we are logging into our digitaltwin we will create the following record:
# INSERT INTO digitaltwin_dns (name, public_key, app_id, ip) VALUES ('test.3bot', 'abc123', 'digitaltwin.be', NULL);

# The digitaltwin will be able to update the ip if the data is correctly signed.
# INSERT INTO digitaltwin_dns (name, public_key, app_id, ip) VALUES ('test.3bot', 'abc123', 'digitaltwin.be', NULL);

# All users will be able to query the backend and ask which ips test.3bot with digitaltwin.be has.
# SELECT app_id, ip FROM digitaltwin_dns where name = '';
