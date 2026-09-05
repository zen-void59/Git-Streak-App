class OAuthConfig {
  // GitHub OAuth App Client ID
  // Get this from: https://github.com/settings/developers -> OAuth Apps
  static const String clientId = String.fromEnvironment(
    'GITHUB_CLIENT_ID',
    defaultValue: '123456789',//private key
  );

  // Backend proxy URL for token exchange
  // Deploy the backend/ folder and update this URL
  static const String tokenExchangeUrl = String.fromEnvironment(
    'TOKEN_EXCHANGE_URL',
    defaultValue: '123456789',//private key
  );

  // OAuth scopes
  // read:user - Read user profile
  // repo      - Access private repos and contributions
  static const String scopes = 'read:user repo';

  // Deep link scheme (must match AndroidManifest.xml and Info.plist)
  static const String redirectScheme = 'mossapp';
  static const String redirectHost = 'callback';

  // GitHub OAuth endpoints
  static const String authorizeUrl = 'https://github.com/login/oauth/authorize';
}
