package dev.aegisledger.app.api;

import dev.aegisledger.application.PostTransactionResult;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record TransactionResponse(
        UUID transactionId,
        String status,
        String reference,
        String currency,
        Instant effectiveAt,
        Instant postedAt,
        List<Entry> entries) {

    public record Entry(UUID accountId, String direction, long amountMinor) {}

    public static TransactionResponse from(PostTransactionResult result) {
        return new TransactionResponse(
                result.transactionId(), result.status(), result.reference(), result.currency().value(),
                result.effectiveAt(), result.postedAt(),
                result.lines().stream()
                        .map(line -> new Entry(line.accountId().value(), line.direction().name(), line.amountMinor()))
                        .toList());
    }
}
