import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

extension NavigationHelper on BuildContext {
  void safePop() {
    final route = ModalRoute.of(this);
    final isAnimating = route?.animation?.isCompleted == false;

    if (!isAnimating && mounted && canPop()) {
      pop();
    }
  }
}
