package dev.aegisledger.app.config;

import dev.aegisledger.application.GetTransactionUseCase;
import dev.aegisledger.application.LedgerPostingPort;
import dev.aegisledger.application.PostTransactionUseCase;
import dev.aegisledger.application.TransactionQueryPort;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class ApplicationConfig {
    @Bean
    PostTransactionUseCase postTransactionUseCase(LedgerPostingPort port) {
        return new PostTransactionUseCase(port);
    }

    @Bean
    GetTransactionUseCase getTransactionUseCase(TransactionQueryPort port) {
        return new GetTransactionUseCase(port);
    }
}
