package dev.aegisledger.application;

import dev.aegisledger.domain.TenantId;
import java.util.Objects;
import java.util.UUID;

public final class GetTransactionUseCase {
    private final TransactionQueryPort queryPort;
    public GetTransactionUseCase(TransactionQueryPort queryPort) { this.queryPort = Objects.requireNonNull(queryPort); }
    public PostTransactionResult execute(TenantId tenantId, UUID transactionId) { return queryPort.get(tenantId, transactionId); }
}
