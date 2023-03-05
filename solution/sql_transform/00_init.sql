-- schema
DROP SCHEMA IF EXISTS raw_data CASCADE;

CREATE SCHEMA IF NOT EXISTS raw_data;

DROP SCHEMA IF EXISTS data_mart CASCADE;

CREATE SCHEMA IF NOT EXISTS data_mart;

-- uuid

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
