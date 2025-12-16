-- =============================================
-- CONSUME App - Initial Database Schema
-- =============================================
-- Run this in your Supabase SQL Editor
-- =============================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_trgm"; -- For text search

-- =============================================
-- USERS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT,
    display_name TEXT,
    avatar_url TEXT,
    is_premium BOOLEAN DEFAULT FALSE,
    subscription_tier TEXT DEFAULT 'free' CHECK (subscription_tier IN ('free', 'pro', 'premium')),
    subscription_expires_at TIMESTAMPTZ,
    default_expiry_days INTEGER DEFAULT 7 CHECK (default_expiry_days >= 1 AND default_expiry_days <= 30),
    daily_review_goal INTEGER DEFAULT 5 CHECK (daily_review_goal >= 1 AND daily_review_goal <= 50),
    notifications_enabled BOOLEAN DEFAULT TRUE,
    reminder_time TEXT DEFAULT '09:00', -- HH:MM format
    theme_mode TEXT DEFAULT 'system' CHECK (theme_mode IN ('light', 'dark', 'system')),
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    total_items_saved INTEGER DEFAULT 0,
    total_items_consumed INTEGER DEFAULT 0,
    last_review_date DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- FOLDERS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.folders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    color_hex TEXT DEFAULT '#6366F1',
    icon_name TEXT DEFAULT 'folder',
    sort_order INTEGER DEFAULT 0,
    parent_id UUID REFERENCES public.folders(id) ON DELETE SET NULL,
    is_default BOOLEAN DEFAULT FALSE,
    item_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, name)
);

-- =============================================
-- SAVED ITEMS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.saved_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    url TEXT NOT NULL,
    title TEXT,
    description TEXT,
    thumbnail_url TEXT,
    favicon_url TEXT,
    status TEXT DEFAULT 'unreviewed' CHECK (status IN ('unreviewed', 'kept', 'consumed', 'expired', 'archived')),
    source TEXT DEFAULT 'other' CHECK (source IN ('twitter', 'instagram', 'youtube', 'tiktok', 'reddit', 'linkedin', 'facebook', 'pinterest', 'medium', 'spotify', 'web', 'other')),
    source_app_name TEXT,
    folder_id UUID REFERENCES public.folders(id) ON DELETE SET NULL,
    expires_at TIMESTAMPTZ,
    consumed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    tags TEXT[] DEFAULT '{}',
    notes TEXT,
    is_pinned BOOLEAN DEFAULT FALSE,
    reminder_at TIMESTAMPTZ,
    share_count INTEGER DEFAULT 0,
    view_count INTEGER DEFAULT 0
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_saved_items_user_id ON public.saved_items(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_items_status ON public.saved_items(status);
CREATE INDEX IF NOT EXISTS idx_saved_items_folder_id ON public.saved_items(folder_id);
CREATE INDEX IF NOT EXISTS idx_saved_items_expires_at ON public.saved_items(expires_at);
CREATE INDEX IF NOT EXISTS idx_saved_items_created_at ON public.saved_items(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_saved_items_source ON public.saved_items(source);

-- =============================================
-- DAILY STATISTICS TABLE
-- =============================================
CREATE TABLE IF NOT EXISTS public.daily_statistics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    items_saved INTEGER DEFAULT 0,
    items_consumed INTEGER DEFAULT 0,
    items_expired INTEGER DEFAULT 0,
    items_reviewed INTEGER DEFAULT 0,
    review_time_seconds INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date)
);

CREATE INDEX IF NOT EXISTS idx_daily_statistics_user_date ON public.daily_statistics(user_id, date DESC);

-- =============================================
-- TAGS TABLE (for tag suggestions)
-- =============================================
CREATE TABLE IF NOT EXISTS public.tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    usage_count INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, name)
);

CREATE INDEX IF NOT EXISTS idx_tags_user_id ON public.tags(user_id);
