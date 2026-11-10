import 'package:flutter/material.dart';

import '../widgets/lesson_scaffold.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LessonScaffold(
      title: 'About / team',
      route: '/about',
      nextLabel: 'Back to home',
      onNext: () => Navigator.pushReplacementNamed(context, '/'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        children: const [
          InfoCard(
            icon: Icons.school,
            title: 'Basic Electronics Laboratory',
            body:
                'Educational MVP: V-I characteristics of a PN junction diode. '
                'One-day Flutter app for Android with a PHP API and MySQL quiz result.',
          ),
          SizedBox(height: 10),
          InfoCard(
            icon: Icons.groups,
            title: 'Team / group',
            body: 'Team / Group: Basic Electronics Laboratory\n'
                'Team lead: (add name)\n'
                'Members: (add names)\n\n'
                'Prepared for submission to the course curator.',
          ),
          SizedBox(height: 10),
          InfoCard(
            icon: Icons.checklist,
            title: 'MVP scope',
            body:
                'Includes: lessons, Si vs Ge table, five MCQs, local score, Save result via PHP. '
                'Not included: login, live circuit simulation, Bluetooth, admin CMS, profiles, or notifications.',
          ),
        ],
      ),
    );
  }
}
