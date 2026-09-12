package dev.aegisledger.app.security;

import dev.aegisledger.domain.TenantId;
import jakarta.servlet.http.HttpServletRequest;

public interface TenantResolver {
    TenantId resolve(HttpServletRequest request);
}
