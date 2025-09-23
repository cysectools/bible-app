# Supabase Database Setup Guide

## 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com)
2. Sign up or log in
3. Click "New Project"
4. Choose your organization
5. Enter project details:
   - Name: `bible-app`
   - Database Password: (choose a strong password)
   - Region: (choose closest to your users)

## 2. Get Project Credentials

1. Go to Settings → API
2. Copy your:
   - Project URL
   - Anon/Public Key

## 3. Update Database Service

In `lib/services/database_service.dart`, replace:
```dart
url: 'YOUR_SUPABASE_URL',
anonKey: 'YOUR_SUPABASE_ANON_KEY',
```

With your actual credentials.

## 4. Create Database Tables

Run these SQL commands in your Supabase SQL Editor:

### User Profiles Table
```sql
CREATE TABLE user_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  name TEXT,
  age INTEGER,
  favorite_verse TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Practice Progress Table
```sql
CREATE TABLE practice_progress (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  practice_type TEXT NOT NULL,
  completed_count INTEGER DEFAULT 0,
  correct_count INTEGER DEFAULT 0,
  total_score INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  best_streak INTEGER DEFAULT 0,
  last_completed TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, practice_type)
);
```

### User Stats Table
```sql
CREATE TABLE user_stats (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT UNIQUE NOT NULL,
  total_practices INTEGER DEFAULT 0,
  drag_drop_completed INTEGER DEFAULT 0,
  writing_completed INTEGER DEFAULT 0,
  drag_drop_streak INTEGER DEFAULT 0,
  writing_streak INTEGER DEFAULT 0,
  perfect_scores INTEGER DEFAULT 0,
  total_score INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Badges Table
```sql
CREATE TABLE badges (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT NOT NULL,
  icon TEXT NOT NULL,
  color TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### User Badges Table
```sql
CREATE TABLE user_badges (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  badge_id TEXT NOT NULL REFERENCES badges(id),
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, badge_id)
);
```

## 5. Insert Default Badges

```sql
INSERT INTO badges (id, name, description, icon, color) VALUES
('first_drag_drop_complete', 'Drag Master', 'Complete your first drag and drop practice', '🎯', '#4CAF50'),
('first_writing_complete', 'Scribe', 'Complete your first writing practice', '✍️', '#2196F3'),
('drag_drop_streak_3', 'Drag Champion', 'Complete 3 drag and drop practices in a row', '🏆', '#FF9800'),
('writing_streak_3', 'Writing Wizard', 'Complete 3 writing practices in a row', '📝', '#9C27B0'),
('perfect_score_5', 'Perfectionist', 'Get perfect scores on 5 practices', '⭐', '#FFD700'),
('total_practices_10', 'Dedicated Learner', 'Complete 10 total practices', '🎓', '#607D8B'),
('total_practices_25', 'Bible Scholar', 'Complete 25 total practices', '📚', '#795548'),
('total_practices_50', 'Bible Master', 'Complete 50 total practices', '👑', '#E91E63');
```

## 6. Set Up Row Level Security (RLS)

Enable RLS on all tables:

```sql
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE practice_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;
```

Create policies (for now, allow all access - you can restrict later):

```sql
-- User profiles policies
CREATE POLICY "Allow all access to user_profiles" ON user_profiles FOR ALL USING (true);

-- Practice progress policies
CREATE POLICY "Allow all access to practice_progress" ON practice_progress FOR ALL USING (true);

-- User stats policies
CREATE POLICY "Allow all access to user_stats" ON user_stats FOR ALL USING (true);

-- User badges policies
CREATE POLICY "Allow all access to user_badges" ON user_badges FOR ALL USING (true);

-- Badges policies (read-only for all)
CREATE POLICY "Allow read access to badges" ON badges FOR SELECT USING (true);
```

## 7. Test the Connection

Your app should now be able to connect to Supabase! The database service will automatically handle:
- User profile management
- Practice progress tracking
- Badge awarding
- Statistics tracking

## Security Notes

- The current setup allows all access for simplicity
- For production, implement proper authentication and RLS policies
- Consider using Supabase Auth for user management
- Regularly backup your database

## Next Steps

1. Update the `_userId` in your app to use actual user identification
2. Implement user authentication with Supabase Auth
3. Add more sophisticated RLS policies
4. Set up database backups
