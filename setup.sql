-- Replace BOTH placeholder UUIDs with the actual User IDs from Authentication > Users.
-- Run once in a NEW Supabase project, before publishing the website.
begin;
create table public.wall_items (
  id uuid primary key,
  kind text not null check (kind in ('note','photo','decoration','board')),
  text text not null default '' check (char_length(text)<=1200),
  image text check (image is null or (char_length(image)<=1500000 and image like 'data:image/jpeg;base64,%')),
  color text not null check (color ~ '^#[0-9a-fA-F]{6}$'),
  x double precision not null check (x between 0 and 1800),
  y double precision not null check (y between 0 and 1200),
  angle integer not null check (angle between -180 and 180),
  width integer not null check (width between 110 and (case when kind='decoration' then 1600 else 500 end)),
  z bigint not null check (z>=0),
  author text not null check (char_length(author)<=35),
  created_at timestamptz not null default now(),
  appearance jsonb not null default '{}'::jsonb,
  check ((kind in ('note','decoration','board') and image is null) or (kind='photo' and image is not null)),
  check ((kind='board') = (id='00000000-0000-4000-8000-000000000707'::uuid))
);
alter table public.wall_items enable row level security;
revoke all on public.wall_items from anon, authenticated;
grant select, insert, update, delete on public.wall_items to authenticated;
create policy "Only the two approved people" on public.wall_items
for all to authenticated
using ((select auth.uid()) in ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid))
with check ((select auth.uid()) in ('00000000-0000-0000-0000-000000000001'::uuid,'00000000-0000-0000-0000-000000000002'::uuid));
commit;
