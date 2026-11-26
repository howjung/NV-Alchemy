/// 입력 범위(PRD 7, 제안값). 서버도 같은 값으로 검증한다.
const nicknameLength = (min: 2, max: 12);
const heightRange = (min: 100.0, max: 250.0); // cm
const weightRange = (min: 20.0, max: 300.0); // kg, 현재·목표 체중 공통

String? nicknameError(String input) {
  final length = input.trim().length;
  if (length < nicknameLength.min || length > nicknameLength.max) {
    return '닉네임은 ${nicknameLength.min}~${nicknameLength.max}자로 입력해 주세요.';
  }
  return null;
}

String? rangeError(
  String label,
  String input,
  ({double min, double max}) range,
  String unit,
) {
  final value = double.tryParse(input.trim());
  if (value == null || !value.isFinite) return '숫자를 입력해 주세요.';
  if (value < range.min || value > range.max) {
    return '$label 범위는 ${range.min.round()}~${range.max.round()}$unit로 입력해 주세요.';
  }
  return null;
}
