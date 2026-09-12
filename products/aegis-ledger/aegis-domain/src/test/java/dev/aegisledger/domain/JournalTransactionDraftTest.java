package dev.aegisledger.domain;

import org.junit.jupiter.api.Test;

import java.util.List;
import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertDoesNotThrow;
import static org.junit.jupiter.api.Assertions.assertThrows;

class JournalTransactionDraftTest {
    @Test
    void balancedTransactionIsAccepted() {
        assertDoesNotThrow(() -> new JournalTransactionDraft(CurrencyCode.of("CAD"), List.of(
                new JournalLineDraft(new AccountId(UUID.randomUUID()), JournalDirection.DEBIT, 500),
                new JournalLineDraft(new AccountId(UUID.randomUUID()), JournalDirection.CREDIT, 500))));
    }

    @Test
    void unbalancedTransactionIsRejected() {
        assertThrows(UnbalancedTransactionException.class, () -> new JournalTransactionDraft(CurrencyCode.of("CAD"), List.of(
                new JournalLineDraft(new AccountId(UUID.randomUUID()), JournalDirection.DEBIT, 500),
                new JournalLineDraft(new AccountId(UUID.randomUUID()), JournalDirection.CREDIT, 499))));
    }
}
