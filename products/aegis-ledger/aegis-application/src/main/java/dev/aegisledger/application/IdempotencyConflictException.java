package dev.aegisledger.application;
public final class IdempotencyConflictException extends RuntimeException {
    public IdempotencyConflictException() { super("Idempotency key was already used with a different payload"); }
}
