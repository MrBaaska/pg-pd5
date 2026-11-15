-- Login-history table for index.html and nvvr.html.
begin;

grant usage on schema public to anon, authenticated;

create table if not exists public.section_session_logs (
    id text primary key,
    section_key text not null,
    section_title text not null,
    brigade_key text not null,
    position_key text not null,
    position_title text not null,
    name text not null,
    department text not null,
    login_time timestamptz not null,
    logout_time timestamptz,
    status text not null default 'Active'
        check (status in ('Active', 'Completed')),
    created_at timestamptz not null default now()
);

create index if not exists section_session_logs_section_login_idx
    on public.section_session_logs (section_key, login_time desc);

alter table public.section_session_logs enable row level security;

-- This demo uses the Supabase anon key and has no user authentication.
-- These policies make the records accessible to any visitor with the page;
-- they are not suitable for confidential or production employee data.
grant select, insert, update, delete
    on public.section_session_logs to anon, authenticated;

drop policy if exists "demo can read section session logs"
    on public.section_session_logs;
create policy "demo can read section session logs"
    on public.section_session_logs for select
    to anon, authenticated
    using (true);

drop policy if exists "demo can add section session logs"
    on public.section_session_logs;
create policy "demo can add section session logs"
    on public.section_session_logs for insert
    to anon, authenticated
    with check (true);

drop policy if exists "demo can update section session logs"
    on public.section_session_logs;
create policy "demo can update section session logs"
    on public.section_session_logs for update
    to anon, authenticated
    using (true)
    with check (true);

drop policy if exists "demo can delete section session logs"
    on public.section_session_logs;
create policy "demo can delete section session logs"
    on public.section_session_logs for delete
    to anon, authenticated
    using (true);

-- Shared autosaved form state, isolated by road section and embedded page.
create table if not exists public.section_autosave_entries (
    section_key text not null,
    frame_path text not null,
    state_key text not null,
    state jsonb not null,
    updated_at timestamptz not null default now(),
    primary key (section_key, frame_path, state_key)
);

create index if not exists section_autosave_entries_section_frame_idx
    on public.section_autosave_entries (section_key, frame_path);

alter table public.section_autosave_entries enable row level security;

-- Demo-only: anon clients can access every section; production needs authenticated section-level policies.
grant select, insert, update
    on public.section_autosave_entries to anon, authenticated;

drop policy if exists "demo can read section autosave entries"
    on public.section_autosave_entries;
create policy "demo can read section autosave entries"
    on public.section_autosave_entries for select
    to anon, authenticated
    using (true);

drop policy if exists "demo can add section autosave entries"
    on public.section_autosave_entries;
create policy "demo can add section autosave entries"
    on public.section_autosave_entries for insert
    to anon, authenticated
    with check (true);

drop policy if exists "demo can update section autosave entries"
    on public.section_autosave_entries;
create policy "demo can update section autosave entries"
    on public.section_autosave_entries for update
    to anon, authenticated
    using (true)
    with check (true);

commit;

notify pgrst, 'reload schema';
