# Itinerary Notes Database Integration Guide

## 📋 Overview
This guide explains how to set up and use the itinerary notes database feature for storing user notes about activities and transportation for each day of their trip.

## 🗄️ Database Schema

### Table: `itinerary_catatan`

```sql
CREATE TABLE itinerary_catatan (
    id_catatan SERIAL PRIMARY KEY,
    id_petualangan INT NOT NULL,
    hari_ke INT NOT NULL,
    tipe_catatan VARCHAR(20) NOT NULL CHECK (tipe_catatan IN ('aktivitas', 'transportasi')),
    waktu VARCHAR(10),
    konten TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    CONSTRAINT fk_petualangan
        FOREIGN KEY (id_petualangan) 
        REFERENCES petualangan(id_petualangan)
        ON DELETE CASCADE
);
```

### Column Descriptions

| Column | Type | Description |
|--------|------|-------------|
| `id_catatan` | SERIAL | Primary key, auto-incrementing |
| `id_petualangan` | INT | Foreign key referencing the trip |
| `hari_ke` | INT | Day number (1-indexed, Day 1, Day 2, etc.) |
| `tipe_catatan` | VARCHAR(20) | Type of note: 'aktivitas' or 'transportasi' |
| `waktu` | VARCHAR(10) | Optional time string (e.g., "09:00") |
| `konten` | TEXT | The actual note content |
| `created_at` | TIMESTAMPTZ | Timestamp when note was created |
| `updated_at` | TIMESTAMPTZ | Timestamp when note was last updated |

## 🚀 Setup Instructions

### Step 1: Run SQL Migration

1. Open your Supabase Dashboard
2. Go to **SQL Editor**
3. Create a new query
4. Copy the entire content from `supabase/migrations/20251217_create_itinerary_catatan.sql`
5. Click **Run** to execute the SQL

The migration will:
- ✅ Create the `itinerary_catatan` table
- ✅ Add foreign key constraint to `petualangan` table
- ✅ Create indexes for better query performance
- ✅ Add auto-update trigger for `updated_at` column
- ✅ Enable Row Level Security (RLS)
- ✅ Create security policies (users can only access their own trip notes)

### Step 2: Verify Table Creation

1. Go to **Table Editor** in Supabase Dashboard
2. You should see `itinerary_catatan` in the table list
3. Click on it to verify the structure

### Step 3: Test the Integration

1. Run your Flutter app: `flutter run`
2. Navigate to any trip's itinerary screen
3. Add a note to Aktivitas or Transportasi
4. Check Supabase Table Editor → `itinerary_catatan` to see the saved note

## 📝 Service Methods

### `ItineraryService` Class

Location: `lib/services/itinerary_service.dart`

#### 1. Save Note
```dart
await itineraryService.saveNote(
  idPetualangan: tripId,
  hariKe: dayIndex, // 0-indexed in UI
  tipeCatatan: 'aktivitas', // or 'transportasi'
  waktu: '09:00', // optional
  konten: 'Visit Monas at 9 AM',
);
```

#### 2. Load All Notes for a Trip
```dart
final notes = await itineraryService.loadNotesForTrip(tripId);
// Returns: Map<int, Map<String, List<Map<String, dynamic>>>>
// Structure: {dayIndex: {type: [notes]}}
```

#### 3. Delete a Note
```dart
await itineraryService.deleteNote(noteId);
```

#### 4. Update a Note
```dart
await itineraryService.updateNote(
  idCatatan: noteId,
  waktu: '10:00',
  konten: 'Updated note content',
);
```

#### 5. Delete All Notes for a Trip
```dart
await itineraryService.deleteAllNotesForTrip(tripId);
```

## 🔄 How It Works

### Data Flow

1. **User adds a note** → `_showAddNoteDialog()` is called
2. **Dialog submitted** → `onAddNote()` callback triggered
3. **Save to database** → `itineraryService.saveNote()` called
4. **Update UI** → `setState()` updates local state with saved note
5. **On screen load** → `_loadNotesFromDatabase()` fetches all notes

### Note Structure in Memory

```dart
Map<int, List<Map<String, dynamic>>> _activityNotesPerDay = {
  0: [ // Day 0 (Day 1 in UI)
    {'id': 1, 'time': '09:00', 'content': 'Visit Monas'},
    {'id': 2, 'time': '14:00', 'content': 'Lunch at restaurant'},
  ],
  1: [ // Day 1 (Day 2 in UI)
    {'id': 3, 'time': '', 'content': 'Beach day'},
  ],
};
```

## 🔐 Security (Row Level Security)

The migration includes RLS policies that ensure:

- ✅ Users can only view notes for trips they created
- ✅ Users can only add notes to their own trips
- ✅ Users can only update/delete their own trip notes
- ❌ Users cannot access other users' notes

### Policy Logic

All policies check:
```sql
id_petualangan IN (
    SELECT id_petualangan 
    FROM petualangan 
    WHERE id_pembuat = auth.uid()
)
```

This ensures that only the trip creator (matched by `auth.uid()`) can perform operations on the notes.

## 🗑️ Cascade Deletion

When a trip is deleted from the `petualangan` table, all associated notes are automatically deleted due to the `ON DELETE CASCADE` constraint.

To manually delete trip notes when deleting a trip:
```dart
// In trip_service.dart deleteTrip() method
await _itineraryService.deleteAllNotesForTrip(id);
await _supabase.from('petualangan').delete().eq('id_petualangan', id);
```

## 📊 Example Queries

### Get all notes for a specific trip
```sql
SELECT * FROM itinerary_catatan 
WHERE id_petualangan = 1 
ORDER BY hari_ke, created_at;
```

### Get activity notes for Day 2 of Trip 1
```sql
SELECT * FROM itinerary_catatan 
WHERE id_petualangan = 1 
  AND hari_ke = 2 
  AND tipe_catatan = 'aktivitas';
```

### Count notes per trip
```sql
SELECT id_petualangan, COUNT(*) as total_notes 
FROM itinerary_catatan 
GROUP BY id_petualangan;
```

## ✅ Testing Checklist

- [ ] Run SQL migration in Supabase
- [ ] Verify table appears in Table Editor
- [ ] Test adding activity note
- [ ] Test adding transport note
- [ ] Test deleting a note
- [ ] Test notes persist after closing and reopening app
- [ ] Test notes are private (create second user, verify cannot see first user's notes)
- [ ] Test cascade deletion (delete trip, verify notes are deleted)

## 🐛 Troubleshooting

### Notes not saving
1. Check console for error messages
2. Verify RLS policies are enabled
3. Check if user is authenticated (`auth.uid()` returns valid ID)
4. Verify `id_petualangan` exists in `petualangan` table

### Notes not loading
1. Check if `id_petualangan` is passed correctly to the screen
2. Verify foreign key constraint is set up
3. Check console for loading errors

### Permission denied errors
1. Verify RLS policies are created correctly
2. Check if `id_pembuat` in `petualangan` table matches `auth.uid()`
3. Try disabling RLS temporarily for testing:
```sql
ALTER TABLE itinerary_catatan DISABLE ROW LEVEL SECURITY;
```

## 📚 Related Files

- `lib/screens/home/itinerary_screen.dart` - UI integration
- `lib/services/itinerary_service.dart` - Database service
- `supabase/migrations/20251217_create_itinerary_catatan.sql` - SQL migration

## 🎯 Next Steps

1. Run the SQL migration in Supabase
2. Test adding and viewing notes
3. Consider adding features:
   - Edit existing notes
   - Add timestamps to notes
   - Add categories/tags to notes
   - Export itinerary with notes to PDF
