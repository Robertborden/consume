# Supabase Setup for CONSUME App

## Quick Setup

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Create a new project or select existing one
3. Go to **SQL Editor**
4. Run the migration files in order:
   - `001_initial_schema.sql` - Creates tables
   - `002_rls_policies.sql` - Sets up Row Level Security
   - `003_functions.sql` - Creates database functions

## Configuration

After setup, get your credentials:

1. Go to **Project Settings** > **API**
2. Copy:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

3. Create `lib/core/constants/api_constants.dart`:

```dart
class ApiConstants {
  static const String supabaseUrl = 'YOUR_PROJECT_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
}
```

## Authentication Setup

### Email/Password
Enabled by default.

### Google OAuth
1. Go to **Authentication** > **Providers** > **Google**
2. Enable and add your Google OAuth credentials
3. Add redirect URL to your Google Console

### Apple Sign-In
1. Go to **Authentication** > **Providers** > **Apple**
2. Enable and configure with your Apple Developer credentials

## Deep Links (for OAuth)

Add to **Authentication** > **URL Configuration**:
- Site URL: `io.supabase.consume://`
- Redirect URLs:
  - `io.supabase.consume://login-callback/`
  - `io.supabase.consume://reset-password/`

## Scheduled Functions

To automatically expire items, create a **Cron Job** in Supabase:

1. Go to **Database** > **Extensions** > Enable `pg_cron`
2. Run:

```sql
SELECT cron.schedule(
  'mark-expired-items',
  '0 * * * *', -- Every hour
  $$SELECT public.mark_expired_items()$$
);
```

## Tables Overview

| Table | Description |
|-------|-------------|
| `users` | User profiles and settings |
| `folders` | User-created folders for organization |
| `saved_items` | Saved URLs/content |
| `daily_statistics` | Daily activity tracking |
| `tags` | Tag suggestions |

## RLS Policies

All tables have Row Level Security enabled. Users can only:
- Read their own data
- Insert their own data
- Update their own data
- Delete their own data
