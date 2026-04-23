-- Portfolio Management System — Database Schema
-- Wells Fargo Software Engineering Virtual Experience
-- Backend: Java 17 + Spring Boot | DB: PostgreSQL

-- ─────────────────────────────────────────────
-- TABLE: financial_advisor
-- ─────────────────────────────────────────────
CREATE TABLE financial_advisor (
    id          BIGSERIAL       PRIMARY KEY,
    first_name  VARCHAR(100)    NOT NULL,
    last_name   VARCHAR(100)    NOT NULL,
    email       VARCHAR(255)    NOT NULL UNIQUE,
    phone       VARCHAR(20),
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ─────────────────────────────────────────────
-- TABLE: client
-- ─────────────────────────────────────────────
CREATE TABLE client (
    id          BIGSERIAL       PRIMARY KEY,
    advisor_id  BIGINT          NOT NULL,
    first_name  VARCHAR(100)    NOT NULL,
    last_name   VARCHAR(100)    NOT NULL,
    email       VARCHAR(255)    NOT NULL UNIQUE,
    phone       VARCHAR(20),
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_client_advisor
        FOREIGN KEY (advisor_id)
        REFERENCES financial_advisor(id)
        ON DELETE RESTRICT
);

-- ─────────────────────────────────────────────
-- TABLE: portfolio
-- 1-to-1 with client (UNIQUE constraint enforces this)
-- ─────────────────────────────────────────────
CREATE TABLE portfolio (
    id          BIGSERIAL       PRIMARY KEY,
    client_id   BIGINT          NOT NULL UNIQUE,   -- UNIQUE = 1-to-1
    name        VARCHAR(255)    NOT NULL DEFAULT 'My Portfolio',
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_portfolio_client
        FOREIGN KEY (client_id)
        REFERENCES client(id)
        ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- TABLE: security
-- ─────────────────────────────────────────────
CREATE TABLE security (
    id              BIGSERIAL       PRIMARY KEY,
    portfolio_id    BIGINT          NOT NULL,
    name            VARCHAR(255)    NOT NULL,
    category        VARCHAR(100)    NOT NULL,       -- Equity, Bond, ETF, Mutual Fund, etc.
    purchase_date   DATE            NOT NULL,
    purchase_price  DECIMAL(15, 4)  NOT NULL,       -- DECIMAL avoids float rounding in financial calc
    quantity        INT             NOT NULL CHECK (quantity > 0),
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_security_portfolio
        FOREIGN KEY (portfolio_id)
        REFERENCES portfolio(id)
        ON DELETE CASCADE
);

-- ─────────────────────────────────────────────
-- INDEXES
-- ─────────────────────────────────────────────
-- Advisor → client (most frequent access pattern)
CREATE INDEX idx_client_advisor_id     ON client(advisor_id);

-- Portfolio lookup by client
CREATE INDEX idx_portfolio_client_id   ON portfolio(client_id);

-- Securities by portfolio (dashboard load)
CREATE INDEX idx_security_portfolio_id ON security(portfolio_id);

-- Filter by category (analytics / reporting)
CREATE INDEX idx_security_category     ON security(category);

-- Date range queries on purchase history
CREATE INDEX idx_security_purchase_date ON security(purchase_date);

-- ─────────────────────────────────────────────
-- SAMPLE DATA
-- ─────────────────────────────────────────────
INSERT INTO financial_advisor (first_name, last_name, email, phone)
VALUES ('Sarah', 'Chen', 'sarah.chen@wf.example.com', '+1-415-555-0101');

INSERT INTO client (advisor_id, first_name, last_name, email, phone)
VALUES (1, 'James', 'Harrington', 'james.h@example.com', '+1-212-555-0202');

INSERT INTO portfolio (client_id, name)
VALUES (1, 'Retirement Portfolio');

INSERT INTO security (portfolio_id, name, category, purchase_date, purchase_price, quantity)
VALUES
    (1, 'Apple Inc.',                 'Equity',      '2024-01-15', 185.5000, 50),
    (1, 'US Treasury Bond 2030',      'Bond',        '2024-02-01', 98.2500,  10),
    (1, 'Vanguard S&P 500 ETF',       'ETF',         '2024-03-10', 450.0000, 20),
    (1, 'Fidelity Contrafund',        'Mutual Fund', '2024-04-05', 175.3300, 15);
