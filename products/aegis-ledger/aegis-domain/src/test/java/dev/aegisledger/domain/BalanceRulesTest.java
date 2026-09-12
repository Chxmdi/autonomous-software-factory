package dev.aegisledger.domain;

import org.junit.jupiter.api.Test;

import java.util.UUID;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class BalanceRulesTest {
    private final TenantId tenant = new TenantId(UUID.randomUUID());
    private final LedgerId ledger = new LedgerId(UUID.randomUUID());
    private final AccountId account = new AccountId(UUID.randomUUID());
    private final CurrencyCode cad = CurrencyCode.of("CAD");

    @Test
    void debitReducesCreditNormalLiability() {
        var snapshot = new AccountSnapshot(account, tenant, ledger, cad, NormalBalance.CREDIT,
                NegativeBalancePolicy.DISALLOW_NEGATIVE, 0, 1000, 0, AccountStatus.ACTIVE);
        long effect = BalanceRules.signedEffect(NormalBalance.CREDIT, JournalDirection.DEBIT, 250);
        assertEquals(750, BalanceRules.validateAndApply(snapshot, effect));
    }

    @Test
    void protectedAccountRejectsOverdraft() {
        var snapshot = new AccountSnapshot(account, tenant, ledger, cad, NormalBalance.CREDIT,
                NegativeBalancePolicy.DISALLOW_NEGATIVE, 0, 100, 0, AccountStatus.ACTIVE);
        long effect = BalanceRules.signedEffect(NormalBalance.CREDIT, JournalDirection.DEBIT, 101);
        assertThrows(InsufficientFundsException.class, () -> BalanceRules.validateAndApply(snapshot, effect));
    }
}
