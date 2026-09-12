-- Guard against accidental truncate of financial truth through ordinary application roles.
-- Production must additionally use separate migration/runtime roles and revoke DDL from runtime.
CREATE OR REPLACE FUNCTION reject_journal_truncate() RETURNS trigger AS $$
BEGIN
    RAISE EXCEPTION 'journal tables cannot be truncated';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER journal_transactions_no_truncate
BEFORE TRUNCATE ON journal_transactions
FOR EACH STATEMENT EXECUTE FUNCTION reject_journal_truncate();

CREATE TRIGGER journal_lines_no_truncate
BEFORE TRUNCATE ON journal_lines
FOR EACH STATEMENT EXECUTE FUNCTION reject_journal_truncate();
