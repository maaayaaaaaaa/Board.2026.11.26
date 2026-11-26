-- EXISTING WALL: run once (or again safely) in Supabase SQL Editor.
-- Keeps existing rows and the existing two-account RLS policy.
begin;
alter table public.wall_items add column if not exists appearance jsonb not null default '{}'::jsonb;
-- Remove the old kind/image cross-check and kind check, not the image format or RLS.
do $$
declare c record;
begin
  for c in select conname from pg_constraint
    where conrelid='public.wall_items'::regclass and contype='c'
      and pg_get_constraintdef(oid) ~* '\m(kind|width)\M'
  loop
    execute format('alter table public.wall_items drop constraint %I', c.conname);
  end loop;
end $$;
alter table public.wall_items add constraint wall_items_kind_v2 check (kind in ('note','photo','decoration','board'));
alter table public.wall_items add constraint wall_items_content_v2 check (
  (kind='photo' and image is not null) or (kind in ('note','decoration','board') and image is null)
);
alter table public.wall_items add constraint wall_items_board_id_v2 check (
  (kind='board') = (id='00000000-0000-4000-8000-000000000707'::uuid)
);
alter table public.wall_items add constraint wall_items_width_v2 check (width between 110 and (case when kind='decoration' then 1600 else 500 end));
commit;
