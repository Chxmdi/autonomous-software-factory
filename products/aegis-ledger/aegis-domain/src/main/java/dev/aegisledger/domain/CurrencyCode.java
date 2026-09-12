package dev.aegisledger.domain;

import java.util.Locale;
import java.util.Objects;
import java.util.regex.Pattern;

public record CurrencyCode(String value) {
    private static final Pattern CODE = Pattern.compile("[A-Z]{3}");
    public CurrencyCode {
        Objects.requireNonNull(value, "value");
        value = value.toUpperCase(Locale.ROOT);
        if (!CODE.matcher(value).matches()) throw new IllegalArgumentException("currency must be a 3-letter code");
    }
    public static CurrencyCode of(String value) { return new CurrencyCode(value); }
    @Override public String toString() { return value; }
}
