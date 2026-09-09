/*
# Create ResQ Emergency Response Schema

1. New Tables
- `incidents` — Emergency incidents reported by civilians. Contains location (lat/lng), severity (RSI score), victim count, suspected injuries, hazards, triage level, and status (active/dispatched/resolved).
- `responders` — Registered emergency response units (ambulances, FRSC patrols). Contains name, type, status (idle/dispatched/en_route/on_scene), capability tags, and live GPS coordinates.
- `hospitals` — Healthcare facilities with trauma capability metadata (trauma level, specialties, blood bank, ICU, bed availability).
- `messages` — Chat messages between civilians and dispatchers/responders. Linked to incidents.
- `responder_locations` — Time-series GPS pings from responders (broadcast every 15 seconds).

2. Security
- This is a no-auth emergency app — civilians report incidents without any login.
- RLS enabled on ALL tables.
- All policies use `TO anon, authenticated` since the frontend operates with the anon key.
- Data is intentionally shared (dispatchers, responders, civilians all need cross-access).
*/

-- Incidents table
CREATE TABLE IF NOT EXISTS incidents (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  short_id text NOT NULL DEFAULT UPPER(SUBSTRING(gen_random_uuid()::text, 1, 6)),
  reporter_name text,
  reporter_phone text,
  description text,
  latitude double precision,
  longitude double precision,
  location_text text,
  severity_score numeric DEFAULT 0,
  triage_level text DEFAULT 'minor',
  victim_count integer DEFAULT 1,
  suspected_injuries text,
  hazards text,
  bystander_actions text,
  status text DEFAULT 'active',
  assigned_responder_id uuid,
  assigned_hospital_id uuid,
  eta_minutes integer,
  photo_url text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE incidents ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_incidents" ON incidents;
CREATE POLICY "anon_select_incidents" ON incidents FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_incidents" ON incidents;
CREATE POLICY "anon_insert_incidents" ON incidents FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_incidents" ON incidents;
CREATE POLICY "anon_update_incidents" ON incidents FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_incidents" ON incidents;
CREATE POLICY "anon_delete_incidents" ON incidents FOR DELETE
  TO anon, authenticated USING (true);

-- Responders table
CREATE TABLE IF NOT EXISTS responders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  short_id text NOT NULL DEFAULT UPPER(SUBSTRING(gen_random_uuid()::text, 1, 4)),
  name text NOT NULL,
  unit_type text DEFAULT 'ambulance',
  status text DEFAULT 'idle',
  capabilities text[] DEFAULT ARRAY[]::text[],
  latitude double precision,
  longitude double precision,
  heading numeric,
  speed numeric DEFAULT 0,
  phone text,
  current_incident_id uuid,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE responders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_responders" ON responders;
CREATE POLICY "anon_select_responders" ON responders FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_responders" ON responders;
CREATE POLICY "anon_insert_responders" ON responders FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_responders" ON responders;
CREATE POLICY "anon_update_responders" ON responders FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_responders" ON responders;
CREATE POLICY "anon_delete_responders" ON responders FOR DELETE
  TO anon, authenticated USING (true);

-- Hospitals table
CREATE TABLE IF NOT EXISTS hospitals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  trauma_level integer DEFAULT 3,
  specialties text[] DEFAULT ARRAY[]::text[],
  has_icu boolean DEFAULT false,
  has_blood_bank boolean DEFAULT false,
  bed_availability integer DEFAULT 0,
  phone text,
  address text,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE hospitals ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_hospitals" ON hospitals;
CREATE POLICY "anon_select_hospitals" ON hospitals FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_hospitals" ON hospitals;
CREATE POLICY "anon_insert_hospitals" ON hospitals FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_hospitals" ON hospitals;
CREATE POLICY "anon_update_hospitals" ON hospitals FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_hospitals" ON hospitals;
CREATE POLICY "anon_delete_hospitals" ON hospitals FOR DELETE
  TO anon, authenticated USING (true);

-- Messages table
CREATE TABLE IF NOT EXISTS messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  incident_id uuid NOT NULL REFERENCES incidents(id) ON DELETE CASCADE,
  sender_role text NOT NULL,
  sender_name text,
  content text NOT NULL,
  message_type text DEFAULT 'text',
  is_guidance boolean DEFAULT false,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_messages" ON messages;
CREATE POLICY "anon_select_messages" ON messages FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_messages" ON messages;
CREATE POLICY "anon_insert_messages" ON messages FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_messages" ON messages;
CREATE POLICY "anon_update_messages" ON messages FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_messages" ON messages;
CREATE POLICY "anon_delete_messages" ON messages FOR DELETE
  TO anon, authenticated USING (true);

-- Responder location pings (time-series)
CREATE TABLE IF NOT EXISTS responder_locations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  responder_id uuid NOT NULL REFERENCES responders(id) ON DELETE CASCADE,
  latitude double precision NOT NULL,
  longitude double precision NOT NULL,
  heading numeric,
  speed numeric,
  recorded_at timestamptz DEFAULT now()
);

ALTER TABLE responder_locations ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_responder_locations" ON responder_locations;
CREATE POLICY "anon_select_responder_locations" ON responder_locations FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_responder_locations" ON responder_locations;
CREATE POLICY "anon_insert_responder_locations" ON responder_locations FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_responder_locations" ON responder_locations;
CREATE POLICY "anon_delete_responder_locations" ON responder_locations FOR DELETE
  TO anon, authenticated USING (true);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_incidents_status ON incidents(status);
CREATE INDEX IF NOT EXISTS idx_incidents_severity ON incidents(severity_score DESC);
CREATE INDEX IF NOT EXISTS idx_incidents_created ON incidents(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_messages_incident ON messages(incident_id);
CREATE INDEX IF NOT EXISTS idx_messages_created ON messages(created_at);
CREATE INDEX IF NOT EXISTS idx_responders_status ON responders(status);
CREATE INDEX IF NOT EXISTS idx_responder_locations_responder ON responder_locations(responder_id);
CREATE INDEX IF NOT EXISTS idx_responder_locations_recorded ON responder_locations(recorded_at DESC);

-- Enable realtime on key tables
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'incidents') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE incidents;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'responders') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE responders;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'messages') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE messages;
  END IF;
  IF NOT EXISTS (SELECT 1 FROM pg_publication_tables WHERE pubname = 'supabase_realtime' AND tablename = 'responder_locations') THEN
    ALTER PUBLICATION supabase_realtime ADD TABLE responder_locations;
  END IF;
END $$;