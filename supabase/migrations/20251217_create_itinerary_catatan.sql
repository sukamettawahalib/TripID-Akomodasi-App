-- Create table for storing itinerary notes (activity and transport notes per day)
CREATE TABLE IF NOT EXISTS itinerary_catatan (
    id_catatan SERIAL PRIMARY KEY,
    id_petualangan INT NOT NULL,
    hari_ke INT NOT NULL,
    tipe_catatan VARCHAR(20) NOT NULL CHECK (tipe_catatan IN ('aktivitas', 'transportasi')),
    waktu VARCHAR(10),
    konten TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Foreign key to petualangan table
    CONSTRAINT fk_petualangan
        FOREIGN KEY (id_petualangan) 
        REFERENCES petualangan(id_petualangan)
        ON DELETE CASCADE
);

-- Create index for faster queries
CREATE INDEX idx_itinerary_catatan_petualangan ON itinerary_catatan(id_petualangan);
CREATE INDEX idx_itinerary_catatan_hari ON itinerary_catatan(id_petualangan, hari_ke);

-- Add updated_at trigger
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_itinerary_catatan_updated_at 
    BEFORE UPDATE ON itinerary_catatan
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Enable Row Level Security (optional, adjust based on your needs)
ALTER TABLE itinerary_catatan ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access notes for their own trips
CREATE POLICY "Users can view their own trip notes"
    ON itinerary_catatan FOR SELECT
    USING (
        id_petualangan IN (
            SELECT id_petualangan 
            FROM petualangan 
            WHERE id_pembuat = auth.uid()
        )
    );

CREATE POLICY "Users can insert notes for their own trips"
    ON itinerary_catatan FOR INSERT
    WITH CHECK (
        id_petualangan IN (
            SELECT id_petualangan 
            FROM petualangan 
            WHERE id_pembuat = auth.uid()
        )
    );

CREATE POLICY "Users can update their own trip notes"
    ON itinerary_catatan FOR UPDATE
    USING (
        id_petualangan IN (
            SELECT id_petualangan 
            FROM petualangan 
            WHERE id_pembuat = auth.uid()
        )
    );

CREATE POLICY "Users can delete their own trip notes"
    ON itinerary_catatan FOR DELETE
    USING (
        id_petualangan IN (
            SELECT id_petualangan 
            FROM petualangan 
            WHERE id_pembuat = auth.uid()
        )
    );
