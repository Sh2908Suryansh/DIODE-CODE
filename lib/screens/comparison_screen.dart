import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/lesson_scaffold.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  static const rows = [
    ['Property', 'Silicon (Si)', 'Germanium (Ge)'],
    ['Knee / cut-in voltage', '~ 0.7 V', '~ 0.3 V'],
    ['Reverse leakage', 'Lower', 'Higher'],
    ['Starts conducting', 'Later (higher Vf)', 'Earlier (lower Vf)'],
    [
      'Typical use',
      'Most general-purpose diodes',
      'Special / low-voltage cases'
    ],
    ['Temperature sensitivity', 'More stable leakage', 'Leakage rises faster'],
  ];

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Si vs Ge',
      route: '/comparison',
      nextLabel: 'Open V–I experiment',
      onBack: () => Navigator.pushReplacementNamed(context, '/'),
      onNext: () => Navigator.pushReplacementNamed(context, '/forward'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        children: [
          const InfoCard(
            icon: Icons.table_view,
            title: 'Material comparison',
            body:
                'The semiconductor material changes the cut-in voltage, leakage and temperature response. '
                'That is why the two forward V–I curves do not overlap.',
          ),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxWidth < 620) {
              return Column(children: [
                for (var i = 1; i < rows.length; i++)
                  Card(
                      child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(rows[i][0],
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 10),
                                Text('Si: ${rows[i][1]}'),
                                const SizedBox(height: 6),
                                Text('Ge: ${rows[i][2]}'),
                              ])))
              ]);
            }
            return Card(
                clipBehavior: Clip.antiAlias,
                child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(1.2),
                      1: FlexColumnWidth(),
                      2: FlexColumnWidth()
                    },
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    children: [
                      for (var i = 0; i < rows.length; i++)
                        TableRow(
                            decoration: BoxDecoration(
                                color: i == 0
                                    ? LabColors.navy
                                    : i.isOdd
                                        ? const Color(0xFFF1F8FA)
                                        : Colors.white),
                            children: [
                              for (var j = 0; j < 3; j++)
                                Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Text(rows[i][j],
                                        style: TextStyle(
                                            color: i == 0
                                                ? Colors.white
                                                : LabColors.ink,
                                            fontWeight: i == 0 || j == 0
                                                ? FontWeight.w700
                                                : FontWeight.w400,
                                            height: 1.4)))
                            ])
                    ]));
          }),
          const SizedBox(height: 12),
          const Text('Where they are used',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: LabColors.navy)),
          const SizedBox(height: 10),
          LayoutBuilder(builder: (context, constraints) {
            final cardWidth = constraints.maxWidth >= 700
                ? (constraints.maxWidth - 10) / 2
                : constraints.maxWidth;
            return Wrap(spacing: 10, runSpacing: 10, children: [
              SizedBox(
                  width: cardWidth,
                  child: const InfoCard(
                      icon: Icons.memory,
                      accent: LabColors.silicon,
                      title: 'Silicon diode',
                      body:
                          'Rectifiers, switching circuits, power supplies, protection circuits and most general-purpose electronics. It is preferred for low leakage and good thermal stability.')),
              SizedBox(
                  width: cardWidth,
                  child: const InfoCard(
                      icon: Icons.sensors,
                      accent: LabColors.germanium,
                      title: 'Germanium diode',
                      body:
                          'Low-level signal detection, RF detector circuits and vintage audio equipment. Its low forward drop helps with weak signals.')),
            ]);
          }),
          const SizedBox(height: 12),
          const InfoCard(
              icon: Icons.science_outlined,
              title: 'Expected experiment result',
              body:
                  'Forward: the Ge curve turns upward near 0.3 V; Si near 0.6–0.7 V. Reverse: both currents stay small before breakdown, but Ge leakage is much higher. Actual values depend on device current and temperature.'),
        ],
      ),
    );
  }
}
