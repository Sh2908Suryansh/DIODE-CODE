import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_diode_lab/models/lab_session.dart';
import 'package:vi_diode_lab/screens/bias_screen.dart';
import 'package:vi_diode_lab/screens/quiz_screen.dart';
import 'package:vi_diode_lab/screens/comparison_screen.dart';
import 'package:vi_diode_lab/theme.dart';

void main() {
  setUp(() => LabSession.instance.reset());
  test('progress round-trips and CSV retains signed SI values', () {
    final s = LabSession.instance;
    s.voltage = .777;
    s.silicon = false;
    s.forward = false;
    s.combined = true;
    s.quiz = {
      'answers': [1, null],
      'index': 1
    };
    s.observations.add(const Observation(
        silicon: false, forward: false, volts: -5, amps: -4.4e-6));
    final data = jsonDecode(jsonEncode(s.toJson())) as Map<String, dynamic>;
    s.reset();
    s.restore(data);
    expect(s.voltage, .777);
    expect(s.silicon, false);
    expect(s.forward, false);
    expect(s.combined, true);
    expect(s.quiz['index'], 1);
    expect(s.csv(), contains('Germanium,Reverse,-5.0,-0.0000044,25'));
  });
  for (final width in [360.0, 1440.0]) {
    testWidgets('comparison fits $width without horizontal scrolling',
        (t) async {
      t.view.physicalSize = Size(width, 1100);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(
          MaterialApp(theme: buildLabTheme(), home: const ComparisonScreen()));
      expect(find.byType(SingleChildScrollView), findsNothing);
      expect(t.takeException(), isNull);
    });
    testWidgets('exact input, observations and signed graph at $width',
        (t) async {
      t.view.physicalSize = Size(width, 1100);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.resetPhysicalSize);
      addTearDown(t.view.resetDevicePixelRatio);
      await t.pumpWidget(MaterialApp(
          theme: buildLabTheme(), home: const BiasScreen(forward: true)));
      await t.scrollUntilVisible(find.byKey(const Key('exact-voltage')), 180,
          scrollable: find.byType(Scrollable).first);
      await t.enterText(find.byKey(const Key('exact-voltage')), '2');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
      expect(find.text('Enter a number from 0 to 1 V.'), findsOneWidget);
      expect(LabSession.instance.voltage, .65);
      await t.enterText(find.byKey(const Key('exact-voltage')), '.777');
      await t.testTextInput.receiveAction(TextInputAction.done);
      await t.pumpAndSettle();
      expect(LabSession.instance.voltage, .777);
      await t.scrollUntilVisible(find.text('Record reading'), 120,
          scrollable: find.byType(Scrollable).first);
      await Scrollable.ensureVisible(t.element(find.text('Record reading')),
          alignment: 0.5);
      await t.pumpAndSettle();
      await t.tap(find.text('Record reading'));
      await t.pumpAndSettle();
      expect(LabSession.instance.observations.length, 1);
      expect(LabSession.instance.observations.first.volts, .777);
      await t.scrollUntilVisible(find.text('Combined signed view'), 180,
          scrollable: find.byType(Scrollable).first);
      await Scrollable.ensureVisible(
          t.element(find.text('Combined signed view')),
          alignment: 0.5);
      await t.pumpAndSettle();
      await t.tap(find.text('Combined signed view'));
      await t.pumpAndSettle();
      expect(LabSession.instance.combined, true);
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(MaterialApp(
          theme: buildLabTheme(), home: const BiasScreen(forward: true)));
      expect(LabSession.instance.voltage, .777);
      expect(LabSession.instance.observations.length, 1);
      expect(t.takeException(), isNull);
    });
  }
  testWidgets('quiz resumes after leaving the screen', (t) async {
    await t.pumpWidget(
        MaterialApp(theme: buildLabTheme(), home: const QuizScreen()));
    await t.tap(find.text('Start quiz'));
    await t.pumpAndSettle();
    await t.tap(find.text('A depletion region'));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('Check answer'));
    await t.tap(find.text('Check answer'));
    await t.pumpAndSettle();
    await t.scrollUntilVisible(find.text('Next question'), 150,
        scrollable: find.byType(Scrollable).first);
    await t.tap(find.text('Next question'));
    await t.pumpAndSettle();
    await t.pumpWidget(const SizedBox());
    await t.pumpWidget(
        MaterialApp(theme: buildLabTheme(), home: const QuizScreen()));
    expect(find.text('Question 2 of 8'), findsOneWidget);
  });
}
