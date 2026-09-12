package dev.aegisledger.app.api;

public record ErrorResponse(ErrorBody error) {
    public record ErrorBody(String code, String message, String correlationId, boolean retryable) {}
    public static ErrorResponse of(String code, String message, String correlationId, boolean retryable) {
        return new ErrorResponse(new ErrorBody(code, message, correlationId, retryable));
    }
}
