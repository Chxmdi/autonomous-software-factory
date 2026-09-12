package dev.aegisledger.app.messaging;

import tools.jackson.databind.ObjectMapper;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Component;

@Component
@ConditionalOnProperty(prefix = "aegis.projections", name = "kafka-enabled", havingValue = "true")
public class LedgerProjectionConsumer {
    private final ObjectMapper objectMapper;
    private final AccountActivityProjectionRepository projectionRepository;

    public LedgerProjectionConsumer(
            ObjectMapper objectMapper,
            AccountActivityProjectionRepository projectionRepository) {
        this.objectMapper = objectMapper;
        this.projectionRepository = projectionRepository;
    }

    @KafkaListener(
            topics = "${aegis.projections.topic:aegis.ledger.posted}",
            groupId = "${aegis.projections.group-id:aegis-account-activity-v1}")
    public void onMessage(String payload) {
        try {
            LedgerTransactionPostedEvent event = objectMapper.readValue(payload, LedgerTransactionPostedEvent.class);
            projectionRepository.apply(event);
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid ledger.transaction.posted event payload", e);
        }
    }
}
