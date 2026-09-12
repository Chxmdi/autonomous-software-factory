package dev.aegisledger.application;

import dev.aegisledger.domain.JournalTransactionDraft;

import java.util.Objects;

public final class PostTransactionUseCase {
    private final LedgerPostingPort postingPort;

    public PostTransactionUseCase(LedgerPostingPort postingPort) {
        this.postingPort = Objects.requireNonNull(postingPort);
    }

    public PostTransactionResult execute(PostTransactionCommand command) {
        new JournalTransactionDraft(command.currency(), command.lines());
        return postingPort.post(command);
    }
}
