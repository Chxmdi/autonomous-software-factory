package dev.aegisledger.app.api;

import dev.aegisledger.application.CurrencyMismatchException;
import dev.aegisledger.application.IdempotencyConflictException;
import dev.aegisledger.application.IdempotencyInProgressException;
import dev.aegisledger.application.ResourceNotFoundException;
import dev.aegisledger.domain.AccountUnavailableException;
import dev.aegisledger.domain.InsufficientFundsException;
import dev.aegisledger.domain.UnbalancedTransactionException;
import jakarta.servlet.http.HttpServletRequest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.UUID;

@RestControllerAdvice
public final class ApiExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(ApiExceptionHandler.class);

    @ExceptionHandler({MethodArgumentNotValidException.class, IllegalArgumentException.class})
    ResponseEntity<ErrorResponse> badRequest(Exception ex, HttpServletRequest request) {
        return error(HttpStatus.BAD_REQUEST, "INVALID_REQUEST", ex.getMessage(), false, request);
    }

    @ExceptionHandler(UnbalancedTransactionException.class)
    ResponseEntity<ErrorResponse> unbalanced(UnbalancedTransactionException ex, HttpServletRequest request) {
        return error(HttpStatus.UNPROCESSABLE_ENTITY, "UNBALANCED_TRANSACTION", ex.getMessage(), false, request);
    }

    @ExceptionHandler(InsufficientFundsException.class)
    ResponseEntity<ErrorResponse> insufficient(InsufficientFundsException ex, HttpServletRequest request) {
        return error(HttpStatus.UNPROCESSABLE_ENTITY, "INSUFFICIENT_FUNDS", ex.getMessage(), false, request);
    }

    @ExceptionHandler(AccountUnavailableException.class)
    ResponseEntity<ErrorResponse> accountUnavailable(AccountUnavailableException ex, HttpServletRequest request) {
        return error(HttpStatus.UNPROCESSABLE_ENTITY, "ACCOUNT_UNAVAILABLE", ex.getMessage(), false, request);
    }

    @ExceptionHandler(CurrencyMismatchException.class)
    ResponseEntity<ErrorResponse> currency(CurrencyMismatchException ex, HttpServletRequest request) {
        return error(HttpStatus.UNPROCESSABLE_ENTITY, "CURRENCY_MISMATCH", ex.getMessage(), false, request);
    }

    @ExceptionHandler(IdempotencyConflictException.class)
    ResponseEntity<ErrorResponse> idempotencyConflict(IdempotencyConflictException ex, HttpServletRequest request) {
        return error(HttpStatus.CONFLICT, "IDEMPOTENCY_KEY_REUSED_WITH_DIFFERENT_PAYLOAD", ex.getMessage(), false, request);
    }

    @ExceptionHandler(IdempotencyInProgressException.class)
    ResponseEntity<ErrorResponse> idempotencyInProgress(IdempotencyInProgressException ex, HttpServletRequest request) {
        return error(HttpStatus.CONFLICT, "IDEMPOTENCY_REQUEST_IN_PROGRESS", ex.getMessage(), true, request);
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    ResponseEntity<ErrorResponse> notFound(ResourceNotFoundException ex, HttpServletRequest request) {
        return error(HttpStatus.NOT_FOUND, "TRANSACTION_OR_ACCOUNT_NOT_FOUND", ex.getMessage(), false, request);
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<ErrorResponse> unexpected(Exception ex, HttpServletRequest request) {
        String correlationId = correlationId(request);
        log.error("Unhandled request failure correlationId={}", correlationId, ex);
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ErrorResponse.of("INTERNAL_ERROR", "Unexpected server error", correlationId, false));
    }

    private static ResponseEntity<ErrorResponse> error(HttpStatus status, String code, String message, boolean retryable, HttpServletRequest request) {
        return ResponseEntity.status(status).body(ErrorResponse.of(code, safe(message), correlationId(request), retryable));
    }

    private static String safe(String message) { return message == null || message.isBlank() ? "Request failed" : message; }
    private static String correlationId(HttpServletRequest request) {
        Object value = request.getAttribute(CorrelationIdFilter.ATTRIBUTE);
        return value == null ? UUID.randomUUID().toString() : value.toString();
    }
}
