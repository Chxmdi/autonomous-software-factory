package dev.aegisledger.application;

import dev.aegisledger.domain.CurrencyCode;
import dev.aegisledger.domain.JournalLineDraft;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record PostTransactionResult(
        UUID transactionId,
        String status,
        String reference,
        CurrencyCode currency,
        Instant effectiveAt,
        Instant postedAt,
        List<JournalLineDraft> lines,
        boolean replayed) {
    public PostTransactionResult {
        lines = List.copyOf(lines);
    }
    public PostTransactionResult asReplay() {
        return new PostTransactionResult(transactionId, status, reference, currency, effectiveAt, postedAt, lines, true);
    }
}
