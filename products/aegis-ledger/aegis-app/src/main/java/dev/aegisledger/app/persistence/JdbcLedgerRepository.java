package dev.aegisledger.app.persistence;

import dev.aegisledger.application.CurrencyMismatchException;
import dev.aegisledger.application.IdempotencyConflictException;
import dev.aegisledger.application.IdempotencyInProgressException;
import dev.aegisledger.application.LedgerPostingPort;
import dev.aegisledger.application.PostTransactionCommand;
import dev.aegisledger.application.PostTransactionResult;
import dev.aegisledger.application.ResourceNotFoundException;
import dev.aegisledger.application.TransactionQueryPort;
import dev.aegisledger.domain.AccountId;
import dev.aegisledger.domain.AccountSnapshot;
import dev.aegisledger.domain.AccountStatus;
import dev.aegisledger.domain.BalanceRules;
import dev.aegisledger.domain.CurrencyCode;
import dev.aegisledger.domain.JournalDirection;
import dev.aegisledger.domain.JournalLineDraft;
import dev.aegisledger.domain.LedgerId;
import dev.aegisledger.domain.NegativeBalancePolicy;
import dev.aegisledger.domain.NormalBalance;
import dev.aegisledger.domain.TenantId;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;

import java.time.Instant;
import java.util.Comparator;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.UUID;

@Repository
public class JdbcLedgerRepository implements LedgerPostingPort, TransactionQueryPort {
    private static final String OPERATION = "POST_TRANSACTION";

    private final NamedParameterJdbcTemplate jdbc;
    private final TransactionTemplate transactions;

    public JdbcLedgerRepository(NamedParameterJdbcTemplate jdbc, PlatformTransactionManager transactionManager) {
        this.jdbc = jdbc;
        this.transactions = new TransactionTemplate(transactionManager);
    }

    @Override
    public PostTransactionResult post(PostTransactionCommand command) {
        return Objects.requireNonNull(transactions.execute(status -> postInTransaction(command)));
    }

    @Override
    public PostTransactionResult get(TenantId tenantId, UUID transactionId) {
        return Objects.requireNonNull(transactions.execute(status -> {
            setTenant(tenantId);
            return loadTransaction(tenantId, transactionId, false);
        }));
    }

    private PostTransactionResult postInTransaction(PostTransactionCommand command) {
        setTenant(command.tenantId());

        IdempotencyClaim claim = claimIdempotency(command);
        if (!claim.owner()) {
            if (!claim.requestHash().equals(command.requestHash())) throw new IdempotencyConflictException();
            if (!"COMPLETED".equals(claim.status()) || claim.resourceId() == null) throw new IdempotencyInProgressException();
            return loadTransaction(command.tenantId(), claim.resourceId(), true);
        }

        CurrencyCode ledgerCurrency = loadLedgerCurrency(command.tenantId(), command.ledgerId());
        if (!ledgerCurrency.equals(command.currency())) {
            throw new CurrencyMismatchException("Transaction currency %s does not match ledger currency %s"
                    .formatted(command.currency(), ledgerCurrency));
        }

        Map<AccountId, AccountSnapshot> accounts = lockAccounts(command);
        Map<AccountId, Long> effects = aggregateEffects(command, accounts);
        Map<AccountId, Long> resultingBalances = new LinkedHashMap<>();
        effects.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .forEach(entry -> resultingBalances.put(
                        entry.getKey(),
                        BalanceRules.validateAndApply(accounts.get(entry.getKey()), entry.getValue())));

        UUID transactionId = UUID.randomUUID();
        Instant postedAt = Instant.now();
        insertTransaction(command, transactionId, postedAt);
        insertLines(command, transactionId);
        updateBalances(accounts, resultingBalances);
        insertOutbox(command, transactionId, postedAt);
        completeIdempotency(command, transactionId, postedAt);

        return new PostTransactionResult(
                transactionId,
                "POSTED",
                command.reference(),
                command.currency(),
                command.effectiveAt(),
                postedAt,
                command.lines(),
                false);
    }

    private void setTenant(TenantId tenantId) {
        jdbc.getJdbcTemplate().queryForObject(
                "select set_config('app.tenant_id', ?, true)",
                String.class,
                tenantId.toString());
    }

    private IdempotencyClaim claimIdempotency(PostTransactionCommand command) {
        var params = new MapSqlParameterSource()
                .addValue("id", UUID.randomUUID())
                .addValue("tenantId", command.tenantId().value())
                .addValue("operation", OPERATION)
                .addValue("key", command.idempotencyKey())
                .addValue("hash", command.requestHash())
                .addValue("expiresAt", Instant.now().plusSeconds(72L * 60L * 60L));
        int inserted = jdbc.update("""
                INSERT INTO idempotency_records
                  (id, tenant_id, operation_type, idempotency_key, request_hash, status, expires_at)
                VALUES
                  (:id, :tenantId, :operation, :key, :hash, 'PROCESSING', :expiresAt)
                ON CONFLICT (tenant_id, operation_type, idempotency_key) DO NOTHING
                """, params);
        if (inserted == 1) return new IdempotencyClaim(true, command.requestHash(), "PROCESSING", null);

        List<IdempotencyClaim> rows = jdbc.query("""
                SELECT request_hash, status, resource_id
                FROM idempotency_records
                WHERE tenant_id = :tenantId AND operation_type = :operation AND idempotency_key = :key
                """, params, (rs, rowNum) -> new IdempotencyClaim(
                false,
                rs.getString("request_hash"),
                rs.getString("status"),
                rs.getObject("resource_id", UUID.class)));
        if (rows.size() != 1) throw new IllegalStateException("Idempotency conflict existed but record could not be loaded");
        return rows.getFirst();
    }

    private CurrencyCode loadLedgerCurrency(TenantId tenantId, LedgerId ledgerId) {
        var params = new MapSqlParameterSource("tenantId", tenantId.value()).addValue("ledgerId", ledgerId.value());
        List<CurrencyCode> rows = jdbc.query("""
                SELECT currency FROM ledgers WHERE tenant_id = :tenantId AND id = :ledgerId
                """, params, (rs, rowNum) -> CurrencyCode.of(rs.getString("currency")));
        if (rows.isEmpty()) throw new ResourceNotFoundException("Ledger not found");
        return rows.getFirst();
    }

    private Map<AccountId, AccountSnapshot> lockAccounts(PostTransactionCommand command) {
        List<UUID> accountIds = command.lines().stream()
                .map(line -> line.accountId().value())
                .distinct()
                .sorted()
                .toList();
        var params = new MapSqlParameterSource()
                .addValue("tenantId", command.tenantId().value())
                .addValue("ledgerId", command.ledgerId().value())
                .addValue("accountIds", accountIds);
        List<AccountSnapshot> rows = jdbc.query("""
                SELECT id, tenant_id, ledger_id, currency, normal_balance, negative_policy,
                       credit_limit_minor, posted_balance_minor, version, status
                FROM accounts
                WHERE tenant_id = :tenantId AND ledger_id = :ledgerId AND id IN (:accountIds)
                ORDER BY id
                FOR UPDATE
                """, params, (rs, rowNum) -> new AccountSnapshot(
                new AccountId(rs.getObject("id", UUID.class)),
                new TenantId(rs.getObject("tenant_id", UUID.class)),
                new LedgerId(rs.getObject("ledger_id", UUID.class)),
                CurrencyCode.of(rs.getString("currency")),
                NormalBalance.valueOf(rs.getString("normal_balance")),
                NegativeBalancePolicy.valueOf(rs.getString("negative_policy")),
                rs.getLong("credit_limit_minor"),
                rs.getLong("posted_balance_minor"),
                rs.getLong("version"),
                AccountStatus.valueOf(rs.getString("status"))));

        if (rows.size() != accountIds.size()) throw new ResourceNotFoundException("One or more accounts were not found in tenant/ledger");
        Map<AccountId, AccountSnapshot> map = new HashMap<>();
        rows.forEach(account -> map.put(account.id(), account));
        return map;
    }

    private Map<AccountId, Long> aggregateEffects(PostTransactionCommand command, Map<AccountId, AccountSnapshot> accounts) {
        Map<AccountId, Long> effects = new HashMap<>();
        for (JournalLineDraft line : command.lines()) {
            AccountSnapshot account = accounts.get(line.accountId());
            if (account == null) throw new ResourceNotFoundException("Account not found: " + line.accountId());
            if (!account.currency().equals(command.currency())) {
                throw new CurrencyMismatchException("Account %s currency %s does not match transaction %s"
                        .formatted(account.id(), account.currency(), command.currency()));
            }
            long effect = BalanceRules.signedEffect(account.normalBalance(), line.direction(), line.amountMinor());
            effects.merge(line.accountId(), effect, (left, right) -> Math.addExact(left, right));
        }
        return effects;
    }

    private void insertTransaction(PostTransactionCommand command, UUID transactionId, Instant postedAt) {
        var params = new MapSqlParameterSource()
                .addValue("id", transactionId)
                .addValue("tenantId", command.tenantId().value())
                .addValue("ledgerId", command.ledgerId().value())
                .addValue("reference", command.reference())
                .addValue("currency", command.currency().value())
                .addValue("correlationId", command.correlationId())
                .addValue("effectiveAt", command.effectiveAt())
                .addValue("postedAt", postedAt);
        jdbc.update("""
                INSERT INTO journal_transactions
                  (id, tenant_id, ledger_id, transaction_type, reference, currency, status,
                   correlation_id, effective_at, posted_at)
                VALUES
                  (:id, :tenantId, :ledgerId, 'GENERAL', :reference, :currency, 'POSTED',
                   :correlationId, :effectiveAt, :postedAt)
                """, params);
    }

    private void insertLines(PostTransactionCommand command, UUID transactionId) {
        int sequence = 1;
        for (JournalLineDraft line : command.lines()) {
            var params = new MapSqlParameterSource()
                    .addValue("id", UUID.randomUUID())
                    .addValue("tenantId", command.tenantId().value())
                    .addValue("ledgerId", command.ledgerId().value())
                    .addValue("transactionId", transactionId)
                    .addValue("accountId", line.accountId().value())
                    .addValue("sequence", sequence++)
                    .addValue("direction", line.direction().name())
                    .addValue("amount", line.amountMinor());
            jdbc.update("""
                    INSERT INTO journal_lines
                      (id, tenant_id, ledger_id, transaction_id, account_id, line_sequence, direction, amount_minor)
                    VALUES (:id, :tenantId, :ledgerId, :transactionId, :accountId, :sequence, :direction, :amount)
                    """, params);
        }
    }

    private void updateBalances(Map<AccountId, AccountSnapshot> accounts, Map<AccountId, Long> resultingBalances) {
        for (var entry : resultingBalances.entrySet().stream().sorted(Map.Entry.comparingByKey()).toList()) {
            AccountSnapshot account = accounts.get(entry.getKey());
            var params = new MapSqlParameterSource()
                    .addValue("id", account.id().value())
                    .addValue("tenantId", account.tenantId().value())
                    .addValue("version", account.version())
                    .addValue("balance", entry.getValue());
            int updated = jdbc.update("""
                    UPDATE accounts
                    SET posted_balance_minor = :balance, version = version + 1
                    WHERE tenant_id = :tenantId AND id = :id AND version = :version
                    """, params);
            if (updated != 1) throw new IllegalStateException("Account version changed despite deterministic row lock: " + account.id());
        }
    }

    private void insertOutbox(PostTransactionCommand command, UUID transactionId, Instant postedAt) {
        String payload = "{\"transactionId\":\"%s\",\"tenantId\":\"%s\",\"ledgerId\":\"%s\",\"postedAt\":\"%s\"}"
                .formatted(transactionId, command.tenantId(), command.ledgerId(), postedAt);
        var params = new MapSqlParameterSource()
                .addValue("id", UUID.randomUUID())
                .addValue("tenantId", command.tenantId().value())
                .addValue("aggregateId", transactionId)
                .addValue("key", transactionId.toString())
                .addValue("correlationId", command.correlationId())
                .addValue("payload", payload);
        jdbc.update("""
                INSERT INTO outbox_events
                  (id, tenant_id, aggregate_type, aggregate_id, event_type, event_version,
                   topic, event_key, correlation_id, payload)
                VALUES
                  (:id, :tenantId, 'JOURNAL_TRANSACTION', :aggregateId, 'ledger.transaction.posted', 1,
                   'aegis.ledger.posted', :key, :correlationId, CAST(:payload AS jsonb))
                """, params);
    }

    private void completeIdempotency(PostTransactionCommand command, UUID transactionId, Instant completedAt) {
        var params = new MapSqlParameterSource()
                .addValue("tenantId", command.tenantId().value())
                .addValue("operation", OPERATION)
                .addValue("key", command.idempotencyKey())
                .addValue("resourceId", transactionId)
                .addValue("completedAt", completedAt);
        int updated = jdbc.update("""
                UPDATE idempotency_records
                SET status = 'COMPLETED', resource_id = :resourceId, completed_at = :completedAt
                WHERE tenant_id = :tenantId AND operation_type = :operation AND idempotency_key = :key
                """, params);
        if (updated != 1) throw new IllegalStateException("Idempotency record could not be completed");
    }

    private PostTransactionResult loadTransaction(TenantId tenantId, UUID transactionId, boolean replayed) {
        var params = new MapSqlParameterSource("tenantId", tenantId.value()).addValue("transactionId", transactionId);
        List<TxRow> txRows = jdbc.query("""
                SELECT id, reference, currency, status, effective_at, posted_at
                FROM journal_transactions
                WHERE tenant_id = :tenantId AND id = :transactionId
                """, params, (rs, rowNum) -> new TxRow(
                rs.getObject("id", UUID.class),
                rs.getString("reference"),
                CurrencyCode.of(rs.getString("currency")),
                rs.getString("status"),
                rs.getTimestamp("effective_at").toInstant(),
                rs.getTimestamp("posted_at").toInstant()));
        if (txRows.isEmpty()) throw new ResourceNotFoundException("Transaction not found");
        TxRow tx = txRows.getFirst();
        List<JournalLineDraft> lines = jdbc.query("""
                SELECT account_id, direction, amount_minor
                FROM journal_lines
                WHERE tenant_id = :tenantId AND transaction_id = :transactionId
                ORDER BY line_sequence
                """, params, (rs, rowNum) -> new JournalLineDraft(
                new AccountId(rs.getObject("account_id", UUID.class)),
                JournalDirection.valueOf(rs.getString("direction")),
                rs.getLong("amount_minor")));
        return new PostTransactionResult(
                tx.id(), tx.status(), tx.reference(), tx.currency(), tx.effectiveAt(), tx.postedAt(), lines, replayed);
    }

    private record IdempotencyClaim(boolean owner, String requestHash, String status, UUID resourceId) {}
    private record TxRow(UUID id, String reference, CurrencyCode currency, String status, Instant effectiveAt, Instant postedAt) {}
}
