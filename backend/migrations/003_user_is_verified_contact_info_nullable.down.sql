ALTER TABLE users DROP COLUMN is_verified;

ALTER TABLE users ALTER COLUMN email ADD NOT NULL;
ALTER TABLE users ALTER COLUMN phone_number ADD NOT NULL;

ALTER TABLE users DROP CONSTRAINT users_email_or_phone_required
