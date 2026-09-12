package dev.aegisledger.application;

import dev.aegisledger.domain.TenantId;
import java.util.UUID;

public interface TransactionQueryPort {
    PostTransactionResult get(TenantId tenantId, UUID transactionId);
}
