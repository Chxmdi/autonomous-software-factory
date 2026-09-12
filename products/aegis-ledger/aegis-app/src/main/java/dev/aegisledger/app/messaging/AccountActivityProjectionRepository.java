package dev.aegisledger.app.messaging;

import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.OffsetDateTime;
import java.time.ZoneOffset;
import java.util.Objects;
import java.util.UUID;

@Repository
public class AccountActivityProjectionRepository {
    public static final String CONSUMER_NAME = "account-activity-v1";

    private final NamedParameterJdbcTemplate jdbc;
    private final TransactionTemplate transactions;

    public AccountActivityProjectionRepository(
            NamedParameterJdbcTemplate jdbc,
            PlatformTransactionManager transactionManager) {
        this.jdbc = jdbc;
        this.transactions = new TransactionTemplate(transactionManager);
    }

    public boolean apply(LedgerTransactionPostedEvent event) {
        return Objects.requireNonNull(transactions.execute(status -> applyInTransaction(event)));
    }

    public void resetTenant(UUID tenantId) {
        transactions.executeWithoutResult(status -> {
            setTenant(tenantId);
            var params = new MapSqlParameterSource("tenantId", tenantId);
            jdbc.update("DELETE FROM account_activity_projection WHERE tenant_id = :tenantId", params);
            jdbc.update("DELETE FROM projection_processed_events WHERE tenant_id = :tenantId AND consumer_name = :consumerName",
                    params.addValue("consumerName", CONSUMER_NAME));
        });
    }

    private boolean applyInTransaction(LedgerTransactionPostedEvent event) {
        setTenant(event.tenantId());
        var dedupe = new MapSqlParameterSource()
                .addValue("tenantId", event.tenantId())
                .addValue("eventId", event.eventId())
                .addValue("consumerName", CONSUMER_NAME);
        int claimed = jdbc.update("""
                INSERT INTO projection_processed_events(tenant_id, event_id, consumer_name)
                VALUES (:tenantId, :eventId, :consumerName)
                ON CONFLICT (tenant_id, event_id, consumer_name) DO NOTHING
                """, dedupe);
        if (claimed == 0) return false;

        for (LedgerTransactionPostedEvent.Line line : event.lines()) {
            var params = new MapSqlParameterSource()
                    .addValue("tenantId", event.tenantId())
                    .addValue("eventId", event.eventId())
                    .addValue("transactionId", event.transactionId())
                    .addValue("ledgerId", event.ledgerId())
                    .addValue("accountId", line.accountId())
                    .addValue("lineSequence", line.lineSequence())
                    .addValue("direction", line.direction())
                    .addValue("amountMinor", line.amountMinor())
                    .addValue("balanceAfterMinor", line.balanceAfterMinor())
                    .addValue("currency", event.currency())
                    .addValue("reference", event.reference())
                    .addValue("postedAt", OffsetDateTime.ofInstant(event.occurredAt(), ZoneOffset.UTC));
            jdbc.update("""
                    INSERT INTO account_activity_projection(
                      tenant_id, event_id, transaction_id, ledger_id, account_id, line_sequence,
                      direction, amount_minor, balance_after_minor, currency, reference, posted_at)
                    VALUES (
                      :tenantId, :eventId, :transactionId, :ledgerId, :accountId, :lineSequence,
                      :direction, :amountMinor, :balanceAfterMinor, :currency, :reference, :postedAt)
                    """, params);
        }
        return true;
    }

    private void setTenant(UUID tenantId) {
        jdbc.getJdbcTemplate().queryForObject(
                "select set_config('app.tenant_id', ?, true)",
                String.class,
                tenantId.toString());
    }
}
