package dev.aegisledger.domain;

import java.util.Objects;

public record AccountSnapshot(
        AccountId id,
        TenantId tenantId,
        LedgerId ledgerId,
        CurrencyCode currency,
        NormalBalance normalBalance,
        NegativeBalancePolicy negativeBalancePolicy,
        long creditLimitMinor,
        long postedBalanceMinor,
        long version,
        AccountStatus status) {

    public AccountSnapshot {
        Objects.requireNonNull(id); Objects.requireNonNull(tenantId); Objects.requireNonNull(ledgerId);
        Objects.requireNonNull(currency); Objects.requireNonNull(normalBalance);
        Objects.requireNonNull(negativeBalancePolicy); Objects.requireNonNull(status);
        if (creditLimitMinor < 0) throw new IllegalArgumentException("creditLimitMinor must be >= 0");
        if (negativeBalancePolicy != NegativeBalancePolicy.LIMITED_NEGATIVE && creditLimitMinor != 0) {
            throw new IllegalArgumentException("credit limit only applies to LIMITED_NEGATIVE accounts");
        }
    }
}
