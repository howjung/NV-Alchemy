import 'package:flutter/foundation.dart';

/// 내가 올린 게시물. 소셜 탭과 프로필의 게시물 관리가 함께 쓴다.
/// 서버 연동 전이라 앱 실행 중에만 유지된다.
class MyPost {
  const MyPost({
    required this.id,
    required this.caption,
    required this.meal,
    required this.visibility,
    required this.crew,
  });

  /// 음수. 샘플·전체 피드 번호(0 이상)와 겹치지 않는다.
  final int id;
  final String caption;
  final String meal;
  final String visibility; // 공개 / 비공개 / 크루만 공개
  final bool crew; // 크루 식단 인증으로 올렸는지

  MyPost copyWith({String? caption, String? visibility, bool? crew}) => MyPost(
    id: id,
    caption: caption ?? this.caption,
    meal: meal,
    visibility: visibility ?? this.visibility,
    crew: crew ?? this.crew,
  );
}

const meals = ['아침', '점심', '저녁', '간식'];

final myPosts = ValueNotifier<List<MyPost>>([]);

/// 크루에 가입했는지(또는 크루장인지). "크루만 공개" 선택 가능 여부에 쓴다.
final inCrew = ValueNotifier<bool>(false);

var _nextId = -1;

void addMyPost({
  required String caption,
  required String meal,
  required String visibility,
  required bool crew,
}) => myPosts.value = [
  MyPost(
    id: _nextId--,
    caption: caption,
    meal: meal,
    visibility: visibility,
    crew: crew,
  ),
  ...myPosts.value,
];

void updateMyPost(int id, {String? caption, String? visibility}) =>
    myPosts.value = [
      for (final p in myPosts.value)
        p.id == id ? p.copyWith(caption: caption, visibility: visibility) : p,
    ];

void deleteMyPost(int id) => myPosts.value = [
  for (final p in myPosts.value)
    if (p.id != id) p,
];

/// 크루를 떠나거나 삭제하면 크루 인증 글은 크루와의 연결이 끊긴다.
/// "크루만 공개" 글은 볼 사람이 없으므로 비공개로 바꾼다.
void detachCrewPosts() => myPosts.value = [
  for (final p in myPosts.value)
    p.crew
        ? p.copyWith(
            crew: false,
            visibility: p.visibility == '크루만 공개' ? '비공개' : p.visibility,
          )
        : p,
];

void resetMyPosts() {
  myPosts.value = [];
  inCrew.value = false;
  _nextId = -1;
}
