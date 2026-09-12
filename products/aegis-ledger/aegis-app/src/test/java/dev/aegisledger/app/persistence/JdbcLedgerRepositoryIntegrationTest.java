package dev.aegisledger.app.persistence;

import dev.aegisledger.application.IdempotencyConflictException;
import dev.aegisledger.application.LedgerPostingPort;
import dev.aegisledger.application.PostTransactionCommand;
import dev.aegisledger.domain.AccountId;
import dev.aegisledger.domain.CurrencyCode;
import dev.aegisledger.domain.InsufficientFundsException;
import dev.aegisledger.domain.JournalDirection;
import dev.aegisledger.domain.JournalLineDraft;
import dev.aegisledger.domain.LedgerId;
import dev.aegisledger.domain.TenantId;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.dao.DataAccessException;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import org.testcontainers.containers.PostgreSQLContainer;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.Callable;
import java.util.concurrent.Executors;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest
@ActiveProfiles("local")
@Testcontainers
class JdbcLedgerRepositoryIntegrationTest {
    @Container
    static final PostgreSQLContainer<?> POSTGRES = new PostgreSQLContainer<>("postgres:18.6-alpine")
            .withDatabaseName("aegis")
            .withUsername("aegis")
            .withPassword("admin-test")
            .withInitScript("db/test-init.sql");

    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", () -> "aegis");
        registry.add("spring.datasource.password", () -> "aegis-test");
    }

    @Autowired LedgerPostingPort postingPort;
    @Autowired NamedParameterJdbcTemplate jdbc;
    @Autowired PlatformTransactionManager txManager;

    @Test
    void idempotentReplayReturnsSameTransactionAndDoesNotDuplicateJournal() {
        Fixture f = seed(1_000);
        PostTransactionCommand command = command(f, "idem-1", "a".repeat(64), 100, "purchase-idem");

        var first = postingPort.post(command);
        var second = postingPort.post(command);

        assertEquals(first.transactionId(), second.transactionId());
        assertTrue(second.replayed());
        assertEquals(1L, journalCount(f.tenant(), "purchase-idem"));
    }

    @Test
    void sameIdempotencyKeyWithDifferentHashConflicts() {
        Fixture f = seed(1_000);
        postingPort.post(command(f, "idem-conflict", "a".repeat(64), 100, "purchase-conflict"));
        assertThrows(IdempotencyConflictException.class,
                () -> postingPort.post(command(f, "idem-conflict", "b".repeat(64), 100, "purchase-conflict")));
    }

    @Test
    void concurrentDebitsNeverOverdrawProtectedAccount() throws Exception {
        Fixture f = seed(100);
        int attempts = 200;
        List<Callable<Boolean>> tasks = new ArrayList<>();
        for (int i = 0; i < attempts; i++) {
            int n = i;
            tasks.add(() -> {
                try {
                    postingPort.post(command(f, "concurrent-" + n, String.format("%064x", n + 1L), 1, "race-" + n));
                    return true;
                } catch (InsufficientFundsException expected) {
                    return false;
                }
            });
        }

        int successes;
        try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
            successes = executor.invokeAll(tasks).stream().mapToInt(future -> {
                try { return future.get() ? 1 : 0; }
                catch (Exception e) { throw new RuntimeException(e); }
            }).sum();
        }

        assertEquals(100, successes);
        assertEquals(0L, accountBalance(f.tenant(), f.customer()));
        assertEquals(100L, accountBalance(f.tenant(), f.merchant()));
        assertEquals(100L, journalCountPrefix(f.tenant(), "race-"));
    }

    @Test
    void rowLevelSecurityHidesOtherTenantAccounts() {
        Fixture tenantA = seed(10);
        Fixture tenantB = seed(10);
        TransactionTemplate tx = new TransactionTemplate(txManager);
        long visible = tx.execute(status -> {
            jdbc.getJdbcTemplate().queryForObject("select set_config('app.tenant_id', ?, true)", String.class, tenantA.tenant().toString());
            return jdbc.queryForObject("select count(*) from accounts where id=:id",
                    new MapSqlParameterSource("id", tenantB.customer().value()), Long.class);
        });
        assertEquals(0L, visible);
    }

    @Test
    void postedJournalCannotBeMutated() {
        Fixture f = seed(100);
        var result = postingPort.post(command(f, "immutability", "c".repeat(64), 10, "immutable"));
        TransactionTemplate tx = new TransactionTemplate(txManager);
        assertThrows(DataAccessException.class, () -> tx.executeWithoutResult(status -> {
            jdbc.getJdbcTemplate().queryForObject("select set_config('app.tenant_id', ?, true)", String.class, f.tenant().toString());
            jdbc.update("update journal_transactions set reference='tampered' where tenant_id=:tenant and id=:id",
                    new MapSqlParameterSource("tenant", f.tenant().value()).addValue("id", result.transactionId()));
        }));
    }

    private PostTransactionCommand command(Fixture f, String idempotencyKey, String requestHash, long amount, String reference) {
        return new PostTransactionCommand(
                f.tenant(), f.ledger(), CurrencyCode.of("CAD"), idempotencyKey, requestHash, reference,
                "test-correlation-" + UUID.randomUUID(), Instant.parse("2026-09-11T19:00:00Z"),
                List.of(
                        new JournalLineDraft(f.customer(), JournalDirection.DEBIT, amount),
                        new JournalLineDraft(f.merchant(), JournalDirection.CREDIT, amount)));
    }

    private Fixture seed(long customerBalance) {
        TenantId tenant = new TenantId(UUID.randomUUID());
        LedgerId ledger = new LedgerId(UUID.randomUUID());
        AccountId customer = new AccountId(UUID.randomUUID());
        AccountId merchant = new AccountId(UUID.randomUUID());
        jdbc.getJdbcTemplate().update("insert into tenants(id,name) values (?,?)", tenant.value(), "Tenant " + tenant);

        TransactionTemplate tx = new TransactionTemplate(txManager);
        tx.executeWithoutResult(status -> {
            jdbc.getJdbcTemplate().queryForObject("select set_config('app.tenant_id', ?, true)", String.class, tenant.toString());
            jdbc.update("insert into ledgers(id,tenant_id,name,currency) values (:id,:tenant,'CAD Ledger','CAD')",
                    new MapSqlParameterSource("id", ledger.value()).addValue("tenant", tenant.value()));
            jdbc.update("""
                    insert into accounts(id,tenant_id,ledger_id,account_type,operational_role,normal_balance,currency,negative_policy,posted_balance_minor)
                    values (:id,:tenant,:ledger,'LIABILITY','CUSTOMER_FUNDS','CREDIT','CAD','DISALLOW_NEGATIVE',:balance)
                    """, new MapSqlParameterSource("id", customer.value()).addValue("tenant", tenant.value())
                    .addValue("ledger", ledger.value()).addValue("balance", customerBalance));
            jdbc.update("""
                    insert into accounts(id,tenant_id,ledger_id,account_type,operational_role,normal_balance,currency,negative_policy,posted_balance_minor)
                    values (:id,:tenant,:ledger,'LIABILITY','MERCHANT_PAYABLE','CREDIT','CAD','ALLOW_NEGATIVE',0)
                    """, new MapSqlParameterSource("id", merchant.value()).addValue("tenant", tenant.value()).addValue("ledger", ledger.value()));
        });
        return new Fixture(tenant, ledger, customer, merchant);
    }

    private long accountBalance(TenantId tenant, AccountId account) {
        TransactionTemplate tx = new TransactionTemplate(txManager);
        return tx.execute(status -> {
            jdbc.getJdbcTemplate().queryForObject("select set_config('app.tenant_id', ?, true)", String.class, tenant.toString());
            return jdbc.queryForObject("select posted_balance_minor from accounts where tenant_id=:tenant and id=:id",
                    new MapSqlParameterSource("tenant", tenant.value()).addValue("id", account.value()), Long.class);
        });
    }

    private long journalCount(TenantId tenant, String reference) {
        return tenantQuery(tenant, "select count(*) from journal_transactions where tenant_id=:tenant and reference=:reference",
                new MapSqlParameterSource("tenant", tenant.value()).addValue("reference", reference));
    }

    private long journalCountPrefix(TenantId tenant, String prefix) {
        return tenantQuery(tenant, "select count(*) from journal_transactions where tenant_id=:tenant and reference like :prefix",
                new MapSqlParameterSource("tenant", tenant.value()).addValue("prefix", prefix + "%"));
    }

    private long tenantQuery(TenantId tenant, String sql, MapSqlParameterSource params) {
        TransactionTemplate tx = new TransactionTemplate(txManager);
        return tx.execute(status -> {
            jdbc.getJdbcTemplate().queryForObject("select set_config('app.tenant_id', ?, true)", String.class, tenant.toString());
            return jdbc.queryForObject(sql, params, Long.class);
        });
    }

    private record Fixture(TenantId tenant, LedgerId ledger, AccountId customer, AccountId merchant) {}
}
