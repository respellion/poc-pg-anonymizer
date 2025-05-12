\c postgres

\echo 'Create the the PostgreSQL Anonymizer extension'
CREATE EXTENSION IF NOT EXISTS anon CASCADE;
\echo 'Enable dynamic masking'
ALTER DATABASE postgres SET anon.transparent_dynamic_masking TO true;
SELECT anon.init();

\echo 'Create a "people_tbl" table and populate it with some test data'
CREATE TABLE people_tbl ( id TEXT, firstname TEXT, lastname TEXT, phone TEXT);
INSERT INTO people_tbl VALUES ('T1','Sarah', 'Conor','0609110911');
INSERT INTO people_tbl VALUES ('T2','John', 'Conor','1234567879');


\echo 'Create an anonimized view "people_view" based on the people_tbl table'
CREATE MATERIALIZED VIEW people_view AS
SELECT 
    id, 
    anon.fake_first_name() AS firstname, 
    anon.fake_last_name() as lastname, 
    anon.partial(phone,2,$$******$$,2) AS phone
FROM people_tbl;

\echo 'Create a "people_masked" table and populate it with the same data as the people_tbl table'
CREATE TABLE people_masked AS TABLE people_tbl;

\echo 'Declare a masked user "skynet" with read access'
CREATE ROLE skynet LOGIN;
SECURITY LABEL FOR anon ON ROLE skynet IS 'MASKED';
GRANT pg_read_all_data to skynet;

\echo 'Declare the masking rules'
SECURITY LABEL FOR anon ON COLUMN people_masked.firstname IS 'MASKED WITH FUNCTION anon.fake_first_name()';
SECURITY LABEL FOR anon ON COLUMN people_masked.lastname IS 'MASKED WITH FUNCTION anon.fake_last_name()';
SECURITY LABEL FOR anon ON COLUMN people_masked.phone IS 'MASKED WITH FUNCTION anon.partial(phone,2,$$******$$,2)';
SELECT anon.start_dynamic_masking();


\echo '=== Query people table as admin user ==='
\echo 'people_tbl table'
SELECT * FROM people_tbl;
\echo 'people_view - anonimized data'
SELECT * FROM people_view;
\echo '=== Find Sarah but return anonimized data ==='
SELECT people_view.* 
    FROM people_view 
    JOIN people_tbl ON people_view.id = people_tbl.id 
    WHERE people_tbl.firstname = 'Sarah';


\echo '=== Query people_masked table as "admin" user - returns UNmasked/original data ==='
SELECT * FROM people_masked;

\c - skynet
\echo '=== Query people_masked table as "skynet" user - returns masked data ==='
SELECT * FROM people_masked;
