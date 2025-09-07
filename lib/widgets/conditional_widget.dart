import 'package:flutter/material.dart';

class ConditionalWidget extends StatelessWidget {
  const ConditionalWidget({
    super.key,
    required this.condition,
    required this.child,
    this.elseChild,
  });

  final bool condition;
  final Widget child;
  final Widget? elseChild;

  @override
  Widget build(BuildContext context) {
    return condition ? child : elseChild ?? const SizedBox.shrink();
  }
}
