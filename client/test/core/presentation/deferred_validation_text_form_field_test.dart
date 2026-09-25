import 'package:flutter_test/flutter_test.dart';
import 'package:ink/core/presentation/form_fields/deferred_validation_text_form_field.dart';
import 'package:material_ui/material_ui.dart';

Widget _wrap(TextEditingController controller) => MaterialApp(
  home: Scaffold(
    body: Column(
      children: [
        DeferredValidationTextFormField(
          controller: controller,
          validator: (v) =>
              v != null && v.contains('@') ? null : 'invalid email',
        ),
        // A second focusable node so we can move focus away from the field.
        const TextField(),
      ],
    ),
  ),
);

void main() {
  testWidgets('does not show error while the user is still typing', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(
      find.byType(DeferredValidationTextFormField),
      'nope',
    );
    await tester.pump();

    expect(find.text('invalid email'), findsNothing);
  });

  testWidgets('shows the error once focus leaves the field', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(
      find.byType(DeferredValidationTextFormField),
      'not-an-email',
    );
    // Move focus to the other field: the user has "finished" this one.
    await tester.tap(find.byType(TextField).last);
    await tester.pumpAndSettle();

    expect(find.text('invalid email'), findsOneWidget);
  });

  testWidgets('re-validates live after activation so fixes clear errors', (
    tester,
  ) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(controller));

    await tester.enterText(
      find.byType(DeferredValidationTextFormField),
      'not-an-email',
    );
    await tester.tap(find.byType(TextField).last);
    await tester.pumpAndSettle();
    expect(find.text('invalid email'), findsOneWidget);

    await tester.enterText(
      find.byType(DeferredValidationTextFormField),
      'a@b.co',
    );
    await tester.pump();

    expect(find.text('invalid email'), findsNothing);
  });
}
