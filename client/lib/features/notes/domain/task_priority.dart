import 'package:flutter/material.dart';
import 'package:ink/i18n/strings.g.dart';

enum TaskPriority { none, low, medium, high }

extension TaskPriorityExt on TaskPriority {
  String label(Translations t) {
    switch (this) {
      case TaskPriority.none:
        return t.note.priority.none;
      case TaskPriority.low:
        return t.note.priority.low;
      case TaskPriority.medium:
        return t.note.priority.medium;
      case TaskPriority.high:
        return t.note.priority.high;
    }
  }

  Color get color {
    switch (this) {
      case TaskPriority.none:
        return const Color(0xFFBDBDBD);
      case TaskPriority.low:
        return const Color(0xFF4CAF50);
      case TaskPriority.medium:
        return const Color(0xFFFFA726);
      case TaskPriority.high:
        return const Color(0xFFEF5350);
    }
  }
}
