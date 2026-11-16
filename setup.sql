-- =====================================================================
-- 숲울림: 소원 돌탑 저장소 설정
-- Supabase 대시보드 → SQL Editor → New query 에 전체를 붙여넣고 Run 하세요.
-- 여러 번 실행해도 안전하도록 작성했어요.
-- =====================================================================

-- 1) 소원 테이블
create table if not exists public.wishes (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  layer      int  not null check (layer between 1 and 99),
  name       text not null default '' check (char_length(name) <= 12),
  text       text not null check (char_length(trim(text)) between 1 and 60),
  created_at timestamptz not null default now()
);
create index if not exists wishes_created_at_idx on public.wishes (created_at);
create index if not exists wishes_user_idx on public.wishes (user_id, created_at);

-- 2) 행 단위 보안(RLS): 누구나 읽기, 본인만 쓰기·지우기
alter table public.wishes enable row level security;

drop policy if exists "wishes_read_all"   on public.wishes;
drop policy if exists "wishes_insert_own" on public.wishes;
drop policy if exists "wishes_delete_own" on public.wishes;

create policy "wishes_read_all" on public.wishes
  for select to anon, authenticated using (true);

create policy "wishes_insert_own" on public.wishes
  for insert to authenticated with check (auth.uid() = user_id);

create policy "wishes_delete_own" on public.wishes
  for delete to authenticated using (auth.uid() = user_id);

-- 수정(update)은 정책이 없으므로 아무도 못 해요. 관리자는 대시보드에서 직접 지울 수 있어요.

-- 3) 도배 방지: 사람마다 10초에 1개, 하루 30개까지
create or replace function public.wishes_rate_limit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if exists (
    select 1 from public.wishes
    where user_id = new.user_id and created_at > now() - interval '10 seconds'
  ) then
    raise exception '너무 빨라요. 잠시 후 다시 시도해 주세요.';
  end if;

  if (
    select count(*) from public.wishes
    where user_id = new.user_id and created_at > now() - interval '1 day'
  ) >= 30 then
    raise exception '하루에 남길 수 있는 소원은 30개까지예요.';
  end if;

  return new;
end;
$$;

drop trigger if exists wishes_rate_limit on public.wishes;
create trigger wishes_rate_limit
  before insert on public.wishes
  for each row execute function public.wishes_rate_limit();

-- 4) 실시간: 새 소원이 올라오면 다른 사람 화면에 바로 보이게
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'wishes'
  ) then
    alter publication supabase_realtime add table public.wishes;
  end if;
end $$;
