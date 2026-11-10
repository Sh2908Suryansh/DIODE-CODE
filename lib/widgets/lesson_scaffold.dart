import 'package:flutter/material.dart';

import '../theme.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(child: _NavigationContent(currentRoute: currentRoute)),
    );
  }
}

class _NavigationContent extends StatelessWidget {
  const _NavigationContent({required this.currentRoute});

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          color: LabColors.navy,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Virtual electronics lab',
                style: TextStyle(
                  color: LabColors.teal,
                  fontSize: 11,
                  letterSpacing: 0.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Diode V–I Lab',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Silicon & germanium analysis',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        _item(context, Icons.hub_outlined, 'PN junction', '/'),
        _item(context, Icons.compare_arrows, 'Si vs Ge', '/comparison'),
        _item(context, Icons.show_chart, 'V–I experiment', '/forward'),
        _item(context, Icons.quiz_outlined, 'Test your knowledge', '/quiz'),
      ],
    );
  }

  Widget _item(
      BuildContext context, IconData icon, String label, String route) {
    final selected = currentRoute == route;
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
        child: Material(
          borderRadius: BorderRadius.circular(10),
          clipBehavior: Clip.antiAlias,
          color: Colors.white,
          child: ListTile(
            leading: Icon(icon,
                color: selected ? LabColors.tealDark : LabColors.navy),
            title: Text(
              label,
              style: TextStyle(
                fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                color: LabColors.ink,
              ),
            ),
            selected: selected,
            selectedTileColor: LabColors.teal.withValues(alpha: 0.12),
            onTap: () {
              if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                Navigator.pop(context);
              }
              if (!selected) {
                Navigator.pushReplacementNamed(context, route);
              }
            },
          ),
        ));
  }
}

class LessonScaffold extends StatelessWidget {
  const LessonScaffold({
    super.key,
    required this.title,
    required this.route,
    required this.body,
    this.nextLabel,
    this.onNext,
    this.onBack,
  });

  final String title;
  final String route;
  final Widget body;
  final String? nextLabel;
  final VoidCallback? onNext;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      drawer: wide ? null : AppDrawer(currentRoute: route),
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Row(
        children: [
          if (wide)
            Container(
              width: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    right: BorderSide(
                        color: LabColors.navy.withValues(alpha: 0.10))),
              ),
              child: SafeArea(
                  top: false, child: _NavigationContent(currentRoute: route)),
            ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1440),
                        child: body),
                  ),
                ),
                if (onNext != null || onBack != null)
                  SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      child: Row(
                        children: [
                          if (onBack != null)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: onBack,
                                child: const Text('Back'),
                              ),
                            ),
                          if (onBack != null && onNext != null)
                            const SizedBox(width: 12),
                          if (onNext != null)
                            Expanded(
                              flex: 2,
                              child: ElevatedButton(
                                onPressed: onNext,
                                child: Text(nextLabel ?? 'Next'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    required this.title,
    required this.body,
    this.icon,
    this.accent,
  });

  final String title;
  final String body;
  final IconData? icon;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final color = accent ?? LabColors.teal;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: LabColors.navy),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: LabColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    body,
                    style: const TextStyle(
                      height: 1.45,
                      color: LabColors.ink,
                      fontSize: 14.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
