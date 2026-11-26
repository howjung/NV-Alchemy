import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const _danger = AppTheme.danger;
const _soft = Color(0xFFEDF3EF);

/// 확인 팝업 (Figma POP-01/02/05). 확인을 누르면 true, 그 외에는 false.
Future<bool> showConfirmPopup(
  BuildContext context, {
  required String title,
  required String confirmLabel,
  String cancelLabel = '취소',
  String? message,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: .4),
    builder: (context) => Dialog(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: SizedBox(
        width: 298,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 34, 15, 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (message != null) ...[
                const SizedBox(height: 10),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 14),
                ),
              ],
              SizedBox(height: message == null ? 30 : 20),
              Row(
                children: [
                  Expanded(
                    child: _PopupButton(
                      label: cancelLabel,
                      background: _soft,
                      foreground: AppTheme.primary,
                      onPressed: () => Navigator.pop(context, false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PopupButton(
                      label: confirmLabel,
                      background: _danger,
                      foreground: Colors.white,
                      onPressed: () => Navigator.pop(context, true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
  return confirmed ?? false;
}

/// 토스트 (Figma Overlay/…토스트). 글자 폭에 맞춘 알약 모양으로, 짧으면 2초
/// 길면(12자 초과) 4초 동안 보인다.
/// [bottom]은 화면 아래에서 띄우는 거리다.
void showAppToast(BuildContext context, String message, {double bottom = 24}) {
  const style = TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
  // 앱 글꼴(테마)로 재야 실제 글자 폭과 같아 줄이 꺾이지 않는다.
  final measured = Theme.of(context).textTheme.bodyMedium!.merge(style);
  final painter = TextPainter(
    text: TextSpan(text: message, style: measured),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
  )..layout();
  final textWidth = painter.width;
  painter.dispose();
  // 창 폭이 아니라 이 화면이 실제로 차지하는 폭을 기준으로 가운데에 둔다.
  final side = (((context.size?.width ?? 402) - textWidth - 44) / 2).clamp(
    16.0,
    double.infinity,
  );
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center, style: style),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.fromLTRB(side, 0, side, bottom),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
        duration: Duration(seconds: message.length > 12 ? 4 : 2),
        backgroundColor: AppTheme.primary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
}

class _PopupButton extends StatelessWidget {
  const _PopupButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 46,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class AppMenuItem<T> {
  const AppMenuItem(this.value, this.label, {this.danger = false});

  final T value;
  final String label;
  final bool danger;
}

/// 드롭다운 메뉴 (Figma Overlay/…드롭다운). [child]를 누르면 그 아래에 열린다.
/// [selected]와 같은 값의 항목은 강조해서 보여준다.
class AppMenu<T> extends StatelessWidget {
  const AppMenu({
    required this.items,
    required this.child,
    this.selected,
    this.onSelected,
    this.width = 132,
    this.offset = Offset.zero,
    this.tooltip,
    super.key,
  });

  final List<AppMenuItem<T>> items;
  final Widget child;
  final T? selected;
  final ValueChanged<T>? onSelected;
  final double width;
  final Offset offset;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => PopupMenuButton<T>(
    tooltip: tooltip,
    onSelected: onSelected,
    position: PopupMenuPosition.under,
    offset: offset,
    color: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    clipBehavior: Clip.antiAlias,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: AppTheme.border),
    ),
    constraints: BoxConstraints.tightFor(width: width),
    menuPadding: const EdgeInsets.symmetric(vertical: 6),
    itemBuilder: (_) => [
      for (final item in items)
        PopupMenuItem<T>(
          value: item.value,
          height: 44,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: 44,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: item.value == selected ? _soft : null,
            child: Semantics(
              selected: item.value == selected,
              child: Text(
                item.label,
                style: TextStyle(
                  color: item.danger ? _danger : AppTheme.primary,
                  fontSize: 15,
                  fontWeight: item.value == selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
    ],
    child: child,
  );
}
