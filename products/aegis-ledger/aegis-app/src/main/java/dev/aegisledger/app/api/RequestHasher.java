package dev.aegisledger.app.api;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

public final class RequestHasher {
    private RequestHasher() {}

    public static String sha256(TransactionRequest request) {
        StringBuilder canonical = new StringBuilder();
        append(canonical, request.ledgerId().toString());
        append(canonical, request.currency());
        append(canonical, request.reference());
        append(canonical, request.effectiveAt().toString());
        for (TransactionRequest.Entry entry : request.entries()) {
            append(canonical, entry.accountId().toString());
            append(canonical, entry.direction());
            append(canonical, Long.toString(entry.amountMinor()));
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            return HexFormat.of().formatHex(digest.digest(canonical.toString().getBytes(StandardCharsets.UTF_8)));
        } catch (NoSuchAlgorithmException impossible) {
            throw new IllegalStateException("SHA-256 unavailable", impossible);
        }
    }

    private static void append(StringBuilder out, String value) {
        out.append(value.length()).append(':').append(value).append('|');
    }
}
