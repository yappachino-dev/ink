import 'package:flutter/material.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';

extension AppSnackBarExtension on BuildContext {
  void showSnackbarError(String message) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.error,
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onError,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.smRadius,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void showSnackBarInfo(String message) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.surfaceContainer,
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.smRadius,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void showSnackBarSuccess(String message) {
    ScaffoldMessenger.of(this)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          backgroundColor: colorScheme.primary,
          content: Text(
            message,
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimary,
            ),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.smRadius,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
