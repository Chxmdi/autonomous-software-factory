package dev.aegisledger.app.messaging;

import dev.aegisledger.application.LedgerPostingPort;
import dev.aegisledger.application.PostTransactionCommand;
import dev.aegisledger.domain.AccountId;
import dev.aegisledger.domain.CurrencyCode;
import dev.aegisledger.domain.JournalDirection;
import dev.aegisledger.domain.JournalLineDraft;
import dev.aegisledger.domain.LedgerId;
import dev.aegisledger.domain.TenantId;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.DynamicPropertyRegistry;
import org.springframework.test.context.DynamicPropertySource;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.support.TransactionTemplate;
import org.testcontainers.junit.jupiter.Container;
import org.testcontainers.junit.jupiter.Testcontainers;
import org.testcontainers.postgresql.PostgreSQLContainer;

import java.time.Duration;
import java.time.Instant;
import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;
import java.util.function.BooleanSupplier;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertTrue;

@SpringBootTest(properties = "aegis.projections.kafka-enabled=true")
@ActiveProfiles("local")
@Testcontainers
@EmbeddedKafka(
        partitions = 1,
        topics = KafkaProjectionIntegrationTest.TOPIC,
        bootstrapServersProperty = "spring.kafka.bootstrap-servers")
class KafkaProjectionIntegrationTest {
    static final String TOPIC = "aegis.ledger.posted";

    @Container
    static final PostgreSQLContainer POSTGRES = new PostgreSQLContainer("postgres:18.6-alpine")
            .withDatabaseName("aegis")
            .withUsername("postgres")
            .withPassword("admin-test")
            .withInitScript("db/test-init.sql");

    @DynamicPropertySource
    static void properties(DynamicPropertyRegistry registry) {
        registry.add("spring.datasource.url", POSTGRES::getJdbcUrl);
        registry.add("spring.datasource.username", () -> "aegis");
        registry.add("spring.datasource.password", () -> "aegis-test");
    }

    @Autowired LedgerPostingPort postingPort;
    @Autowired KafkaTemplate<String, String> kafkaTemplate;
    @Autowired AccountActivityProjectionRepository projectionRepository;
    @Autowired NamedParameterJdbcTemplate jdbc;
    @Autowired PlatformTransactionManager txManager;

    @Test
    void outboxEventIsSelfContainedDuplicateSafeAndRebuildable() throws Exception {
        Fixture fixture = seed(1_000);
        var result = postingPort.post(command(fixture, "wp06-event", "d".repeat(64), 100, "wp06-purchase"));
        String payload = outboxPayload(fixture.tenant(), result.transactionId());

        kafkaTemplate.send(TOPIC, result.transactionId().toString(), payload).get(10, TimeUnit.SECONDS);
        await("initial projection", Duration.ofSeconds(10),
                () -> projectionCount(fixture.tenant(), result.transactionId()) == 2);

        assertEquals(900L, projectedBalance(fixture.tenant(), result.transactionId(), fixture.customer()));
        assertEquals(100L, projectedBalance(fixture.tenant(), result.transactionId(), fixture.merchant()));
        assertEquals(1L, processedEventCount(fixture.tenant()));

        for (int i = 0; i < 5; i++) {
            kafkaTemplate.send(TOPIC, result.transactionId().toString(), payload).get(10, TimeUnit.SECONDS);
        }
        await("duplicate delivery remains idempotent", Duration.ofSeconds(10),
                () -> processedEventCount(fixture.tenant()) == 1);
        assertEquals(2L, projectionCount(fixture.tenant(), result.transactionId()));

        projectionRepository.resetTenant(fixture.tenant().value());
        assertEquals(0L, projectionCount(fixture.tenant(), result.transactionId()));
        assertEquals(0L, processedEventCount(fixture.tenant()));

        kafkaTemplate.send(TOPIC, result.transactionId().toString(), payload).get(10, TimeUnit.SECONDS);
        await("projection rebuild", Duration.ofSeconds(10),
                () -> projectionCount(fixture.tenant(), result.transactionId()) == 2);
        assertEquals(900L, projectedBalance(fixture.tenant(), result.transactionId(), fixture.customer()));
        assertEquals(100L, projectedBalance(fixture.tenant(), result.transactionId(), fixture.merchant()));
    }

    private Fixture seed(long customerBalance) {
        TenantId tenant = new TenantId(UUID.randomUUID());
        LedgerId ledger = new LedgerId(UUID.randomUUID());
        AccountId customer = new AccountId(UUID.randomUUID());
        AccountId merchant = new AccountId(UUID.randomUUID());
        jdbc.getJdbcTemplate().update("insert into tenants(id,name) values (?,?)", tenant.value(), "Tenant " + tenant);

        TransactionTemplate tx = new TransactionTemplate(txManager);
        tx.executeWithoutResult(status -> {
            setTenant(tenant);
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
                    """, new MapSqlParameterSource("id", merchant.value()).addValue("tenant", tenant.value())
                    .addValue("ledger", ledger.value()));
        });
        return new Fixture(tenant, ledger, customer, merchant);
    }

    private PostTransactionCommand command(Fixture f, String key, String hash, long amount, String reference) {
        return new PostTransactionCommand(
                f.tenant(), f.ledger(), CurrencyCode.of("CAD"), key, hash, reference,
                "wp06-correlation-" + UUID.randomUUID(), Instant.parse("2026-09-12T02:00:00Z"),
                List.of(
                        new JournalLineDraft(f.customer(), JournalDirection.DEBIT, amount),
                        new JournalLineDraft(f.merchant(), JournalDirection.CREDIT, amount)));
    }

    private String outboxPayload(TenantId tenant, UUID transactionId) {
        return tenantQuery(tenant, () -> jdbc.queryForObject(
                "select payload::text from outbox_events where tenant_id=:tenant and aggregate_id=:tx",
                new MapSqlParameterSource("tenant", tenant.value()).addValue("tx", transactionId),
                String.class));
    }

    private long projectionCount(TenantId tenant, UUID transactionId) {
        Long value = tenantQuery(tenant, () -> jdbc.queryForObject(
                "select count(*) from account_activity_projection where tenant_id=:tenant and transaction_id=:tx",
                new MapSqlParameterSource("tenant", tenant.value()).addValue("tx", transactionId),
                Long.class));
        return value == null ? 0L : value;
    }

    private long processedEventCount(TenantId tenant) {
        Long value = tenantQuery(tenant, () -> jdbc.queryForObject(
                "select count(*) from projection_processed_events where tenant_id=:tenant and consumer_name=:consumer",
                new MapSqlParameterSource("tenant", tenant.value())
                        .addValue("consumer", AccountActivityProjectionRepository.CONSUMER_NAME),
                Long.class));
        return value == null ? 0L : value;
    }

    private long projectedBalance(TenantId tenant, UUID transactionId, AccountId accountId) {
        Long value = tenantQuery(tenant, () -> jdbc.queryForObject(
                """
                select balance_after_minor from account_activity_projection
                where tenant_id=:tenant and transaction_id=:tx and account_id=:account
                """,
                new MapSqlParameterSource("tenant", tenant.value())
                        .addValue("tx", transactionId)
                        .addValue("account", accountId.value()),
                Long.class));
        return value == null ? 0L : value;
    }

    private <T> T tenantQuery(TenantId tenant, java.util.function.Supplier<T> query) {
        TransactionTemplate tx = new TransactionTemplate(txManager);
        return tx.execute(status -> {
            setTenant(tenant);
            return query.get();
        });
    }

    private void setTenant(TenantId tenant) {
        jdbc.getJdbcTemplate().queryForObject(
                "select set_config('app.tenant_id', ?, true)",
                String.class,
                tenant.toString());
    }

    private static void await(String description, Duration timeout, BooleanSupplier condition) throws InterruptedException {
        long deadline = System.nanoTime() + timeout.toNanos();
        while (System.nanoTime() < deadline) {
            if (condition.getAsBoolean()) return;
            Thread.sleep(50);
        }
        assertTrue(condition.getAsBoolean(), "Timed out waiting for " + description);
    }

    private record Fixture(TenantId tenant, LedgerId ledger, AccountId customer, AccountId merchant) {}
}
