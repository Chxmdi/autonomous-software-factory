import dev.aegisledger.domain.*;

import java.util.List;
import java.util.UUID;

public final class DomainSmokeMain {
    public static void main(String[] args) {
        var tenant = new TenantId(UUID.randomUUID());
        var ledger = new LedgerId(UUID.randomUUID());
        var customer = new AccountId(UUID.randomUUID());
        var merchant = new AccountId(UUID.randomUUID());
        var cad = CurrencyCode.of("cad");

        new JournalTransactionDraft(cad, List.of(
                new JournalLineDraft(customer, JournalDirection.DEBIT, 100),
                new JournalLineDraft(merchant, JournalDirection.CREDIT, 100)));

        var customerSnapshot = new AccountSnapshot(customer, tenant, ledger, cad, NormalBalance.CREDIT,
                NegativeBalancePolicy.DISALLOW_NEGATIVE, 0, 100, 0, AccountStatus.ACTIVE);
        long effect = BalanceRules.signedEffect(customerSnapshot.normalBalance(), JournalDirection.DEBIT, 100);
        long finalBalance = BalanceRules.validateAndApply(customerSnapshot, effect);
        assert finalBalance == 0 : "expected exact spend to reach zero";

        boolean rejected = false;
        try {
            long tooMuch = BalanceRules.signedEffect(customerSnapshot.normalBalance(), JournalDirection.DEBIT, 101);
            BalanceRules.validateAndApply(customerSnapshot, tooMuch);
        } catch (InsufficientFundsException expected) {
            rejected = true;
        }
        assert rejected : "protected account must reject overdraft";

        boolean unbalanced = false;
        try {
            new JournalTransactionDraft(cad, List.of(
                    new JournalLineDraft(customer, JournalDirection.DEBIT, 100),
                    new JournalLineDraft(merchant, JournalDirection.CREDIT, 99)));
        } catch (UnbalancedTransactionException expected) {
            unbalanced = true;
        }
        assert unbalanced : "unbalanced journal must be rejected";

        System.out.println("AegisLedger domain smoke: PASS");
    }
}
