package dev.aegisledger.domain;
public final class UnbalancedTransactionException extends RuntimeException {
    public UnbalancedTransactionException(String message) { super(message); }
}
