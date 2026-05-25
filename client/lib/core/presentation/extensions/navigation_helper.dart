import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

extension NavigationHelper on BuildContext {
  void safePop() {
    final route = ModalRoute.of(this);
    final isAnimating = route?.animation?.isCompleted == false;

    if (!isAnimating && mounted && canPop()) {
      pop();
    }
  }
}
