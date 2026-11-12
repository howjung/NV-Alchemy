import 'package:flutter/material.dart';

class AppScreenFrame extends StatelessWidget {
  const AppScreenFrame({
    required this.figmaName,
    this.child = const SizedBox.expand(),
    super.key,
  });

  final String figmaName;
  final Widget child;

  static const Size figmaSize = Size(402, 874);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 402),
          child: SizedBox.expand(
            child: Semantics(label: figmaName, child: child),
          ),
        ),
      ),
    );
  }
}
