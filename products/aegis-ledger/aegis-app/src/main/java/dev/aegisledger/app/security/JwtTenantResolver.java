package dev.aegisledger.app.security;

import dev.aegisledger.domain.TenantId;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.context.annotation.Profile;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Component;

@Component
@Profile("!local")
public final class JwtTenantResolver implements TenantResolver {
    @Override
    public TenantId resolve(HttpServletRequest request) {
        Authentication auth = SecurityContextHolder.getContext().getAuthentication();
        if (auth == null || !(auth.getPrincipal() instanceof Jwt jwt)) {
            throw new IllegalArgumentException("Authenticated JWT tenant context is required");
        }
        String tenantId = jwt.getClaimAsString("tenant_id");
        if (tenantId == null || tenantId.isBlank()) throw new IllegalArgumentException("JWT tenant_id claim is required");
        return TenantId.of(tenantId);
    }
}
