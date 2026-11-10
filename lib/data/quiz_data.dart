class QuizQuestion {
  const QuizQuestion(
      {required this.prompt,
      required this.options,
      required this.correctIndex,
      required this.explanation});
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

const quizQuestions = [
  QuizQuestion(
    prompt:
        'What forms around a PN junction when P-type and N-type materials are joined?',
    options: [
      'A metallic wire',
      'A depletion region',
      'A transistor channel',
      'An insulating air gap'
    ],
    correctIndex: 1,
    explanation:
        'Electrons and holes recombine near the junction, leaving fixed ions. This region has very few mobile charge carriers and creates a potential barrier.',
  ),
  QuizQuestion(
    prompt: 'How is a diode connected in forward bias?',
    options: [
      'Anode to negative, cathode to positive',
      'Both terminals to positive',
      'Anode to positive, cathode to negative',
      'Both terminals disconnected'
    ],
    correctIndex: 2,
    explanation:
        'Forward bias connects the P-side (anode) to positive and the N-side (cathode) to negative. This lowers the junction barrier.',
  ),
  QuizQuestion(
    prompt: 'What is the typical knee voltage of a silicon diode?',
    options: ['0.1 V', '0.3 V', '0.7 V', '5 V'],
    correctIndex: 2,
    explanation:
        'A silicon diode is commonly described as turning on around 0.7 V. The exact forward voltage depends on current, temperature, and the diode itself.',
  ),
  QuizQuestion(
    prompt: 'Which material usually has the higher reverse leakage current?',
    options: [
      'Silicon',
      'Germanium',
      'Both always have equal leakage',
      'Neither has any leakage'
    ],
    correctIndex: 1,
    explanation:
        'Germanium generally has more reverse leakage than silicon, and its leakage is more sensitive to temperature.',
  ),
  QuizQuestion(
    prompt: 'What happens to forward current beyond the knee region?',
    options: [
      'It falls to zero',
      'It stays constant',
      'It increases rapidly',
      'It reverses direction'
    ],
    correctIndex: 2,
    explanation:
        'Forward current rises steeply as forward voltage increases. A series resistor limits current and protects the diode.',
  ),
  QuizQuestion(
    prompt: 'Why is a resistor connected in series with the diode?',
    options: [
      'To limit current',
      'To remove the depletion region permanently',
      'To short the supply',
      'To make reverse current zero'
    ],
    correctIndex: 0,
    explanation:
        'The series resistor limits current, especially after the diode starts conducting strongly. A wire across the resistor would bypass this protection.',
  ),
  QuizQuestion(
    prompt:
        'How should the meters be connected to measure diode voltage and current?',
    options: [
      'Both in series',
      'Both in parallel',
      'Ammeter in parallel, voltmeter in series',
      'Ammeter in series, voltmeter across the diode'
    ],
    correctIndex: 3,
    explanation:
        'An ammeter measures the current through the series path. A voltmeter connects in parallel across the diode to measure its terminal voltage.',
  ),
  QuizQuestion(
    prompt: 'What happens to the depletion region under reverse bias?',
    options: [
      'It disappears',
      'It becomes wider',
      'It becomes a metal',
      'It always carries a large forward current'
    ],
    correctIndex: 1,
    explanation:
        'Reverse bias widens the depletion region. Only a small leakage current flows before breakdown, which is avoided in this ordinary-diode experiment.',
  ),
];
