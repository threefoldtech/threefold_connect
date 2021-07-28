from database import update_table

update_productkeys_sql = """ ALTER TABLE productkeys ADD COLUMN IF NOT EXISTS activated_directly boolean default false; """
update_table(update_productkeys_sql)