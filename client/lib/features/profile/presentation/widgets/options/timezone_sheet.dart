import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ink/core/config/user_config.dart';
import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class TimezoneSheet extends ConsumerStatefulWidget {
  const TimezoneSheet({super.key});

  @override
  ConsumerState<TimezoneSheet> createState() => _TimezoneSheetState();
}

class _TimezoneSheetState extends ConsumerState<TimezoneSheet> {
  /// Read by `build`, so it cannot be `late`: the first frame happened before
  /// the sheet threw, which is the crash this replaces.
  String _selected = _timezones.first;

  @override
  void initState() {
    super.initState();

    final stored = ref.read(userPreferencesProvider).selectedTimezone;
    if (stored != null && _timezones.contains(stored)) _selected = stored;
  }

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      header: Text(
        context.t.profile.settings.timezone,
        style: context.textTheme.titleLarge,
      ),
      children: [
        Container(
          decoration: BoxDecoration(
            color: context.ink.surface,
            borderRadius: AppRadius.mdRadius,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selected,
              isExpanded: true,
              borderRadius: AppRadius.mdRadius,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: context.theme.hintColor,
              ),
              style: context.textTheme.titleMedium,
              items: _timezones
                  .map(
                    (tz) => DropdownMenuItem(
                      value: tz,
                      child: Text(context.t['timezones.$tz'].toString()),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selected = val);
              },
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        FilledButton(
          onPressed: () {
            unawaited(
              ref.read(userPreferencesProvider).setSelectedTimezone(_selected),
            );
            Navigator.pop(context, _selected);
          },
          style: FilledButton.styleFrom(
            foregroundColor: context.colorScheme.surface,
            minimumSize: const Size(double.infinity, 48),
            shape: const RoundedRectangleBorder(
              borderRadius: AppRadius.lgRadius,
            ),
          ),
          child: Text(
            context.t.common.save,
            style: context.textTheme.labelLarge?.copyWith(
              color: context.colorScheme.surface,
            ),
          ),
        ),
      ],
    );
  }
}

/// IANA zone ids, with a display label in the catalogue. The previous list was
/// country names that had no translation entry at all, so every option rendered
/// as a blank row.
const List<String> _timezones = [
  'utc',
  'london',
  'warsaw',
  'newYork',
  'losAngeles',
  'tokyo',
];
