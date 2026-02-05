/// Network-related constants for core_base_bloc.
library;

// ============================================================================
// Default Storage Keys
// ============================================================================

/// Default storage key for access token.
/// Projects can override this via AuthConfig.tokenStorageKey
const String kDefaultTokenStorageKey = "TOKEN_STRING";

/// Default storage key for refresh token.
/// Projects can override this via AuthConfig.refreshTokenStorageKey
const String kDefaultRefreshTokenStorageKey = "REFRESH_TOKEN_STRING";

// ============================================================================
// HTTP Status Codes
// ============================================================================

/// HTTP 401 Unauthorized - Authentication required or failed
const int kAuthErrorUnauthorized = 401;

/// HTTP 403 Forbidden - Authenticated but not authorized
const int kAuthErrorForbidden = 403;

/// HTTP 200 OK - Success status code
const int kHttpStatusOk = 200;
