import 'package:ink/core/presentation/theme/theme_extensions.dart';
import 'package:ink/core/presentation/widgets/bottom_sheet.dart';
import 'package:ink/i18n/strings.g.dart';
import 'package:material_ui/material_ui.dart';

class WidgetsSheet extends StatefulWidget {
  const WidgetsSheet({super.key});

  @override
  State<WidgetsSheet> createState() => _WidgetsSheetState();
}

class _WidgetsSheetState extends State<WidgetsSheet> {
  final List<({String title, bool enabled})> _widgets = [
    (title: 'tasks', enabled: true),
    (title: 'calendar', enabled: false),
    (title: 'progress', enabled: false),
  ];

  @override
  Widget build(BuildContext context) {
    return BottomSheetLayout(
      header: Text(
        context.t.profile.settings.widgets,
        style: context.textTheme.titleLarge,
      ),
      children: [
        ..._widgets.asMap().entries.map(
          (entry) => SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(
              context.t['widgets.${entry.value.title}'].toString(),
              style: context.textTheme.titleMedium,
            ),
            value: entry.value.enabled,
            activeThumbColor: context.colorScheme.primary,
            activeTrackColor: context.colorScheme.surface,
            trackOutlineColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return context.colorScheme.primary;
              }
              return null;
            }),

            onChanged: (val) {
              setState(() {
                _widgets[entry.key] = (
                  title: entry.value.title,
                  enabled: val,
                );
              });
            },
          ),
        ),
      ],
    );
  }
}
