# 실시간 의연금 모으기 Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 20명이 각자 태블릿에서 친구 미션 퀴즈로 엽전을 모아 65만 원씩 넣고, 반 모금함 1,300만 원이 실시간으로 함께 차게 한다.

**Architecture:** `index.html` 하나에 `Escape.sync`(공유 상태 층)를 더한다. 백엔드는 Firebase RTDB(compat SDK, databaseURL만) 또는 로컬(store에 저장). 화면은 sync를 구독해 부분만 고친다(입력 중인 칸은 건드리지 않음).

**Tech Stack:** vanilla JS, Firebase JS SDK compat 10.12.2 (gstatic), 브라우저 검사 페이지 `tests/test.html`.

**Spec:** docs/superpowers/specs/2026-11-17-realtime-donation-design.md

## Global Constraints
- 화면 글과 문서에 중간점(U+00B7)을 쓰지 않는다.
- 학생 번호 1~23 중 2, 15, 17 제외 20명, 번호 순 5명씩 4모둠. 65만 원 × 20 = 1,300만 원.
- 선생님 비밀번호 4129. 선생님 화면은 나가면 다시 잠긴다.
- 검사는 `index.html?local`(로컬 모드)로만 돈다. 실제 반 데이터에 쓰지 않는다.
- 학생이 쓴 글은 모두 esc()로 보여 준다.

## Review Focus
1. 입력 중인 칸이 다른 친구의 실시간 갱신 때문에 지워지거나 커서가 튀면 안 된다.
2. '새 수업 시작' 뒤 지난 수업 기기가 옛 진행(비밀 숫자, 열린 금고)을 그대로 들고 있으면 안 된다. 처음 연결한 기기는 지워지면 안 된다.
3. 연결이 끊기거나 Firebase가 막혀도 미션, 금고, 증서, 호외는 그 기기에서 돌아가야 한다.
4. 같은 문제를 마구 눌러 맞히지 못하게 틀리면 잠긴다. 엽전 4개 전에는 넣기 버튼이 안 눌린다.
5. 친구가 쓴 글(HTML 꼴)도 글자로만 보인다.

---

### Task 1: 퀴즈 자료와 공유 상태 층
**Files:** Modify `index.html` (data script, 새 sync script), `tests/test.html`
**Produces:** `Escape.QUIZ[m] = {q, options[4], answer}`, `Escape.quizFor(no) -> [{friend, mission, title, q, options, answer}]`(자리 순, 자기 제외), `Escape.COINS_NEEDED = 4`, `Escape.SEAT_FIELDS`, `Escape.sync = {tree(), subscribe(fn)->unsub, set(path, v), clear(session), status(), use(backend)}`, `Escape.makeLocalBackend(store)`.
- [ ] 실패 검사: quizFor(12) → 친구 13, 14, 16, 18과 미션 4, 5, 1, 2. 모든 QUIZ 보기 4개, 답 위치가 보기 안. sync.set('donated/3', true) 뒤 tree().donated[3] === true, set(path, null)은 지움, clear(5) 뒤 tree()는 {session:5}.
- [ ] 구현, 전체 검사 통과.

### Task 2: 모둠 화면 다시 만들기
**Files:** Modify `index.html` (group script), `tests/test.html`
- [ ] 실패 검사: 퀴즈 카드 4개, 정답 → quiz/12/4 저장과 엽전 1, 오답 → 그 카드 잠김과 '13번' 안내, 엽전 4개 뒤 #donate → donated/12와 게이지 '65만 원', 다른 학생 donated 실시간 반영과 20명이면 #celebrate, 자리별 맡은 칸(12번은 cut, fact1만 입력), 친구 칸 실시간 반영, 내 약속 → 호외, HTML 꼴 글 escape, 새로고침 뒤 유지.
- [ ] 구현: 정적 틀 한 번 그리고 구독으로 게이지, 엽전, 친구 칸, 미리보기만 고친다.

### Task 3: 선생님 현황판과 새 수업 시작
**Files:** Modify `index.html` (teacher script, screens script), `tests/test.html`
- [ ] 실패 검사: 현황판 칸 20개가 donated 따라 실시간으로 켜짐, #reset(새 수업 시작) → 방 데이터 지움과 session 숫자, 잠금, #start. 다른 session이 오면 그 기기 me가 지워지고 #start.
- [ ] 구현: 옛 게이지 토글 제거.

### Task 4: Firebase 연결과 안내
**Files:** Modify `index.html` (SDK script 태그, FIREBASE_URL, makeFirebaseBackend), `README.md`, `docs/firebase-rules.json`
- [ ] Firebase 무료 프로젝트와 RTDB(asia-southeast1) 만들기, 규칙 게시, databaseURL 넣기.
- [ ] 브라우저 탭 두 개로 실제 실시간 확인(한쪽에서 넣으면 다른 쪽 게이지가 오름). 검사 전체 통과.
