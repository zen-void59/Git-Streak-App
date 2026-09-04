# Moss OAuth Proxy

This server handles the GitHub OAuth token exchange. The `client_secret` stays on this server — it's never sent to the mobile app.

## Setup

1. Register a GitHub OAuth App:
   - Go to https://github.com/settings/developers
   - Click "OAuth Apps" → "New OAuth App"
   - **Application name:** Moss
   - **Homepage URL:** https://your-domain.com (or anything)
   - **Authorization callback URL:** `mossapp://callback`

2. Copy your Client ID and Client Secret

3. Create `.env` file:
   ```bash
   cp .env.example .env
   ```

4. Edit `.env` and add your credentials:
   ```
   GITHUB_CLIENT_ID=Ov23li...
   GITHUB_CLIENT_SECRET=...
   ```

5. Install and run:
   ```bash
   npm install
   npm start
   ```

## Deployment Options

### Railway (Recommended - Free Tier)
```bash
# Install Railway CLI
npm install -g @railway/cli

# Login and deploy
railway login
railway init
railway up
```

### Render (Free Tier)
1. Push to GitHub
2. Create new Web Service on render.com
3. Select your repo
4. Set build command: `npm install`
5. Set start command: `npm start`
6. Add environment variables in dashboard

### Vercel (Serverless)
Create `api/exchange.js` for serverless deployment.

### Heroku
```bash
heroku create moss-oauth-proxy
git push heroku main
```

## API Endpoints

### POST /exchange-code
Exchanges an authorization code for an access token.

**Request:**
```json
{
  "code": "abc123..."
}
```

**Response:**
```json
{
  "access_token": "gho_...",
  "token_type": "bearer",
  "scope": "read:user,repo"
}
```

## Update Flutter App

Once deployed, update `lib/config/oauth_config.dart` with your proxy URL:

```dart
static const String tokenExchangeUrl = 'https://your-proxy-url.onrender.com/exchange-code';
```
