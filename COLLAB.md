# 협업 안내 (COLLAB)

Antifreeze Flutter 프론트엔드를 두 명 이상이 함께 작업하기 위한 규칙이다. **사람과 AI 에이전트 모두 작업을 시작하기 전에 이 파일, `docs/프론트엔드_작업이력.md`, `docs/이어하기.md`를 읽는다.**

- 저장소: `howjung/NV-Alchemy` (앱 코드는 `flutter_apps/`)
- 작업 브랜치: `feat/frontend-collab`
- 기준 문서: `docs/PRD_Antifreeze.md`, 최종 Figma(파일 키 `gkRodOTSAWJ7EeRMANmERf`)
- 코드 작성 지침: `flutter_apps/AGENTS.md` (변경은 최소로, 인접 코드는 건드리지 않기)

## 1. 시작 전 동기화

1. 작업 중인 파일이 있으면 먼저 커밋하거나 `git stash` 한다.
2. 최신을 받는다.
   ```
   git fetch origin
   git checkout feat/frontend-collab
   git pull
   ```
3. 환경과 상태를 확인한다.
   ```
   cd flutter_apps
   flutter pub get
   flutter analyze
   flutter test
   ```
   `flutter analyze`는 이슈 없음이어야 하고 `flutter test`는 모두 통과해야 한다.

## 2. 파일 영역 (충돌 방지)

| 영역 | 담당 | 파일 |
| --- | --- | --- |
| 소셜 탭 | 소셜 담당 | `features/social/presentation/*`, `core/widgets/app_overlays.dart` |
| 홈·기록 | 홈·기록 담당 | `features/home/presentation/*`, `features/records/presentation/*` |
| 쇼핑 | 소셜 담당(작업 중) | `features/shopping/presentation/*` |
| 프로필 | 소셜 담당(작업 예정) | `features/profile/presentation/*` |

- 다른 사람 영역의 파일을 고쳐야 하면 **먼저 그 사람에게 알린다.**
- 공용 파일(`core/theme/app_theme.dart`, `core/navigation/app_routes.dart` 등)을 고칠 때도 먼저 알린다.
- 영역 담당이 바뀌면 이 표를 고친다.

## 3. 푸시 전 규칙

1. `git fetch origin`으로 원격에 새 커밋이 있는지 본다.
2. 새 커밋이 있으면 겹치는 파일을 확인한다.
   ```
   git diff --name-only HEAD origin/feat/frontend-collab
   ```
3. 병합하고(`git merge origin/feat/frontend-collab`) 다시 `flutter analyze`, `flutter test`를 통과시킨다.
4. 푸시한다. 강제 푸시(`--force`)는 하지 않는다.
5. 커밋 메시지는 `feat:`, `fix:`, `docs:` 접두어와 한국어 설명을 쓴다.

## 4. 작업 이력 갱신

프론트엔드 코드나 이 문서를 고칠 때마다 `docs/프론트엔드_작업이력.md`를 함께 갱신한다.

- 상단 "버전: vN"을 1 올린다.
- 수정 이력 표에 한 줄을 추가한다(버전·날짜·내용·커밋 해시).
- 같은 작업의 여러 수정은 한 버전으로 묶는다.
- 커밋 해시는 커밋한 뒤에 채운다.

## 5. 공용 위젯 (먼저 재사용한다)

| 위젯 | 위치 | 용도 |
| --- | --- | --- |
| `showConfirmPopup` | `core/widgets/app_overlays.dart` | 삭제·탈퇴·추방 같은 확인 팝업 |
| `AppMenu`, `AppMenuItem` | `core/widgets/app_overlays.dart` | 드롭다운 메뉴 |
| `PrimaryButton`, `LabeledField`, `ScreenTopBar` | `core/widgets/antifreeze_widgets.dart` | 기본 버튼·입력·상단 바 |
| `PostActionRow`, `PostInteractionStore` | `features/social/presentation/post_detail_screen.dart` | 좋아요·댓글·불꽃 보내기 |

새 위젯을 만들기 전에 위 목록에 같은 역할이 있는지 확인한다.

## 6. Figma 기준 작업

- 화면은 Figma 프레임을 기준으로 맞춘다. Figma에 없는 상태를 만들면 **임시 디자인**으로 표시하고 `docs/프론트엔드_작업이력.md`의 "Figma에 없어서 임시로 만든 것" 목록에 추가한다.
- 시트 프레임(P1~P5, POP-03 등)은 "원본"이다. 실제 화면은 `Overlay/…` 프레임을 기준으로 한다.
- 서버가 연결되기 전까지 좋아요·댓글·게시물 같은 상태는 앱 실행 중에만 유지된다.

## 7. 지금 알려진 문제

- PRD N13(불꽃 보내기 규칙)이 확정 전이라 임시값(게시물당 1회)으로 구현돼 있다.
- 프로필 화면에서 `ListTile` 물결 효과 경고가 남아 있을 수 있다(쇼핑은 v11에서 해결).
- 자세한 목록은 `docs/프론트엔드_작업이력.md`의 "확정 필요 / 남은 확인"을 본다.
