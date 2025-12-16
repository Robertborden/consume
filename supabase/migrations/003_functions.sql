-- =============================================
-- DATABASE FUNCTIONS
-- =============================================
-- Run this after 002_rls_policies.sql
-- =============================================

-- =============================================
-- Function: Create user profile on signup
-- =============================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, display_name, avatar_url)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    
    -- Create default "Inbox" folder
    INSERT INTO public.folders (user_id, name, is_default, icon_name, color_hex)
    VALUES (NEW.id, 'Inbox', TRUE, 'inbox', '#6366F1');
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user signup
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- =============================================
-- Function: Update folder item count
-- =============================================
CREATE OR REPLACE FUNCTION public.update_folder_item_count()
RETURNS TRIGGER AS $$
BEGIN
    -- Update old folder count if item moved
    IF OLD IS NOT NULL AND OLD.folder_id IS NOT NULL THEN
        UPDATE public.folders
        SET item_count = (
            SELECT COUNT(*) FROM public.saved_items
            WHERE folder_id = OLD.folder_id AND status NOT IN ('expired', 'archived')
        ),
        updated_at = NOW()
        WHERE id = OLD.folder_id;
    END IF;
    
    -- Update new folder count
    IF NEW IS NOT NULL AND NEW.folder_id IS NOT NULL THEN
        UPDATE public.folders
        SET item_count = (
            SELECT COUNT(*) FROM public.saved_items
            WHERE folder_id = NEW.folder_id AND status NOT IN ('expired', 'archived')
        ),
        updated_at = NOW()
        WHERE id = NEW.folder_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Triggers for folder item count
DROP TRIGGER IF EXISTS on_saved_item_folder_change ON public.saved_items;
CREATE TRIGGER on_saved_item_folder_change
    AFTER INSERT OR UPDATE OF folder_id, status OR DELETE ON public.saved_items
    FOR EACH ROW EXECUTE FUNCTION public.update_folder_item_count();

-- =============================================
-- Function: Update user statistics
-- =============================================
CREATE OR REPLACE FUNCTION public.update_user_stats()
RETURNS TRIGGER AS $$
BEGIN
    -- On item saved
    IF TG_OP = 'INSERT' THEN
        UPDATE public.users
        SET total_items_saved = total_items_saved + 1,
            updated_at = NOW()
        WHERE id = NEW.user_id;
    END IF;
    
    -- On item consumed
    IF TG_OP = 'UPDATE' AND NEW.status = 'consumed' AND OLD.status != 'consumed' THEN
        UPDATE public.users
        SET total_items_consumed = total_items_consumed + 1,
            updated_at = NOW()
        WHERE id = NEW.user_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for user stats
DROP TRIGGER IF EXISTS on_saved_item_stats ON public.saved_items;
CREATE TRIGGER on_saved_item_stats
    AFTER INSERT OR UPDATE ON public.saved_items
    FOR EACH ROW EXECUTE FUNCTION public.update_user_stats();

-- =============================================
-- Function: Update user streak
-- =============================================
CREATE OR REPLACE FUNCTION public.update_user_streak(p_user_id UUID)
RETURNS VOID AS $$
DECLARE
    v_last_review DATE;
    v_current_streak INTEGER;
    v_longest_streak INTEGER;
BEGIN
    SELECT last_review_date, current_streak, longest_streak
    INTO v_last_review, v_current_streak, v_longest_streak
    FROM public.users WHERE id = p_user_id;
    
    -- If already reviewed today, do nothing
    IF v_last_review = CURRENT_DATE THEN
        RETURN;
    END IF;
    
    -- If reviewed yesterday, increment streak
    IF v_last_review = CURRENT_DATE - INTERVAL '1 day' THEN
        v_current_streak := v_current_streak + 1;
    -- If missed a day, reset streak
    ELSIF v_last_review < CURRENT_DATE - INTERVAL '1 day' OR v_last_review IS NULL THEN
        v_current_streak := 1;
    END IF;
    
    -- Update longest streak if current is higher
    IF v_current_streak > v_longest_streak THEN
        v_longest_streak := v_current_streak;
    END IF;
    
    -- Update user
    UPDATE public.users
    SET current_streak = v_current_streak,
        longest_streak = v_longest_streak,
        last_review_date = CURRENT_DATE,
        updated_at = NOW()
    WHERE id = p_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- Function: Get user statistics
-- =============================================
CREATE OR REPLACE FUNCTION public.get_user_statistics(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_result JSON;
BEGIN
    SELECT json_build_object(
        'total_saved', COALESCE(u.total_items_saved, 0),
        'total_consumed', COALESCE(u.total_items_consumed, 0),
        'total_expired', (SELECT COUNT(*) FROM public.saved_items WHERE user_id = p_user_id AND status = 'expired'),
        'total_active', (SELECT COUNT(*) FROM public.saved_items WHERE user_id = p_user_id AND status IN ('unreviewed', 'kept')),
        'consumption_rate', CASE 
            WHEN u.total_items_saved > 0 
            THEN ROUND((u.total_items_consumed::NUMERIC / u.total_items_saved) * 100, 1)
            ELSE 0 
        END,
        'current_streak', COALESCE(u.current_streak, 0),
        'longest_streak', COALESCE(u.longest_streak, 0),
        'items_by_source', (
            SELECT json_object_agg(source, cnt)
            FROM (SELECT source, COUNT(*) as cnt FROM public.saved_items WHERE user_id = p_user_id GROUP BY source) s
        ),
        'weekly_activity', (
            SELECT COALESCE(json_agg(cnt ORDER BY day), '[]'::json)
            FROM (
                SELECT 
                    date_trunc('day', created_at)::date as day,
                    COUNT(*) as cnt
                FROM public.saved_items
                WHERE user_id = p_user_id
                AND created_at >= CURRENT_DATE - INTERVAL '7 days'
                GROUP BY day
            ) w
        ),
        'guilt_meter_percentage', (
            SELECT CASE 
                WHEN COUNT(*) = 0 THEN 0
                ELSE ROUND(
                    (COUNT(*) FILTER (WHERE status = 'unreviewed')::NUMERIC / COUNT(*)) * 100,
                    1
                )
            END
            FROM public.saved_items
            WHERE user_id = p_user_id AND status NOT IN ('archived')
        )
    )
    INTO v_result
    FROM public.users u
    WHERE u.id = p_user_id;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- Function: Mark expired items
-- =============================================
CREATE OR REPLACE FUNCTION public.mark_expired_items()
RETURNS INTEGER AS $$
DECLARE
    v_count INTEGER;
BEGIN
    UPDATE public.saved_items
    SET status = 'expired',
        updated_at = NOW()
    WHERE status = 'unreviewed'
    AND expires_at IS NOT NULL
    AND expires_at < NOW();
    
    GET DIAGNOSTICS v_count = ROW_COUNT;
    RETURN v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =============================================
-- Updated at trigger function
-- =============================================
CREATE OR REPLACE FUNCTION public.update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER update_users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_folders_updated_at
    BEFORE UPDATE ON public.folders
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();

CREATE TRIGGER update_saved_items_updated_at
    BEFORE UPDATE ON public.saved_items
    FOR EACH ROW EXECUTE FUNCTION public.update_updated_at();
