package dev.aegisledger.domain;
public final class InsufficientFundsException extends RuntimeException {
    public InsufficientFundsException(AccountId accountId, long resultingBalance, long floor) {
        super("Account %s would reach %d below allowed floor %d".formatted(accountId, resultingBalance, floor));
    }
}
