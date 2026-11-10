import 'package:vi_diode_lab/models/lab_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vi_diode_lab/screens/bias_screen.dart';
import 'package:vi_diode_lab/theme.dart';

void main() {
  setUp(() => LabSession.instance.reset());
  for (final width in [360.0, 1440.0]) {
    testWidgets('experiment works at $width pixels', (tester) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(MaterialApp(
          theme: buildLabTheme(), home: const BiasScreen(forward: true)));
      // Let the framework report full layout diagnostics.
      await tester.tap(find.text('Germanium (Ge)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reverse'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Reverse characteristic'), 180,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Reverse characteristic'), findsOneWidget);
      // Let the framework report full layout diagnostics.
      await tester.scrollUntilVisible(find.text('Circuit & procedure'), 180,
          scrollable: find.byType(Scrollable).first);
      await Scrollable.ensureVisible(
          tester.element(find.text('Circuit & procedure')),
          alignment: 0.5);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Circuit & procedure'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('Reverse-bias circuit'), 120,
          scrollable: find.byType(Scrollable).first);
      expect(find.text('Reverse-bias circuit'), findsOneWidget);
      // Let the framework report full layout diagnostics.
    });
  }
}
