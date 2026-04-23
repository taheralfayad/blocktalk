ALTER TABLE users ADD COLUMN is_verified BOOLEAN DEFAULT false;

ALTER TABLE users ALTER COLUMN email DROP NOT NULL;
ALTER TABLE users ALTER COLUMN phone_number DROP NOT NULL;

ALTER TABLE users ADD CONSTRAINT users_email_or_phone_required
  CHECK (email IS NOT NULL OR phone_number IS NOT NULL);
