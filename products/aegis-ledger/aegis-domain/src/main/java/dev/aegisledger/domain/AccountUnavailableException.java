package dev.aegisledger.domain;
public final class AccountUnavailableException extends RuntimeException {
    public AccountUnavailableException(AccountId accountId, AccountStatus status) {
        super("Account %s is not available for posting: %s".formatted(accountId, status));
    }
}
