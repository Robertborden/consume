-- =============================================
-- ROW LEVEL SECURITY POLICIES
-- =============================================
-- Run this after 001_initial_schema.sql
-- =============================================

-- Enable RLS on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.folders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_statistics ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tags ENABLE ROW LEVEL SECURITY;

-- =============================================
-- USERS POLICIES
-- =============================================

-- Users can read their own profile
CREATE POLICY "Users can read own profile"
    ON public.users FOR SELECT
    USING (auth.uid() = id);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Users can insert their own profile (on signup)
CREATE POLICY "Users can insert own profile"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- =============================================
-- FOLDERS POLICIES
-- =============================================

-- Users can read their own folders
CREATE POLICY "Users can read own folders"
    ON public.folders FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own folders
CREATE POLICY "Users can insert own folders"
    ON public.folders FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own folders
CREATE POLICY "Users can update own folders"
    ON public.folders FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own folders
CREATE POLICY "Users can delete own folders"
    ON public.folders FOR DELETE
    USING (auth.uid() = user_id);

-- =============================================
-- SAVED ITEMS POLICIES
-- =============================================

-- Users can read their own items
CREATE POLICY "Users can read own items"
    ON public.saved_items FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own items
CREATE POLICY "Users can insert own items"
    ON public.saved_items FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own items
CREATE POLICY "Users can update own items"
    ON public.saved_items FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own items
CREATE POLICY "Users can delete own items"
    ON public.saved_items FOR DELETE
    USING (auth.uid() = user_id);

-- =============================================
-- DAILY STATISTICS POLICIES
-- =============================================

-- Users can read their own statistics
CREATE POLICY "Users can read own statistics"
    ON public.daily_statistics FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own statistics
CREATE POLICY "Users can insert own statistics"
    ON public.daily_statistics FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own statistics
CREATE POLICY "Users can update own statistics"
    ON public.daily_statistics FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- =============================================
-- TAGS POLICIES
-- =============================================

-- Users can read their own tags
CREATE POLICY "Users can read own tags"
    ON public.tags FOR SELECT
    USING (auth.uid() = user_id);

-- Users can insert their own tags
CREATE POLICY "Users can insert own tags"
    ON public.tags FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- Users can update their own tags
CREATE POLICY "Users can update own tags"
    ON public.tags FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- Users can delete their own tags
CREATE POLICY "Users can delete own tags"
    ON public.tags FOR DELETE
    USING (auth.uid() = user_id);
