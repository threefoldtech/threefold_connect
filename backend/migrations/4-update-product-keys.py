# @TODO: REMOVE THIS FILE ALSO ON STAGING
update_productkeys_sql = """ ALTER TABLE productkeys ADD COLUMN IF NOT EXISTS activated_directly boolean default false; """