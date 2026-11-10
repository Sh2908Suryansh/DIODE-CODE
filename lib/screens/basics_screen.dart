import 'package:flutter/material.dart';

import '../widgets/lesson_scaffold.dart';

class BasicsScreen extends StatelessWidget {
  const BasicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'Diode basics',
      route: '/basics',
      nextLabel: 'Forward bias',
      onBack: () => Navigator.pushReplacementNamed(context, '/'),
      onNext: () => Navigator.pushReplacementNamed(context, '/forward'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        children: const [
          InfoCard(
            icon: Icons.architecture,
            title: 'PN junction structure',
            body:
                'A PN junction diode is formed by joining P-type and N-type semiconductor. '
                'The P-region has majority holes; the N-region has majority electrons. '
                'The P-side terminal is the anode; the N-side terminal is the cathode.',
          ),
          SizedBox(height: 10),
          InfoCard(
            icon: Icons.blur_circular,
            title: 'Depletion region',
            body:
                'When the materials are joined, electrons and holes near the junction recombine. '
                'This leaves uncovered ions and forms a depletion region (depletion layer) '
                'with a built-in barrier potential that opposes further diffusion.',
          ),
          SizedBox(height: 10),
          InfoCard(
            icon: Icons.settings_input_component,
            title: 'Function',
            body:
                'The diode permits a significant current when it is forward biased (after the knee voltage) '
                'and blocks most current when it is reverse biased. That one-way behaviour is the basis '
                'of the V-I characteristics experiment.',
          ),
          SizedBox(height: 10),
          InfoCard(
            icon: Icons.cable,
            title: 'Terminals',
            body:
                'Anode: P-side, connected toward the more positive supply in forward bias. '
                'Cathode: N-side, marked by the bar on the diode symbol. Current (conventional) '
                'flows from anode to cathode in forward bias.',
          ),
        ],
      ),
    );
  }
}
