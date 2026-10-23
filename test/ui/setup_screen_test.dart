import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysecrets/ui/screens/setup_screen.dart';

void main() {
  testWidgets('setup screen requires strong passphrase, matching confirm and data-loss ack',
      (tester) async {
    var submitted = <String>[];
    await tester.pumpWidget(MaterialApp(
      home: SetupScreen(
        onSetup: (p) async {
          submitted.add(p);
        },
      ),
    ));

    await tester.enterText(find.byType(TextFormField).at(0), 'short');
    await tester.enterText(find.byType(TextFormField).at(1), 'short');
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(find.text('Use at least 12 characters'), findsWidgets);
    expect(submitted, isEmpty);

    final good = 'a much stronger master 42!';
    await tester.enterText(find.byType(TextFormField).at(0), good);
    await tester.enterText(find.byType(TextFormField).at(1), good);
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(submitted, isEmpty,
        reason: 'must refuse until data-loss checkbox is accepted');

    await tester.tap(find.byType(CheckboxListTile));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(submitted, [good]);
  });
}
