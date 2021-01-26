import 'package:flutter/material.dart';

class AutoHideKeyboard extends StatelessWidget {
  final Widget child;

  const AutoHideKeyboard({
    @required this.child,
  }) : assert(child != null);

  @override
  Widget build(BuildContext context) {
    void hideKeyboard() {
      var currentFocus = FocusScope.of(context);
      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }
    }

    ;
    return GestureDetector(
      onTap: hideKeyboard,
      // onTapDown: (_) => hideKeyboard(),
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}
