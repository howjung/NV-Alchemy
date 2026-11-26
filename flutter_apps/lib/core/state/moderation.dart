import 'package:flutter/foundation.dart';

/// 신고·관심 없음·차단 상태. 서버 연동 전이라 앱 실행 중에만 유지된다.
/// 게시물 번호가 0 이상이면 샘플 게시물이다(내 글은 음수).
final hiddenPosts = ValueNotifier<Set<int>>({}); // 관심 없음 + 신고한 글
final reportedPosts = <int>{}; // 이미 신고한 글(중복 신고 방지)
final blockedUsers = ValueNotifier<List<String>>([]);

/// 신고 사유 목록(PRD N15 미확정, 제안값).
const reportReasons = ['스팸·광고', '부적절한 사진', '욕설·비방', '허위 정보', '기타'];

/// 샘플 게시물의 작성자는 모두 같다(Figma 샘플). 내 글은 음수 번호.
String authorOf(int postId) => postId < 0 ? '나' : sampleAuthor;
const sampleAuthor = '김민지';

bool isPostVisible(int postId) =>
    !hiddenPosts.value.contains(postId) &&
    !blockedUsers.value.contains(authorOf(postId));

void hidePost(int postId) => hiddenPosts.value = {...hiddenPosts.value, postId};

void blockUser(String name) {
  if (!blockedUsers.value.contains(name)) {
    blockedUsers.value = [...blockedUsers.value, name];
  }
}

void unblockUser(String name) => blockedUsers.value = [
  for (final n in blockedUsers.value)
    if (n != name) n,
];

void resetModeration() {
  hiddenPosts.value = {};
  reportedPosts.clear();
  blockedUsers.value = [];
}
