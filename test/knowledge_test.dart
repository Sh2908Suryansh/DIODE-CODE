import 'package:vi_diode_lab/models/lab_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_diode_lab/main.dart';
import 'package:vi_diode_lab/screens/quiz_screen.dart';
import 'package:vi_diode_lab/theme.dart';

void main() {
  setUp(() => LabSession.instance.reset());
  testWidgets(
      'quiz checks answers, scores a mixed attempt, reviews and retries',
      (tester) async {
    await tester.pumpWidget(
        MaterialApp(theme: buildLabTheme(), home: const QuizScreen()));
    await tester.tap(find.text('Start quiz'));
    await tester.pumpAndSettle();
    expect(
        tester
            .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Check answer'))
            .onPressed,
        isNull);
    const answers = [
      'A metallic wire',
      'Anode to positive, cathode to negative',
      '0.7 V',
      'Germanium',
      'It increases rapidly',
      'To limit current',
      'Ammeter in series, voltmeter across the diode',
      'It becomes wider'
    ];
    for (var i = 0; i < answers.length; i++) {
      await tester.tap(find.text(answers[i]));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Check answer'));
      await tester.tap(find.text('Check answer'));
      await tester.pumpAndSettle();
      expect(find.text(i == 0 ? 'Keep learning' : 'Correct!'), findsOneWidget);
      final next =
          find.text(i == answers.length - 1 ? 'See results' : 'Next question');
      await tester.scrollUntilVisible(next, 180);
      await tester.tap(next);
      await tester.pumpAndSettle();
    }
    expect(find.text('7 / 8'), findsOneWidget);
    expect(find.text('Review your answers'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 8'), findsOneWidget);
    expect(
        tester
            .widget<ElevatedButton>(
                find.widgetWithText(ElevatedButton, 'Check answer'))
            .onPressed,
        isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('knowledge section opens through the phone navigation drawer',
      (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DiodeLabApp());
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Test your knowledge'));
    await tester.pumpAndSettle();
    expect(find.text('Put your diode knowledge to the test'), findsOneWidget);
    await tester.tap(find.text('Start quiz'));
    await tester.pumpAndSettle();
    expect(find.text('Question 1 of 8'), findsOneWidget);
    await tester.tap(find.text('A depletion region'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Check answer'));
    await tester.tap(find.text('Check answer'));
    await tester.pumpAndSettle();
    expect(find.text('Correct!'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
