package dev.aegisledger.domain;

import java.util.Objects;

public record JournalLineDraft(AccountId accountId, JournalDirection direction, long amountMinor) {
    public JournalLineDraft {
        Objects.requireNonNull(accountId); Objects.requireNonNull(direction);
        if (amountMinor <= 0) throw new IllegalArgumentException("amountMinor must be > 0");
    }
}
