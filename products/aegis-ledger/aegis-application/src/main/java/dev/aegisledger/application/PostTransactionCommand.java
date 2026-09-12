package dev.aegisledger.application;

import dev.aegisledger.domain.CurrencyCode;
import dev.aegisledger.domain.JournalLineDraft;
import dev.aegisledger.domain.LedgerId;
import dev.aegisledger.domain.TenantId;

import java.time.Instant;
import java.util.List;
import java.util.Objects;

public record PostTransactionCommand(
        TenantId tenantId,
        LedgerId ledgerId,
        CurrencyCode currency,
        String idempotencyKey,
        String requestHash,
        String reference,
        String correlationId,
        Instant effectiveAt,
        List<JournalLineDraft> lines) {
    public PostTransactionCommand {
        Objects.requireNonNull(tenantId); Objects.requireNonNull(ledgerId); Objects.requireNonNull(currency);
        Objects.requireNonNull(idempotencyKey); Objects.requireNonNull(requestHash); Objects.requireNonNull(reference);
        Objects.requireNonNull(correlationId); Objects.requireNonNull(effectiveAt); Objects.requireNonNull(lines);
        lines = List.copyOf(lines);
        if (idempotencyKey.isBlank() || idempotencyKey.length() > 128) throw new IllegalArgumentException("invalid idempotency key");
        if (!requestHash.matches("[0-9a-f]{64}")) throw new IllegalArgumentException("requestHash must be lowercase SHA-256 hex");
        if (reference.isBlank() || reference.length() > 200) throw new IllegalArgumentException("invalid reference");
    }
}
