package dev.aegisledger.application;
public final class IdempotencyInProgressException extends RuntimeException {
    public IdempotencyInProgressException() { super("Idempotent operation is still processing"); }
}
