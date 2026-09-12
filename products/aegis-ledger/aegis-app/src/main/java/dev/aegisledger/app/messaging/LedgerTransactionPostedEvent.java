package dev.aegisledger.app.messaging;

import java.time.Instant;
import java.util.List;
import java.util.Objects;
import java.util.UUID;

public record LedgerTransactionPostedEvent(
        UUID eventId,
        String eventType,
        int eventVersion,
        UUID tenantId,
        UUID transactionId,
        UUID ledgerId,
        String currency,
        String reference,
        String correlationId,
        Instant occurredAt,
        List<Line> lines) {

    public static final String TYPE = "ledger.transaction.posted";
    public static final int VERSION = 1;

    public LedgerTransactionPostedEvent {
        Objects.requireNonNull(eventId, "eventId");
        Objects.requireNonNull(eventType, "eventType");
        Objects.requireNonNull(tenantId, "tenantId");
        Objects.requireNonNull(transactionId, "transactionId");
        Objects.requireNonNull(ledgerId, "ledgerId");
        Objects.requireNonNull(currency, "currency");
        Objects.requireNonNull(reference, "reference");
        Objects.requireNonNull(correlationId, "correlationId");
        Objects.requireNonNull(occurredAt, "occurredAt");
        lines = List.copyOf(lines);
        if (!TYPE.equals(eventType)) throw new IllegalArgumentException("Unsupported event type: " + eventType);
        if (eventVersion != VERSION) throw new IllegalArgumentException("Unsupported event version: " + eventVersion);
        if (lines.isEmpty()) throw new IllegalArgumentException("Posted ledger event requires at least one line");
    }

    public record Line(
            UUID accountId,
            int lineSequence,
            String direction,
            long amountMinor,
            long balanceAfterMinor) {
        public Line {
            Objects.requireNonNull(accountId, "accountId");
            Objects.requireNonNull(direction, "direction");
            if (lineSequence <= 0) throw new IllegalArgumentException("lineSequence must be positive");
            if (!direction.equals("DEBIT") && !direction.equals("CREDIT")) {
                throw new IllegalArgumentException("direction must be DEBIT or CREDIT");
            }
            if (amountMinor <= 0) throw new IllegalArgumentException("amountMinor must be positive");
        }
    }
}
