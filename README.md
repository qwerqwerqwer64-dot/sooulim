# 숲울림 — 고요한 산길

오래된 숲을 지나 산 정상까지 천천히 오르는 3D 웹 산책 게임입니다.
바람·새·물소리를 코드로 직접 합성하고, 동물과 교감하며, 정상에서 돌탑을 쌓고 층마다 소원을 남깁니다.
남긴 소원은 링크로 들어온 모든 사람과 실시간으로 공유됩니다.

**플레이:** https://qwerqwerqwer64-dot.github.io/sooulim/

## 주요 기능

- **절차적 생성 지형**: 노이즈 기반 산, 구불구불한 산길, 연못, 나무·풀 수만 개(인스턴싱)
- **사운드 합성**: 외부 음원 없이 Web Audio API로 바람, 나뭇잎, 물, 새소리 8종, 발소리, 엔진음 생성
- **동물 AI**: 10종 × 희귀도 5단계 × 성격 3가지(겁많음, 느긋함, 다정함), 교감 시스템
- **환경**: 사계절, 4가지 시간대, 자연 현상 13종(무지개, 운해, 은하수, 별똥별 등), 7km 원경
- **탈것**: 수동 5단 기어 엔듀로 바이크(경사·점프·충돌 물리)
- **돌탑 쌓기**: 타이밍 기반 쌓기 + 무게중심 안정성 판정
- **실시간 소원 기록**: Supabase(Postgres + RLS + Realtime) + 익명 로그인

## 기술 스택

| 영역 | 사용 기술 |
|---|---|
| 3D 렌더링 | Three.js (WebGL), 커스텀 셰이더(바람, 계절, 하늘, 원경 대기 원근) |
| 사운드 | Web Audio API (오실레이터, 노이즈, 필터, 컨볼루션 리버브) |
| 백엔드 | Supabase: Postgres, Row Level Security, Realtime, Anonymous Auth |
| 배포 | GitHub Pages (정적 호스팅, 빌드 과정 없음) |

## 직접 배포하는 법

### 1. Supabase 프로젝트 만들기
1. https://supabase.com 에 로그인한 뒤 **New project**를 누릅니다. 지역은 Northeast Asia (Seoul)이 가까워요.
2. 데이터베이스 비밀번호는 안전한 곳에 따로 적어두세요. 코드에는 넣지 않아요.

### 2. 테이블 만들기
1. 왼쪽 메뉴에서 **SQL Editor** → **New query**를 엽니다.
2. `setup.sql` 내용을 전부 붙여넣고 **Run**을 누릅니다.

### 3. 익명 로그인 켜기
- **Authentication** → **Sign In / Providers**(또는 Settings)에서 **Allow anonymous sign-ins**를 켭니다.
- 이걸 켜야 방문자가 회원가입 없이 소원을 남길 수 있어요.

### 4. 연결 정보 넣기
1. **Project Settings** → **API**(또는 API Keys)에서 아래 두 가지를 복사합니다.
   - Project URL: `https://xxxx.supabase.co`
   - Publishable key: `sb_publishable_...`
2. `index.html` 위쪽의 `SUPABASE_URL`, `SUPABASE_KEY`에 붙여넣습니다.

> Publishable key는 웹페이지에 공개돼도 괜찮은 키예요. 보안은 RLS 정책이 담당해요.
> **secret 키(`sb_secret_...`)나 service_role 키는 절대 넣지 마세요.**

### 5. GitHub Pages로 배포
1. GitHub에서 **New repository**를 누르고, 이름을 `sooulim`, 공개 범위를 **Public**으로 만듭니다.
2. **Add file** → **Upload files**로 `index.html`, `README.md`, `setup.sql`을 올리고 **Commit**합니다.
3. **Settings** → **Pages**에서 Source를 **Deploy from a branch**, Branch를 `main` / `(root)`로 정하고 **Save**합니다.
4. 1~2분 뒤 `https://<GitHub 아이디>.github.io/sooulim/` 에서 열립니다.

## 관리

- **부적절한 소원 지우기**: Supabase → **Table Editor** → `wishes` 테이블에서 해당 줄을 선택하고 삭제합니다.
- **도배 방지**: 한 사람당 10초에 1개, 하루 30개까지 올릴 수 있어요(DB 트리거). 욕설은 브라우저에서 간단히 거릅니다.
- **한계**: 브라우저 기록을 지우면 새 익명 사용자가 되므로, 작정한 도배는 완전히 막지 못해요. 필요하면 Supabase Auth의 CAPTCHA를 켜세요.

## 조작

게임 안에서 **L** 키를 누르면 전체 설명서가 열립니다.

| 키 | 동작 |
|---|---|
| WASD | 이동 |
| Shift | 달리기 |
| Space | 점프 |
| E | 교감, 돌 줍기·올리기 |
| V | 1인칭 / 3인칭 |
| F / B | 바이크 타기 / 부르기 |
| T / Y | 시간대 / 계절 |
| N / C / K | 지도 / 도감 / 소원 기록 |
