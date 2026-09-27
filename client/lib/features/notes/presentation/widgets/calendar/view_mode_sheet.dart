import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/features/notes/domain/calendar_view_mode.dart';
import 'package:ink/features/notes/presentation/extensions/calendar_view_mode_ui_extension.dart';
import 'package:ink/features/notes/presentation/notifiers/ui_state.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class ViewModeSheet extends ConsumerWidget {
  const ViewModeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(calendarViewModeStateProvider);

    return BottomSheetLayout(
      header: Text(
        context.t.calendar.view,
        style: context.textTheme.titleLarge,
      ),
      children: [
        ...CalendarViewMode.values.map(
          (mode) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              mode.icon,
              size: AppSize.iconLarge,
              color: viewMode == mode
                  ? context.colorScheme.primary
                  : context.colorScheme.onSurface,
            ),
            title: Text(
              mode.label(t),
              style: context.textTheme.titleMedium?.copyWith(
                color: viewMode == mode
                    ? context.colorScheme.primary
                    : context.theme.hintColor,
              ),
            ),
            trailing: viewMode == mode
                ? Icon(
                    Icons.check,
                    size: AppSize.iconMedium,
                    color: context.colorScheme.primary,
                  )
                : null,
            onTap: () =>
                ref.read(calendarViewModeStateProvider.notifier).mode = mode,
          ),
        ),
      ],
    );
  }
}
