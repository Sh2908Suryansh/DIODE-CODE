import 'package:flutter/material.dart';

import '../data/quiz_data.dart';
import '../models/lab_session.dart';
import '../theme.dart';
import '../widgets/lesson_scaffold.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _scroll = ScrollController();
  final _answers = List<int?>.filled(quizQuestions.length, null);
  int _index = 0;
  bool _started = false;
  bool _checked = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    final saved = LabSession.instance.quiz;
    final answers = saved['answers'] as List?;
    if (answers != null && answers.length == quizQuestions.length) {
      for (var i = 0; i < answers.length; i++) {
        final answer = answers[i];
        _answers[i] = answer is int &&
                answer >= 0 &&
                answer < quizQuestions[i].options.length
            ? answer
            : null;
      }
      _index =
          ((saved['index'] as int?) ?? 0).clamp(0, quizQuestions.length - 1);
      _started = saved['started'] == true;
      _checked = saved['checked'] == true && _answers[_index] != null;
      _finished = saved['finished'] == true && _answers.every((v) => v != null);
    }
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    LabSession.instance.quiz = {
      'answers': List<int?>.from(_answers),
      'index': _index,
      'started': _started,
      'checked': _checked,
      'finished': _finished
    };
    LabSession.instance.save();
  }

  int get _score => List.generate(quizQuestions.length,
          (i) => _answers[i] == quizQuestions[i].correctIndex ? 1 : 0)
      .fold(0, (total, value) => total + value);

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _next() {
    setState(() {
      if (_index == quizQuestions.length - 1) {
        _finished = true;
      } else {
        _index++;
        _checked = false;
      }
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  void _retry() {
    setState(() {
      _answers.fillRange(0, _answers.length, null);
      _index = 0;
      _checked = false;
      _finished = false;
    });
    if (_scroll.hasClients) _scroll.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) => LessonScaffold(
        title: 'Test your knowledge',
        route: '/quiz',
        onBack: () => Navigator.pushReplacementNamed(context, '/forward'),
        body: ListView(
          controller: _scroll,
          padding: const EdgeInsets.all(16),
          children: !_started
              ? _intro()
              : _finished
                  ? _results()
                  : _question(),
        ),
      );

  List<Widget> _intro() => [
        const InfoCard(
          icon: Icons.quiz_outlined,
          title: 'Put your diode knowledge to the test',
          body: 'Eight questions on PN junctions, forward and reverse bias, '
              'silicon versus germanium, and the virtual circuit. '
              'Check each answer to see an explanation, then review your score. '
              'No timer; you can retry as often as you like.',
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: () => setState(() => _started = true),
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Start quiz'),
        ),
      ];

  List<Widget> _question() {
    final question = quizQuestions[_index];
    final correct = _answers[_index] == question.correctIndex;
    return [
      Text('Question ${_index + 1} of ${quizQuestions.length}',
          style: const TextStyle(
              color: LabColors.tealDark, fontWeight: FontWeight.w800)),
      const SizedBox(height: 10),
      LinearProgressIndicator(
          value: (_index + (_checked ? 1 : 0)) / quizQuestions.length,
          minHeight: 6,
          borderRadius: BorderRadius.circular(6)),
      const SizedBox(height: 22),
      Text(question.prompt,
          style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: LabColors.navy,
              height: 1.35)),
      const SizedBox(height: 18),
      ...List.generate(question.options.length, (i) {
        final selected = _answers[_index] == i;
        final showCorrect = _checked && i == question.correctIndex;
        final showWrong = _checked && selected && !correct;
        final color = showCorrect
            ? LabColors.tealDark
            : showWrong
                ? Colors.red.shade700
                : selected
                    ? LabColors.silicon
                    : LabColors.navy;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Semantics(
            selected: selected,
            child: OutlinedButton(
              onPressed:
                  _checked ? null : () => setState(() => _answers[_index] = i),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                foregroundColor: color,
                disabledForegroundColor: color,
                backgroundColor: selected || showCorrect
                    ? color.withValues(alpha: 0.08)
                    : Colors.white,
                side: BorderSide(
                    color: color.withValues(
                        alpha: selected || showCorrect ? 1 : 0.2)),
                padding: const EdgeInsets.all(16),
              ),
              child: Row(children: [
                Icon(
                    showCorrect
                        ? Icons.check_circle_outline
                        : showWrong
                            ? Icons.cancel_outlined
                            : selected
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                    size: 22),
                const SizedBox(width: 12),
                Expanded(
                    child: Text(question.options[i],
                        style: const TextStyle(fontSize: 15, height: 1.4))),
              ]),
            ),
          ),
        );
      }),
      if (_checked) ...[
        const SizedBox(height: 6),
        InfoCard(
          icon: correct ? Icons.check_circle_outline : Icons.lightbulb_outline,
          title: correct ? 'Correct!' : 'Keep learning',
          body:
              '${correct ? '' : 'Correct answer: ${question.options[question.correctIndex]}\n\n'}${question.explanation}',
          accent: correct ? LabColors.teal : LabColors.germanium,
        ),
        const SizedBox(height: 16),
      ],
      ElevatedButton(
        onPressed: _checked
            ? _next
            : _answers[_index] == null
                ? null
                : () => setState(() => _checked = true),
        child: Text(_checked
            ? _index == quizQuestions.length - 1
                ? 'See results'
                : 'Next question'
            : 'Check answer'),
      ),
    ];
  }

  List<Widget> _results() => [
        Card(
          color: LabColors.navy,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Icon(Icons.school_outlined,
                  color: LabColors.teal, size: 36),
              const SizedBox(height: 12),
              const Text('Quiz complete',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700)),
              Text('$_score / ${quizQuestions.length}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 48,
                      fontWeight: FontWeight.w900)),
              Text(
                  _score == quizQuestions.length
                      ? 'Excellent work!'
                      : 'Review the explanations and give it another try.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70)),
            ]),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again')),
        const SizedBox(height: 22),
        const Text('Review your answers',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: LabColors.navy)),
        const SizedBox(height: 12),
        ...List.generate(quizQuestions.length, (i) {
          final q = quizQuestions[i];
          final correct = _answers[i] == q.correctIndex;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InfoCard(
              icon:
                  correct ? Icons.check_circle_outline : Icons.cancel_outlined,
              accent: correct ? LabColors.teal : LabColors.germanium,
              title: '${i + 1}. ${q.prompt}',
              body: 'Your answer: ${q.options[_answers[i]!]}\n'
                  '${correct ? '' : 'Correct answer: ${q.options[q.correctIndex]}\n'}'
                  '\n${q.explanation}',
            ),
          );
        }),
      ];
}
