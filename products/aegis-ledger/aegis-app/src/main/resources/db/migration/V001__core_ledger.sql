CREATE TABLE tenants (
    id UUID PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE ledgers (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    name VARCHAR(200) NOT NULL,
    currency CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (tenant_id, name),
    UNIQUE (tenant_id, id),
    UNIQUE (tenant_id, id, currency)
);

CREATE TABLE accounts (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    ledger_id UUID NOT NULL,
    account_type VARCHAR(32) NOT NULL CHECK (account_type IN ('ASSET','LIABILITY','EQUITY','REVENUE','EXPENSE')),
    operational_role VARCHAR(64) NOT NULL,
    normal_balance VARCHAR(6) NOT NULL CHECK (normal_balance IN ('DEBIT','CREDIT')),
    currency CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    status VARCHAR(16) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','FROZEN','CLOSING','CLOSED')),
    negative_policy VARCHAR(32) NOT NULL CHECK (negative_policy IN ('ALLOW_NEGATIVE','DISALLOW_NEGATIVE','LIMITED_NEGATIVE')),
    credit_limit_minor BIGINT NOT NULL DEFAULT 0 CHECK (credit_limit_minor >= 0),
    posted_balance_minor BIGINT NOT NULL DEFAULT 0,
    version BIGINT NOT NULL DEFAULT 0 CHECK (version >= 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    closed_at TIMESTAMPTZ,
    CONSTRAINT fk_account_ledger FOREIGN KEY (tenant_id, ledger_id, currency) REFERENCES ledgers(tenant_id, id, currency),
    CONSTRAINT ck_account_credit_policy CHECK (
        (negative_policy = 'LIMITED_NEGATIVE') OR credit_limit_minor = 0
    ),
    CONSTRAINT ck_account_balance_floor CHECK (
        negative_policy = 'ALLOW_NEGATIVE'
        OR (negative_policy = 'DISALLOW_NEGATIVE' AND posted_balance_minor >= 0)
        OR (negative_policy = 'LIMITED_NEGATIVE' AND posted_balance_minor >= -credit_limit_minor)
    ),
    UNIQUE (tenant_id, id),
    UNIQUE (tenant_id, ledger_id, id)
);
CREATE INDEX ix_accounts_tenant_ledger ON accounts(tenant_id, ledger_id);

CREATE TABLE journal_transactions (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    ledger_id UUID NOT NULL,
    transaction_type VARCHAR(64) NOT NULL,
    reference VARCHAR(200) NOT NULL,
    currency CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    status VARCHAR(16) NOT NULL CHECK (status IN ('POSTED','REVERSED')),
    correlation_id VARCHAR(128) NOT NULL,
    effective_at TIMESTAMPTZ NOT NULL,
    posted_at TIMESTAMPTZ NOT NULL,
    reversal_of_transaction_id UUID,
    CONSTRAINT fk_journal_ledger FOREIGN KEY (tenant_id, ledger_id, currency) REFERENCES ledgers(tenant_id, id, currency),
    CONSTRAINT fk_reversal FOREIGN KEY (tenant_id, reversal_of_transaction_id) REFERENCES journal_transactions(tenant_id, id),
    UNIQUE (tenant_id, id),
    UNIQUE (tenant_id, ledger_id, id)
);
CREATE INDEX ix_journal_tx_tenant_posted ON journal_transactions(tenant_id, posted_at DESC);
CREATE INDEX ix_journal_tx_reference ON journal_transactions(tenant_id, reference);

CREATE TABLE journal_lines (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL,
    ledger_id UUID NOT NULL,
    transaction_id UUID NOT NULL,
    account_id UUID NOT NULL,
    line_sequence INTEGER NOT NULL CHECK (line_sequence > 0),
    direction VARCHAR(6) NOT NULL CHECK (direction IN ('DEBIT','CREDIT')),
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    CONSTRAINT fk_line_transaction FOREIGN KEY (tenant_id, ledger_id, transaction_id)
        REFERENCES journal_transactions(tenant_id, ledger_id, id),
    CONSTRAINT fk_line_account FOREIGN KEY (tenant_id, ledger_id, account_id)
        REFERENCES accounts(tenant_id, ledger_id, id),
    UNIQUE (transaction_id, line_sequence)
);
CREATE INDEX ix_journal_lines_account ON journal_lines(tenant_id, account_id, transaction_id);

CREATE TABLE idempotency_records (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    operation_type VARCHAR(64) NOT NULL,
    idempotency_key VARCHAR(128) NOT NULL,
    request_hash VARCHAR(64) NOT NULL CHECK (request_hash ~ '^[0-9a-f]{64}$'),
    status VARCHAR(16) NOT NULL CHECK (status IN ('PROCESSING','COMPLETED')),
    resource_id UUID,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    completed_at TIMESTAMPTZ,
    expires_at TIMESTAMPTZ NOT NULL,
    UNIQUE (tenant_id, operation_type, idempotency_key)
);
CREATE INDEX ix_idempotency_expiry ON idempotency_records(expires_at);

CREATE TABLE outbox_events (
    id UUID PRIMARY KEY,
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    aggregate_type VARCHAR(64) NOT NULL,
    aggregate_id UUID NOT NULL,
    event_type VARCHAR(128) NOT NULL,
    event_version INTEGER NOT NULL CHECK (event_version > 0),
    topic VARCHAR(200) NOT NULL,
    event_key VARCHAR(200) NOT NULL,
    correlation_id VARCHAR(128) NOT NULL,
    payload JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX ix_outbox_created ON outbox_events(created_at, id);

CREATE OR REPLACE FUNCTION prevent_journal_mutation() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'posted journal data is immutable';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER journal_transactions_immutable
BEFORE UPDATE OR DELETE ON journal_transactions
FOR EACH ROW EXECUTE FUNCTION prevent_journal_mutation();

CREATE TRIGGER journal_lines_immutable
BEFORE UPDATE OR DELETE ON journal_lines
FOR EACH ROW EXECUTE FUNCTION prevent_journal_mutation();

CREATE OR REPLACE FUNCTION verify_balanced_transaction() RETURNS trigger AS $$
DECLARE
    target_tx UUID;
    debit_total NUMERIC;
    credit_total NUMERIC;
    line_count INTEGER;
BEGIN
    target_tx := NEW.transaction_id;
    SELECT
        COUNT(*),
        COALESCE(SUM(CASE WHEN direction = 'DEBIT' THEN amount_minor ELSE 0 END), 0),
        COALESCE(SUM(CASE WHEN direction = 'CREDIT' THEN amount_minor ELSE 0 END), 0)
    INTO line_count, debit_total, credit_total
    FROM journal_lines
    WHERE transaction_id = target_tx;

    IF line_count < 2 OR debit_total <> credit_total THEN
        RAISE EXCEPTION 'journal transaction % is unbalanced: lines %, debits %, credits %',
            target_tx, line_count, debit_total, credit_total;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE CONSTRAINT TRIGGER journal_balance_guard
AFTER INSERT ON journal_lines
DEFERRABLE INITIALLY DEFERRED
FOR EACH ROW EXECUTE FUNCTION verify_balanced_transaction();

-- Defense-in-depth tenant isolation. Runtime transactions must call
-- SELECT set_config('app.tenant_id', '<tenant-uuid>', true) before tenant-owned queries.
DO $$
DECLARE
    table_name TEXT;
BEGIN
    FOREACH table_name IN ARRAY ARRAY[
        'ledgers','accounts','journal_transactions','journal_lines','idempotency_records','outbox_events'
    ] LOOP
        EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', table_name);
        EXECUTE format('ALTER TABLE %I FORCE ROW LEVEL SECURITY', table_name);
        EXECUTE format(
            'CREATE POLICY tenant_isolation ON %I USING (tenant_id::text = current_setting(''app.tenant_id'', true)) WITH CHECK (tenant_id::text = current_setting(''app.tenant_id'', true))',
            table_name
        );
    END LOOP;
END $$;
