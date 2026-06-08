ALTER TABLE public.users ADD COLUMN is_verified BOOLEAN DEFAULT false;

ALTER TABLE public.users ALTER COLUMN email DROP NOT NULL;
ALTER TABLE public.users ALTER COLUMN phone_number DROP NOT NULL;

ALTER TABLE public.users ADD CONSTRAINT users_email_or_phone_required
  CHECK (email IS NOT NULL OR phone_number IS NOT NULL);
