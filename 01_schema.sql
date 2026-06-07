-- ============================================================
-- Imagine Communications — SQL Practice Project
-- File: 01_schema.sql
-- Description: Schema creation for media broadcasting domain
-- Author: Sabin Mainali
-- Platform: Oracle 23ai Free
-- ============================================================

-- Regions: geographic territories Imagine operates in
CREATE TABLE regions (
    region_id     NUMBER PRIMARY KEY,
    region_name   VARCHAR2(50),
    region_code   VARCHAR2(10),
    updated_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Customers: broadcasters, IPTV providers, sports venues
CREATE TABLE customers (
    customer_id    NUMBER PRIMARY KEY,
    company_name   VARCHAR2(100),
    country        VARCHAR2(50),
    region_id      NUMBER REFERENCES regions(region_id),
    customer_type  VARCHAR2(50),   -- Broadcaster, IPTV Provider, Sports Venue, Streaming Service
    since_date     DATE,           -- NULL where onboarding date was not recorded
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products: Imagine's core software products
CREATE TABLE products (
    product_id     NUMBER PRIMARY KEY,
    product_name   VARCHAR2(100),
    category       VARCHAR2(50),   -- Playout, Ad Scheduling, Traffic and Billing, etc.
    annual_price   NUMBER(12,2),
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Contracts: software license agreements with customers
CREATE TABLE contracts (
    contract_id    NUMBER PRIMARY KEY,
    customer_id    NUMBER REFERENCES customers(customer_id),
    start_date     DATE,
    end_date       DATE,
    total_value    NUMBER(12,2),   -- NULL for cancelled contracts
    status         VARCHAR2(20),   -- Active, Expired, Renewed, Cancelled
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Contract Lines: individual product lines within each contract
CREATE TABLE contract_lines (
    line_id        NUMBER PRIMARY KEY,
    contract_id    NUMBER REFERENCES contracts(contract_id),
    product_id     NUMBER REFERENCES products(product_id),
    quantity       NUMBER,
    unit_price     NUMBER(12,2),
    line_total     NUMBER(12,2),   -- unit_price x quantity
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Support Tickets: customer issues raised against contracts
CREATE TABLE support_tickets (
    ticket_id      NUMBER PRIMARY KEY,
    contract_id    NUMBER REFERENCES contracts(contract_id),
    customer_id    NUMBER REFERENCES customers(customer_id),
    created_date   DATE,
    resolved_date  DATE,           -- NULL for unresolved tickets
    priority       VARCHAR2(20),   -- Critical, High, Medium, Low
    category       VARCHAR2(50),   -- Playout Issue, Billing Error, Integration, Training
    status         VARCHAR2(20),   -- Open, In Progress, Resolved, Closed
    updated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
