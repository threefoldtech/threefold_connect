from database import update_table

update_users_sql = """ ALTER TABLE users ADD COLUMN twin_id integer, ADD COLUMN phone text, ADD COLUMN identity_reference text; """
update_table(update_users_sql)
