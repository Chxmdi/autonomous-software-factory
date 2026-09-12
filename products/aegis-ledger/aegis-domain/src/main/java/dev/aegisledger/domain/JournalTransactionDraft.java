package dev.aegisledger.domain;

import java.util.List;
import java.util.Objects;

public record JournalTransactionDraft(CurrencyCode currency, List<JournalLineDraft> lines) {
    public JournalTransactionDraft {
        Objects.requireNonNull(currency); Objects.requireNonNull(lines);
        lines = List.copyOf(lines);
        if (lines.size() < 2) throw new UnbalancedTransactionException("A journal transaction requires at least two lines");
        long debits = 0;
        long credits = 0;
        for (JournalLineDraft line : lines) {
            if (line.direction() == JournalDirection.DEBIT) debits = Math.addExact(debits, line.amountMinor());
            else credits = Math.addExact(credits, line.amountMinor());
        }
        if (debits != credits) {
            throw new UnbalancedTransactionException("Debits %d do not equal credits %d".formatted(debits, credits));
        }
    }
}
