import 'package:flutter/foundation.dart';

/// Configuration class for authentication handling in NetworkService.
///
/// This class centralizes all authentication-related configuration,
/// making it easy to customize auth behavior per project without modifying core code.
///
/// Example usage:
/// ```dart
/// final authConfig = AuthConfig(
///   refreshTokenEndpoint: "/api/auth/refresh",
///   tokenResponseKey: "access_token",
///   refreshTokenResponseKey: "refresh_token",
///   buildRefreshTokenBody: () {
///     final refreshToken = storageRead<String>("MY_REFRESH_TOKEN");
///     return {"refreshToken": refreshToken};
///   },
///   onAuthenticationError: () {
///     // Navigate to login screen
///   },
/// );
/// ```
class NetworkAuthConfig {
  /// Storage key for access token. Defaults to "TOKEN_STRING".
  final String tokenStorageKey;

  /// Storage key for refresh token. Defaults to "REFRESH_TOKEN_STRING".
  final String refreshTokenStorageKey;

  /// API endpoint for refreshing tokens (e.g., "/api/auth/refresh").
  final String refreshTokenEndpoint;

  /// Key name in response JSON for access token (e.g., "access_token").
  final String tokenResponseKey;

  /// Key name in response JSON for refresh token (e.g., "refresh_token").
  final String refreshTokenResponseKey;

  /// Function to build the request body for refresh token API.
  /// This allows projects to customize the request payload.
  ///
  /// Example:
  /// ```dart
  /// buildRefreshTokenBody: () => {
  ///   "refreshToken": storageRead("MY_REFRESH_TOKEN"),
  ///   "deviceId": "device123",
  /// }
  /// ```
  final Map<String, dynamic> buildRefreshTokenBody;

  /// Callback invoked when authentication fails (e.g., refresh token expired).
  /// Projects should implement logout logic here.
  ///
  /// Example:
  /// ```dart
  /// onAuthenticationError: () {
  ///   // Clear user data
  ///   storageRemove("TOKEN");
  ///   // Navigate to login
  ///   Navigator.pushReplacementNamed(context, "/login");
  /// }
  /// ```
  final VoidCallback onAuthenticationError;

  /// Maximum number of retry attempts when receiving 401 responses.
  /// Defaults to 1 to prevent infinite loops.
  final int maxRetryCount;

  /// Creates an AuthConfig with the specified settings.
  ///
  /// All parameters except [tokenStorageKey], [refreshTokenStorageKey],
  /// and [maxRetryCount] are required.
  const NetworkAuthConfig({
    this.tokenStorageKey = "TOKEN_STRING",
    this.refreshTokenStorageKey = "REFRESH_TOKEN_STRING",
    required this.refreshTokenEndpoint,
    required this.tokenResponseKey,
    required this.refreshTokenResponseKey,
    required this.buildRefreshTokenBody,
    required this.onAuthenticationError,
    this.maxRetryCount = 1,
  });
}
