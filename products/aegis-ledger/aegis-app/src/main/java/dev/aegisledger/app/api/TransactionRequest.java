package dev.aegisledger.app.api;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

public record TransactionRequest(
        @NotNull UUID ledgerId,
        @NotBlank @Size(min = 3, max = 3) String currency,
        @NotBlank @Size(max = 200) String reference,
        @NotNull Instant effectiveAt,
        @NotEmpty @Size(min = 2, max = 100) List<@Valid Entry> entries) {

    public record Entry(
            @NotNull UUID accountId,
            @NotBlank String direction,
            @Positive long amountMinor) {}
}
