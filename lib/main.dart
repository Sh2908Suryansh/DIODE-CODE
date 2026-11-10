import 'package:flutter/material.dart';

import 'screens/bias_screen.dart';
import 'screens/comparison_screen.dart';
import 'screens/home_screen.dart';
import 'screens/quiz_screen.dart';
import 'theme.dart';
import 'models/lab_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LabSession.instance.load();
  runApp(const DiodeLabApp());
}

class DiodeLabApp extends StatelessWidget {
  const DiodeLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PN Junction Diode Lab',
      debugShowCheckedModeBanner: false,
      theme: buildLabTheme(),
      initialRoute: '/',
      routes: {
        '/': (_) => const HomeScreen(),
        '/forward': (_) => const BiasScreen(forward: true),
        '/comparison': (_) => const ComparisonScreen(),
        '/quiz': (_) => const QuizScreen(),
      },
    );
  }
}
