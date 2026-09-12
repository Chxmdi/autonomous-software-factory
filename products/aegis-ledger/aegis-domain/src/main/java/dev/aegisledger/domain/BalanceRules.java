package dev.aegisledger.domain;

public final class BalanceRules {
    private BalanceRules() {}

    public static long signedEffect(NormalBalance normalBalance, JournalDirection direction, long amountMinor) {
        if (amountMinor <= 0) throw new IllegalArgumentException("amountMinor must be > 0");
        return normalBalance.name().equals(direction.name()) ? amountMinor : Math.negateExact(amountMinor);
    }

    public static long validateAndApply(AccountSnapshot account, long signedEffect) {
        if (account.status() != AccountStatus.ACTIVE) throw new AccountUnavailableException(account.id(), account.status());
        long result = Math.addExact(account.postedBalanceMinor(), signedEffect);
        long floor = switch (account.negativeBalancePolicy()) {
            case ALLOW_NEGATIVE -> Long.MIN_VALUE;
            case DISALLOW_NEGATIVE -> 0L;
            case LIMITED_NEGATIVE -> Math.negateExact(account.creditLimitMinor());
        };
        if (result < floor) throw new InsufficientFundsException(account.id(), result, floor);
        return result;
    }
}
