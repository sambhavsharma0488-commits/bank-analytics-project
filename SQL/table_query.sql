CREATE TABLE customers (
    customer_id   INT PRIMARY KEY,
    name          VARCHAR(100),
    age           INT,
    gender        VARCHAR(10),
    city          VARCHAR(50),
    state         VARCHAR(50),
    join_date     DATE,
    account_type  VARCHAR(20),
    occupation    VARCHAR(30)
);

CREATE TABLE transactions (
    txn_id        INT PRIMARY KEY,
    customer_id   INT REFERENCES customers(customer_id),
    txn_date      DATE,
    txn_type      VARCHAR(20),
    txn_amount    DECIMAL(12,2),
    product       VARCHAR(20),
    channel       VARCHAR(20),
    status        VARCHAR(20)
);

CREATE TABLE loans (
    loan_id          INT PRIMARY KEY,
    customer_id      INT REFERENCES customers(customer_id),
    loan_type        VARCHAR(20),
    loan_amount      DECIMAL(12,2),
    interest_rate    DECIMAL(5,2),
    tenure_months    INT,
    emi_amount       DECIMAL(12,2),
    disbursed_date   DATE,
    missed_payments  INT,
    loan_status      VARCHAR(20)
);