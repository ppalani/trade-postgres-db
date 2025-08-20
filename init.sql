
--
-- init.sql - Database initialization for trading schema and user
--
-- This script is run by the Postgres superuser at container startup.
-- User, password, and schema names are injected from .env using envsubst in Docker Compose.
--

-- Create the trading user if it does not exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = '${TRADE_USER}') THEN
        EXECUTE format('CREATE USER %I WITH PASSWORD %L', '${TRADE_USER}', '${TRADE_PASSWORD}');
    END IF;
END$$;

-- Create the trading schema and grant privileges to the trading user
CREATE SCHEMA IF NOT EXISTS ${TRADE_SCHEMA} AUTHORIZATION ${TRADE_USER};
GRANT ALL PRIVILEGES ON SCHEMA ${TRADE_SCHEMA} TO ${TRADE_USER};

-- Create the trade_details table in the trading schema
CREATE TABLE IF NOT EXISTS ${TRADE_SCHEMA}.trade_details (
    id SERIAL PRIMARY KEY,
    symbol VARCHAR(10),
    price DECIMAL(10, 2),
    quantity INT,
    trade_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data into the trade_details table
INSERT INTO ${TRADE_SCHEMA}.trade_details (symbol, price, quantity) VALUES
    ('AAPL', 150.00, 100),
    ('GOOGL', 2800.00, 50),
    ('AMZN', 3500.00, 30);
