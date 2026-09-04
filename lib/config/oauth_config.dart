class OAuthConfig {
  // GitHub OAuth App Client ID
  // Get this from: https://github.com/settings/developers → OAuth Apps
  static const String clientId = 'Ov23li...'; // REPLACE WITH YOUR CLIENT ID

  // Backend proxy URL for token exchange
  // Deploy the backend/ folder and update this URL
  static const String tokenExchangeUrl = 'https://your-proxy-url.onrender.com/exchange-code';

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
