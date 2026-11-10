import 'package:vi_diode_lab/models/lab_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_diode_lab/main.dart';

void main() {
  setUp(() => LabSession.instance.reset());
  testWidgets('home shows experiment title and glossary', (tester) async {
    await tester.pumpWidget(const DiodeLabApp());
    expect(find.textContaining('V–I Characteristics'), findsWidgets);
    expect(find.text('Experiment outcomes'), findsOneWidget);
    expect(find.text('PN junction structure & function'), findsOneWidget);
  });

  testWidgets('experiment flow shows comparison and virtual measurement',
      (tester) async {
    await tester.pumpWidget(const DiodeLabApp());

    await tester.tap(find.text('Compare Si & Ge'));
    await tester.pumpAndSettle();
    expect(find.text('~ 0.7 V'), findsOneWidget);
    expect(find.text('~ 0.3 V'), findsOneWidget);

    await tester.tap(find.text('Open V–I experiment'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Virtual measurement'), 300,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Virtual measurement'), findsOneWidget);
    expect(find.text('Silicon (Si)'), findsOneWidget);
    expect(find.text('Germanium (Ge)'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Reverse'), -250,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Reverse'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Reverse characteristic'), 250,
        scrollable: find.byType(Scrollable).first);
    expect(find.text('Reverse characteristic'), findsOneWidget);
  });
}
