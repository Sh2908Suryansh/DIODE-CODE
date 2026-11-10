import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/lesson_scaffold.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const glossary = [
    (
      'Anode',
      'P-side terminal; connected to positive in forward bias.',
      Icons.add_circle_outline
    ),
    (
      'Cathode',
      'N-side terminal, identified by the bar on the diode symbol.',
      Icons.remove_circle_outline
    ),
    (
      'Forward bias',
      'Lowers the junction barrier and allows a large current to flow.',
      Icons.bolt_outlined
    ),
    (
      'Reverse bias',
      'Widens the depletion region, leaving only a tiny leakage current.',
      Icons.block_outlined
    ),
    (
      'Knee voltage',
      'Voltage where current starts rising rapidly: about 0.7 V for Si and 0.3 V for Ge.',
      Icons.turn_sharp_right
    ),
    (
      'Depletion region',
      'Thin region around the junction with almost no mobile charge carriers.',
      Icons.blur_circular
    ),
    (
      'Leakage current',
      'Small minority-carrier current that flows under reverse bias.',
      Icons.water_drop_outlined
    ),
    (
      'Breakdown voltage',
      'Reverse voltage where current rises sharply and an ordinary diode may be damaged.',
      Icons.warning_amber_rounded
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'PN junction structure & function',
      route: '/',
      nextLabel: 'Compare Si & Ge',
      onNext: () => Navigator.pushReplacementNamed(context, '/comparison'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 10),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [LabColors.navyDeep, Color(0xFF123F68)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: LabColors.navy.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 10))
              ],
            ),
            child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('VIRTUAL ELECTRONICS LAB',
                      style: TextStyle(
                          color: LabColors.teal,
                          fontSize: 12,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w800)),
                  SizedBox(height: 10),
                  Text('V–I Characteristics of a P–N Junction Diode',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          height: 1.15,
                          fontWeight: FontWeight.w900)),
                  SizedBox(height: 10),
                  Text(
                      'Inspect the junction, compare semiconductor materials, and operate a virtual forward/reverse-bias circuit.',
                      style: TextStyle(
                          color: Colors.white70, fontSize: 16, height: 1.45)),
                ]),
          ),
          const SizedBox(height: 14),
          Card(
            color: LabColors.navy,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Experiment outcomes',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 4),
                    const Text(
                        'At the end of the experiment, the student should be able to:',
                        style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 13),
                    ...const [
                      'Explain the structure of a P–N junction diode',
                      'Explain the function of a P–N junction diode',
                      'Explain forward and reverse characteristics of a silicon diode',
                      'Explain forward and reverse characteristics of a germanium diode',
                    ].map((text) => Padding(
                          padding: const EdgeInsets.only(bottom: 9),
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: LabColors.teal, size: 20),
                                const SizedBox(width: 9),
                                Expanded(
                                    child: Text(text,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            height: 1.35))),
                              ]),
                        )),
                  ]),
            ),
          ),
          const SizedBox(height: 14),
          const _JunctionVisual(),
          const SizedBox(height: 14),
          LayoutBuilder(builder: (context, constraints) {
            final tileWidth = constraints.maxWidth >= 700
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(spacing: 12, runSpacing: 12, children: [
              SizedBox(
                  width: tileWidth,
                  child: const _FunctionTile(
                      icon: Icons.bolt,
                      title: 'Forward-biased function',
                      text:
                          'Positive to P and negative to N reduces the barrier. Majority carriers cross the junction and current rises rapidly after the knee voltage.',
                      color: LabColors.silicon)),
              SizedBox(
                  width: tileWidth,
                  child: const _FunctionTile(
                      icon: Icons.block,
                      title: 'Reverse-biased function',
                      text:
                          'Negative to P and positive to N widens the depletion region. The diode blocks current except for a small minority-carrier leakage.',
                      color: LabColors.germanium)),
            ]);
          }),
          const SizedBox(height: 24),
          const Text('Glossary',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: LabColors.navy)),
          const SizedBox(height: 4),
          const Text('Terms used in the circuit and V–I graph.',
              style: TextStyle(color: LabColors.muted)),
          const SizedBox(height: 12),
          LayoutBuilder(builder: (context, constraints) {
            final itemWidth = constraints.maxWidth >= 700
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;
            return Wrap(spacing: 12, runSpacing: 12, children: [
              for (final item in glossary)
                SizedBox(
                    width: itemWidth,
                    child: Card(
                        child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                              color: LabColors.teal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10)),
                          child: Icon(item.$3, color: LabColors.navy)),
                      title: Text(item.$1,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: LabColors.navy)),
                      subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(item.$2,
                              style: const TextStyle(height: 1.35))),
                    ))),
            ]);
          }),
        ],
      ),
    );
  }
}

class _JunctionVisual extends StatelessWidget {
  const _JunctionVisual();

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Structure of a P–N junction',
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: LabColors.navy)),
            const SizedBox(height: 6),
            const Text(
                'Joining P-type and N-type material forms a carrier-free depletion region and an internal electric field.',
                style: TextStyle(color: LabColors.muted, height: 1.4)),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                height: 135,
                child: Row(children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: const Color(0xFFFFE4E6),
                      child: const _RegionLabel(
                          title: 'P-type',
                          subtitle: 'Majority carriers: holes',
                          carriers: 'h+   h+   h+'),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      color: const Color(0xFFE2E8F0),
                      child: const Center(
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: Text('DEPLETION',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: LabColors.muted)),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 5,
                    child: Container(
                      color: const Color(0xFFDBEAFE),
                      child: const _RegionLabel(
                          title: 'N-type',
                          subtitle: 'Majority carriers: electrons',
                          carriers: 'e−   e−   e−'),
                    ),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 10),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Anode (P)',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  Text('Junction barrier',
                      style: TextStyle(color: LabColors.muted)),
                  Text('Cathode (N)',
                      style: TextStyle(fontWeight: FontWeight.w700))
                ]),
          ]),
        ),
      );
}

class _RegionLabel extends StatelessWidget {
  const _RegionLabel(
      {required this.title, required this.subtitle, required this.carriers});
  final String title;
  final String subtitle;
  final String carriers;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(8),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: LabColors.navy)),
          const SizedBox(height: 5),
          Text(subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: LabColors.muted)),
          const SizedBox(height: 10),
          Text(carriers,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, color: LabColors.navy)),
        ]),
      );
}

class _FunctionTile extends StatelessWidget {
  const _FunctionTile(
      {required this.icon,
      required this.title,
      required this.text,
      required this.color});
  final IconData icon;
  final String title;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.25))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: LabColors.navy)),
                const SizedBox(height: 5),
                Text(text,
                    style: const TextStyle(height: 1.45, color: LabColors.ink)),
              ])),
        ]),
      );
}
