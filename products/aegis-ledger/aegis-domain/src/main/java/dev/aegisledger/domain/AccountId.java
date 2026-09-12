package dev.aegisledger.domain;

import java.util.Objects;
import java.util.UUID;

public record AccountId(UUID value) implements Comparable<AccountId> {
    public AccountId { Objects.requireNonNull(value, "value"); }
    public static AccountId of(String value) { return new AccountId(UUID.fromString(value)); }
    @Override public String toString() { return value.toString(); }
    @Override public int compareTo(AccountId other) { return value.compareTo(other.value); }
}
