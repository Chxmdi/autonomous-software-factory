package dev.aegisledger.application;

public interface LedgerPostingPort {
    PostTransactionResult post(PostTransactionCommand command);
}
