DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'aegis') THEN
    CREATE ROLE aegis LOGIN PASSWORD 'aegis-local-only'
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT NOREPLICATION;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'aegis_cdc') THEN
    CREATE ROLE aegis_cdc LOGIN PASSWORD 'aegis-cdc-local-only'
      NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT REPLICATION;
  END IF;
END $$;

GRANT CONNECT ON DATABASE aegis TO aegis;
GRANT USAGE, CREATE ON SCHEMA public TO aegis;

GRANT CONNECT ON DATABASE aegis TO aegis_cdc;
GRANT USAGE ON SCHEMA public TO aegis_cdc;

-- SELECT on the outbox table and the Debezium publication are granted/created only
-- after Flyway has created the schema. See infrastructure/debezium/prepare-cdc.sh.
