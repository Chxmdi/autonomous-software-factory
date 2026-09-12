package dev.aegisledger.app.security;

import dev.aegisledger.domain.TenantId;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Profile;
import org.springframework.stereotype.Component;

@Component
@Profile("local")
public final class LocalHeaderTenantResolver implements TenantResolver {
    @Override
    public TenantId resolve(HttpServletRequest request) {
        String value = request.getHeader("X-Tenant-Id");
        if (value == null || value.isBlank()) throw new IllegalArgumentException("X-Tenant-Id is required in local profile");
        return TenantId.of(value);
    }
}
