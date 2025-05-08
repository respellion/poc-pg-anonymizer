# PoC Postgres Anonymizer

PoC for testing [Postgres Anonymizer](https://postgresql-anonymizer.readthedocs.io/en/stable/) using Docker Compose and an init SQL file.


## Configuration

1. Copy/rename the `.env.sample` file to `.env` file and modify if necessary.

## Usage
1. Start with `docker compose up -d` (or just: `docker compose up postgres`)
1. Check logs in Docker Desktop or the console


### Database initialization

The `init-scripts/init.sql` file gets executed when the container starts up for the first time. To re-initialze the database after modifying this file, run the command below. 

**WARN**: this removes the current database.

```
docker compose down -v
```

The initialization SQL script populates the database and configures two dynamic masking rules. It creates a new role 'skynet' and enables anonymization for this role. The script then proves that dynamic masking is enabled by querying data as the default 'admin' user and when being connected with the 'skynet' role. It should output something like:

```
Query data as current user
id | firstname | lastname | phone
----+-----------+----------+------------
T1 | Sarah | Conor | 0609110911
T2 | John | Conor | 1234567879
(2 rows)

Query data as "skynet" user
You are now connected to database "postgres" as user "skynet".
id | firstname | lastname | phone
----+-----------+----------+------------
T1 | Sarah | Payne | 06******11
T2 | John | Clay | 12******79
(2 rows)
```

PG Anonymizer supports many types of [masking functions](https://postgresql-anonymizer.readthedocs.io/en/stable/masking_functions/).