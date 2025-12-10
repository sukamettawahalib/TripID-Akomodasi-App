# Fix: Data Not Inserting to `pengguna` Table

## Problem
Users can register but data doesn't appear in the `pengguna` table.

## Most Common Cause: Email Confirmation Required

By default, Supabase requires email confirmation before users can be fully authenticated.

## Solution: Disable Email Confirmation (For Development)

### Step 1: Go to Supabase Dashboard
1. Open: https://supabase.com/dashboard
2. Select your project: `vtjubyiuuhwzqkegojzs`

### Step 2: Disable Email Confirmation
1. Go to **Authentication** → **Providers**
2. Click on **Email**
3. Find **"Confirm email"** setting
4. **Toggle it OFF** (disable)
5. Click **Save**

### Step 3: Enable Anonymous Sign-ins (Optional)
1. In the same Email provider settings
2. Find **"Enable anonymous sign-ins"**
3. Toggle it ON if needed

### Step 4: Test Again
1. Run your app: `flutter run`
2. Try to register a new user
3. Check the terminal for debug logs
4. Check Supabase **Authentication** → **Users** to see if user was created
5. Check **Table Editor** → **pengguna** to see if profile was inserted

## Debugging Steps

### 1. Check Terminal Output
After running registration, you should see:
```
SignUp response: User=<user-id>, Session=true/false
Insert result: [...]
```

### 2. Check Supabase Auth Users
1. Go to **Authentication** → **Users**
2. Look for the email you registered
3. Check the **Confirmed At** column - it should have a timestamp

### 3. Check pengguna Table
1. Go to **Table Editor** → **pengguna**
2. Refresh the table
3. Look for your username/email

## Common Issues

### Issue 1: Email Confirmation Required
**Symptoms:** User appears in Auth Users but not in pengguna table  
**Solution:** Disable "Confirm email" in Authentication settings

### Issue 2: Row Level Security (RLS) Blocking Inserts
**Symptoms:** Error message about permissions  
**Solution:** Temporarily disable RLS for testing:

```sql
-- Run this in SQL Editor
ALTER TABLE pengguna DISABLE ROW LEVEL SECURITY;
```

### Issue 3: Duplicate Email
**Symptoms:** Error about unique constraint violation  
**Solution:** Delete test users from both:
- Authentication → Users
- Table Editor → pengguna

### Issue 4: Missing Fields
**Symptoms:** Error about NULL values  
**Solution:** Check that all required fields are being sent

## Verify Current Settings

### Check if Email Confirmation is Enabled:
1. Authentication → Settings → Auth
2. Look for **"Enable email confirmations"**
3. Should be **OFF** for development

### Check if Auto-confirm is Enabled:
1. Authentication → Settings → Auth
2. Look for **"Enable email autoconfirm"**  
3. Should be **ON** for development

## Alternative: Manual SQL Insert Test

Test if you can manually insert data:

```sql
-- Go to SQL Editor and run:
INSERT INTO pengguna (email, username, password, total_trip, jarak_tempuh, jam_terbang)
VALUES ('test@example.com', 'testuser', 'password123', 0, 0, 0);
```

If this works → RLS might be the issue  
If this fails → Check table structure/constraints

## Production Note

⚠️ **For production:**
- Re-enable email confirmation
- Implement proper email verification flow
- Enable RLS with proper policies
- Remove password from pengguna table (use Supabase Auth only)

---

## Quick Fix Command

If you have Supabase CLI installed:

```bash
supabase functions deploy --project-ref vtjubyiuuhwzqkegojzs
```

Then update your config to disable email confirmation programmatically.
