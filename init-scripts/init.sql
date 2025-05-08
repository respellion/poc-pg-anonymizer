\c postgres

\echo 'Populate the database with some test data'
CREATE TABLE people ( id TEXT, firstname TEXT, lastname TEXT, phone TEXT);
INSERT INTO people VALUES ('T1','Sarah', 'Conor','0609110911');
INSERT INTO people VALUES ('T2','John', 'Conor','1234567879');

\echo 'Create the the PostgreSQL Anonymizer extension'
CREATE EXTENSION IF NOT EXISTS anon CASCADE;
SELECT anon.version();

\echo 'Enable dynamic masking'
ALTER DATABASE postgres SET anon.transparent_dynamic_masking TO true;


\echo 'Declare a masked user "skynet" with read access'
CREATE ROLE skynet LOGIN;
SECURITY LABEL FOR anon ON ROLE skynet IS 'MASKED';
GRANT pg_read_all_data to skynet;

\echo 'Declare the masking rules'
SECURITY LABEL FOR anon ON COLUMN people.lastname IS 'MASKED WITH FUNCTION anon.fake_last_name()';
SECURITY LABEL FOR anon ON COLUMN people.phone IS 'MASKED WITH FUNCTION anon.partial(phone,2,$$******$$,2)';
SELECT anon.start_dynamic_masking();

\echo 'Query data as current user'
SELECT * FROM people;

\echo 'Query data as "skynet" user'
\c - skynet
SELECT * FROM people;


