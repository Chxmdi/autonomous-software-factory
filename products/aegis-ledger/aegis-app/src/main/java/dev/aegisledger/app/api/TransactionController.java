package dev.aegisledger.app.api;

import dev.aegisledger.application.GetTransactionUseCase;
import dev.aegisledger.application.PostTransactionCommand;
import dev.aegisledger.application.PostTransactionResult;
import dev.aegisledger.application.PostTransactionUseCase;
import dev.aegisledger.app.security.TenantResolver;
import dev.aegisledger.domain.AccountId;
import dev.aegisledger.domain.CurrencyCode;
import dev.aegisledger.domain.JournalDirection;
import dev.aegisledger.domain.JournalLineDraft;
import dev.aegisledger.domain.LedgerId;
import dev.aegisledger.domain.TenantId;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.net.URI;
import java.util.UUID;

@RestController
@RequestMapping("/v1/transactions")
public final class TransactionController {
    private final PostTransactionUseCase postUseCase;
    private final GetTransactionUseCase getUseCase;
    private final TenantResolver tenantResolver;

    public TransactionController(PostTransactionUseCase postUseCase, GetTransactionUseCase getUseCase, TenantResolver tenantResolver) {
        this.postUseCase = postUseCase;
        this.getUseCase = getUseCase;
        this.tenantResolver = tenantResolver;
    }

    @PostMapping
    public ResponseEntity<TransactionResponse> post(
            @RequestHeader("Idempotency-Key") String idempotencyKey,
            @Valid @RequestBody TransactionRequest request,
            HttpServletRequest servletRequest) {
        TenantId tenantId = tenantResolver.resolve(servletRequest);
        String correlationId = correlationId(servletRequest);
        var lines = request.entries().stream()
                .map(entry -> new JournalLineDraft(
                        new AccountId(entry.accountId()),
                        JournalDirection.valueOf(entry.direction().toUpperCase()),
                        entry.amountMinor()))
                .toList();
        var command = new PostTransactionCommand(
                tenantId,
                new LedgerId(request.ledgerId()),
                CurrencyCode.of(request.currency()),
                idempotencyKey,
                RequestHasher.sha256(request),
                request.reference(),
                correlationId,
                request.effectiveAt(),
                lines);
        PostTransactionResult result = postUseCase.execute(command);
        var response = TransactionResponse.from(result);
        if (result.replayed()) return ResponseEntity.ok(response);
        return ResponseEntity.created(URI.create("/v1/transactions/" + result.transactionId())).body(response);
    }

    @GetMapping("/{transactionId}")
    public ResponseEntity<TransactionResponse> get(@PathVariable UUID transactionId, HttpServletRequest request) {
        TenantId tenantId = tenantResolver.resolve(request);
        return ResponseEntity.ok(TransactionResponse.from(getUseCase.execute(tenantId, transactionId)));
    }

    private static String correlationId(HttpServletRequest request) {
        Object value = request.getAttribute(CorrelationIdFilter.ATTRIBUTE);
        return value == null ? UUID.randomUUID().toString() : value.toString();
    }
}
