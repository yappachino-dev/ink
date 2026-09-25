import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/theme/tokens.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class TimezoneSheet extends StatefulWidget {
  const TimezoneSheet({super.key});

  @override
  State<TimezoneSheet> createState() => _TimezoneSheetState();
}

class _TimezoneSheetState extends State<TimezoneSheet> {
  late String _selected;

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
              padding: const EdgeInsets.symmetric(horizontal: 16),
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

        const SizedBox(height: 16),

        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
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

const List<String> _timezones = [
  'ukraine',
  'poland',
  'germany',
  'usaNy',
  'usaLa',
  'greatBritain',
];
