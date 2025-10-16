# Zena Mobile App Setup Guide

## Environment Configuration

This app uses environment variables to manage sensitive configuration like Supabase credentials.

### Setup Steps

1. **Copy the example environment file:**
   ```bash
   cp .env.example .env.local
   ```

2. **Get your Supabase credentials:**
   - Go to your Supabase project dashboard: https://app.supabase.com
   - Navigate to Settings > API
   - Copy your Project URL and anon/public key

3. **Update `.env.local` with your credentials:**
   ```env
   SUPABASE_URL=https://your-project-id.supabase.co
   SUPABASE_ANON_KEY=your-actual-anon-key-here
   BASE_URL=https://zena.live
   ```

4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

5. **Run the app:**
   ```bash
   flutter run
   ```

### Important Notes

- **Never commit `.env.local`** - This file contains sensitive credentials and is already in `.gitignore`
- The `.env.example` file is safe to commit and serves as a template
- If you get an error about missing environment variables, ensure `.env.local` exists and contains all required values
- The app will throw a clear error message if any required environment variable is missing

### Environment Variables

| Variable | Description | Required |
|----------|-------------|----------|
| `SUPABASE_URL` | Your Supabase project URL | Yes |
| `SUPABASE_ANON_KEY` | Your Supabase anonymous/public key | Yes |
| `BASE_URL` | Base API URL for the backend | No (defaults to https://zena.live) |

### Google OAuth Setup

For Google Sign-In to work properly on mobile, you need to configure the OAuth redirect URL in your Supabase dashboard. See [OAUTH_SETUP.md](OAUTH_SETUP.md) for detailed instructions.

**Quick steps:**
1. Go to Supabase Dashboard > Authentication > URL Configuration
2. Add `io.supabase.zena://login-callback/` to Redirect URLs
3. Save changes

### Troubleshooting

**Error: "Missing required environment variable"**
- Ensure `.env.local` file exists in the project root
- Verify all required variables are set in `.env.local`
- Try running `flutter clean` and `flutter pub get`

**Error: "Unable to load asset: .env.local"**
- Ensure `.env.local` is listed in `pubspec.yaml` under `assets`
- Run `flutter pub get` after adding the file
- Try a hot restart (not just hot reload)

**Error: "Redirect URL not allowed" during Google Sign-In**
- See [OAUTH_SETUP.md](OAUTH_SETUP.md) for OAuth configuration
- Ensure `io.supabase.zena://login-callback/` is added to Supabase allowed redirect URLs
