CREATE TABLE projection_processed_events (
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    event_id UUID NOT NULL,
    consumer_name VARCHAR(128) NOT NULL,
    processed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    PRIMARY KEY (tenant_id, event_id, consumer_name)
);

CREATE TABLE account_activity_projection (
    tenant_id UUID NOT NULL REFERENCES tenants(id),
    event_id UUID NOT NULL,
    transaction_id UUID NOT NULL,
    ledger_id UUID NOT NULL,
    account_id UUID NOT NULL,
    line_sequence INTEGER NOT NULL CHECK (line_sequence > 0),
    direction VARCHAR(6) NOT NULL CHECK (direction IN ('DEBIT','CREDIT')),
    amount_minor BIGINT NOT NULL CHECK (amount_minor > 0),
    balance_after_minor BIGINT NOT NULL,
    currency CHAR(3) NOT NULL CHECK (currency ~ '^[A-Z]{3}$'),
    reference VARCHAR(200) NOT NULL,
    posted_at TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (tenant_id, event_id, line_sequence)
);
CREATE INDEX ix_activity_account_posted
    ON account_activity_projection(tenant_id, account_id, posted_at DESC, event_id);
CREATE INDEX ix_activity_transaction
    ON account_activity_projection(tenant_id, transaction_id);

ALTER TABLE projection_processed_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE projection_processed_events FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_projection_events ON projection_processed_events
    USING (tenant_id::text = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id::text = current_setting('app.tenant_id', true));

ALTER TABLE account_activity_projection ENABLE ROW LEVEL SECURITY;
ALTER TABLE account_activity_projection FORCE ROW LEVEL SECURITY;
CREATE POLICY tenant_isolation_account_activity ON account_activity_projection
    USING (tenant_id::text = current_setting('app.tenant_id', true))
    WITH CHECK (tenant_id::text = current_setting('app.tenant_id', true));

COMMENT ON TABLE projection_processed_events IS
    'Derived consumer deduplication state. Safe to rebuild together with its projection.';
COMMENT ON TABLE account_activity_projection IS
    'Derived account activity read model. Not financial source of truth; rebuild from durable events.';
