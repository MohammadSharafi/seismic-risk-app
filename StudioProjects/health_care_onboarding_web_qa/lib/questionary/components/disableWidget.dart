import 'package:flutter/cupertino.dart';

class Disable extends StatelessWidget {
  final bool disabled;
  final Widget child;

  const Disable({
    Key? key,
    required this.disabled,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disabled,
      child: Opacity(
        opacity: disabled ? 0.5 : 1.0, // Still using opacity for visual feedback
        child: child,
      ),
    );
  }
}
