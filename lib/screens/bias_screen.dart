import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/diode_model.dart';
import '../models/lab_session.dart';
import '../services/lab_platform.dart' as platform;
import '../widgets/combined_curve.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
import '../widgets/circuit_diagram.dart';
import '../widgets/lesson_scaffold.dart';

class BiasScreen extends StatefulWidget {
  const BiasScreen({super.key, required this.forward});
  final bool forward;
  @override
  State<BiasScreen> createState() => _BiasScreenState();
}

class _BiasScreenState extends State<BiasScreen> {
  final session = LabSession.instance;
  late final TextEditingController _input;
  String? _inputError;
  bool _exporting = false;
  double get voltage => session.voltage;
  set voltage(double value) => session.voltage = value;
  double get reverseVoltage => session.reverseVoltage;
  set reverseVoltage(double value) => session.reverseVoltage = value;
  bool get silicon => session.silicon;
  set silicon(bool value) => session.silicon = value;
  bool get forwardBias => session.forward;
  set forwardBias(bool value) => session.forward = value;
  @override
  void initState() {
    super.initState();
    _input = TextEditingController(text: selectedVoltage.toStringAsFixed(3));
  }

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    session.save();
  }

  void _applyVoltage() {
    final value = double.tryParse(_input.text.trim());
    final maximum = forwardBias ? 1.0 : 10.0;
    if (value == null || !value.isFinite || value < 0 || value > maximum) {
      setState(
          () => _inputError = 'Enter a number from 0 to ${maximum.toInt()} V.');
      return;
    }
    setState(() {
      if (forwardBias) {
        voltage = value;
      } else {
        reverseVoltage = value;
      }
      _inputError = null;
    });
    FocusScope.of(context).unfocus();
  }

  void _record() {
    if (_input.text.trim() != selectedVoltage.toStringAsFixed(3)) {
      _applyVoltage();
      if (_inputError != null) return;
    }
    final sign = forwardBias ? 1.0 : -1.0;
    setState(() => session.observations.add(Observation(
        silicon: silicon,
        forward: forwardBias,
        volts: selectedVoltage * sign,
        amps: current * (forwardBias ? 1e-3 : 1e-6) * sign)));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        content: Text('Reading ${session.observations.length} recorded')));
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final saved = await platform.exportCsv(session.csv());
      if (mounted && saved) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('CSV exported')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Could not export. Use Copy CSV or try another location.')));
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  DiodeModel get model => silicon ? DiodeModel.silicon : DiodeModel.germanium;
  double get selectedVoltage => forwardBias ? voltage : reverseVoltage;
  double get current => forwardBias
      ? model.forwardMilliAmps(voltage)
      : model.reverseMicroAmps(reverseVoltage);
  Color get accent => silicon ? LabColors.silicon : LabColors.germanium;

  @override
  Widget build(BuildContext context) => LessonScaffold(
      title: 'V–I experiment',
      route: '/forward',
      nextLabel: 'Test your knowledge',
      onNext: () => Navigator.pushReplacementNamed(context, '/quiz'),
      onBack: () => Navigator.pushReplacementNamed(context, '/comparison'),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('Explore the diode curve',
            style: TextStyle(
                fontSize: 30,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: LabColors.navy)),
        const SizedBox(height: 10),
        const Text('Change the voltage. Watch the current respond.',
            style: TextStyle(fontSize: 15, color: LabColors.muted)),
        const SizedBox(height: 24),
        LayoutBuilder(builder: (context, constraints) {
          final controls = _controls();
          final graph = _graph();
          if (constraints.maxWidth < 850) {
            return Column(
                children: [controls, const SizedBox(height: 16), graph]);
          }
          return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(width: 290, child: controls),
            const SizedBox(width: 20),
            Expanded(child: graph),
          ]);
        }),
        const SizedBox(height: 20),
        _observations(),
        const SizedBox(height: 16),
        ValueListenableBuilder<bool>(
            valueListenable: session.storageError,
            builder: (_, failed, __) => failed
                ? const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Text(
                        "Progress could not be saved. Export your readings before closing the app."))
                : const SizedBox.shrink()),
        _panel(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.lightbulb_outline, size: 20, color: LabColors.tealDark),
            SizedBox(width: 8),
            Expanded(
                child: Text('What to look for',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w700)))
          ]),
          const SizedBox(height: 10),
          Text(
              forwardBias
                  ? 'Germanium reaches the same current at a lower voltage. Both curves rise continuously; the familiar 0.3 V and 0.7 V values are approximate, not sharp switches.'
                  : 'Reverse current quickly approaches a small saturation value. Germanium has more leakage in this model. The silicon trace is very close to zero at this scale.',
              style: const TextStyle(height: 1.6, color: LabColors.muted)),
        ])),
        const SizedBox(height: 12),
        _panel(
            padding: EdgeInsets.zero,
            child: ExpansionTile(
                title: const Text('Circuit & procedure',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text(
                    'Connections, instruments and measurement steps'),
                leading: const Icon(Icons.electrical_services_outlined),
                shape: const Border(),
                collapsedShape: const Border(),
                children: [
                  CircuitDiagram(
                      bias: forwardBias
                          ? CircuitBias.forward
                          : CircuitBias.reverse),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      child: Text(
                          forwardBias
                              ? '1. Connect a DC supply, series resistor and diode.\n2. Place an ammeter in series and a voltmeter across the diode.\n3. Increase the supply carefully and record the measured diode voltage and current.\n4. Repeat with the other diode.'
                              : '1. Reverse the supply polarity and keep the series resistor.\n2. Use a sensitive current meter in series and a voltmeter across the diode.\n3. Increase reverse voltage below the diode’s rated breakdown voltage.\n4. Record the small leakage current for each diode.',
                          style: const TextStyle(
                              height: 1.8, color: LabColors.muted))),
                ])),
        const SizedBox(height: 12),
        _panel(
            padding: EdgeInsets.zero,
            child: const ExpansionTile(
              title: Text('About this simulation',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              leading: Icon(Icons.info_outline),
              shape: Border(),
              collapsedShape: Border(),
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                        'Representative PN junctions at 25 °C using the Shockley equation with ideality factor 2 and 2 Ω internal series resistance. The model gives 1 mA at 0.65 V for Si and 0.28 V for Ge. The control sets voltage across the diode, not the DC supply.\n\nReverse plots show positive magnitudes |Vᵣ| and |Iᵣ|; on a signed V–I plot the reverse branch is in the third quadrant. Breakdown and self-heating are excluded. Values illustrate the physics and are not measured data or specifications for a particular diode.',
                        style: TextStyle(height: 1.6, color: LabColors.muted)))
              ],
            )),
      ]));

  Widget _controls() => _panel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Virtual measurement',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
        const SizedBox(height: 20),
        const Text('Bias condition',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: const [
              ButtonSegment(value: true, label: Text('Forward')),
              ButtonSegment(value: false, label: Text('Reverse'))
            ],
            selected: {forwardBias},
            onSelectionChanged: (v) => setState(() {
                  forwardBias = v.first;
                  _input.text = selectedVoltage.toStringAsFixed(3);
                  _inputError = null;
                })),
        const SizedBox(height: 22),
        const Text('Diode material',
            style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        _material(true, 'Silicon (Si)', 'Higher forward voltage'),
        const SizedBox(height: 8),
        _material(false, 'Germanium (Ge)', 'Lower forward voltage'),
        const SizedBox(height: 24),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: Text(
                  forwardBias ? 'Diode voltage' : 'Reverse voltage |Vᵣ|',
                  style: const TextStyle(fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          Text('${selectedVoltage.toStringAsFixed(3)} V',
              style: TextStyle(fontWeight: FontWeight.w800, color: accent)),
        ]),
        const SizedBox(height: 10),
        SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 5),
            child: Slider(
                value: selectedVoltage,
                min: 0,
                max: forwardBias ? 1 : 10,
                divisions: forwardBias ? 100 : 200,
                activeColor: accent,
                semanticFormatterCallback: (v) =>
                    '${v.toStringAsFixed(2)} volts',
                label: '${selectedVoltage.toStringAsFixed(3)} V',
                onChanged: (v) => setState(() {
                      if (forwardBias) {
                        voltage = v;
                      } else {
                        reverseVoltage = v;
                      }
                      _input.text = selectedVoltage.toStringAsFixed(3);
                      _inputError = null;
                    }))),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('0 V', style: TextStyle(color: LabColors.muted)),
          Text(forwardBias ? '1.00 V' : '10.00 V',
              style: const TextStyle(color: LabColors.muted))
        ]),
        const SizedBox(height: 18),
        TextField(
            controller: _input,
            key: const Key('exact-voltage'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _applyVoltage(),
            decoration: InputDecoration(
                labelText: 'Exact diode voltage',
                suffixText: 'V',
                errorText: _inputError,
                helperText: forwardBias ? 'Range: 0–1 V' : 'Range: 0–10 V')),
        const SizedBox(height: 8),
        OutlinedButton(
            onPressed: _applyVoltage, child: const Text('Apply voltage')),
        const SizedBox(height: 10),
        FilledButton.icon(
            onPressed: _record,
            icon: const Icon(Icons.add),
            label: const Text('Record reading')),
        const SizedBox(height: 14),
        const Divider(),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.thermostat, size: 18, color: LabColors.muted),
          const SizedBox(width: 6),
          const Expanded(
              child: Text('25 °C · illustrative model',
                  style: TextStyle(fontSize: 12, color: LabColors.muted))),
          IconButton(
              tooltip: 'Reset experiment',
              icon: const Icon(Icons.restart_alt),
              onPressed: () => setState(() {
                    voltage = 0.65;
                    reverseVoltage = 5;
                    silicon = true;
                    forwardBias = widget.forward;
                    _input.text = selectedVoltage.toStringAsFixed(3);
                    _inputError = null;
                  }))
        ]),
      ]));

  Widget _material(bool si, String title, String subtitle) {
    final selected = silicon == si;
    final color = si ? LabColors.silicon : LabColors.germanium;
    return Semantics(
        selected: selected,
        button: true,
        child: Material(
            color: selected ? color.withValues(alpha: 0.07) : Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(
                    color: selected ? color : const Color(0xFFDCE4ED),
                    width: selected ? 1.5 : 1)),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
                onTap: () => setState(() => silicon = si),
                child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                              color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 3),
                            Text(subtitle,
                                style: const TextStyle(
                                    fontSize: 11, color: LabColors.muted))
                          ])),
                      if (selected)
                        Icon(Icons.check_circle, color: color, size: 19),
                    ])))));
  }

  Widget _graph() {
    final unit =
        forwardBias ? 'mA' : (current > 0 && current < 0.1 ? 'nA' : 'µA');
    final displayCurrent = unit == 'nA' ? current * 1000 : current;
    return _panel(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(
                forwardBias
                    ? 'Forward characteristic'
                    : 'Reverse characteristic',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const _Tag('Live simulation')
          ]),
      const SizedBox(height: 6),
      Text(
          forwardBias
              ? 'Diode current vs. diode voltage'
              : 'Reverse voltage and current magnitudes',
          style: const TextStyle(color: LabColors.muted, fontSize: 13)),
      const SizedBox(height: 22),
      Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: const Color(0xFFF1F6FC),
              borderRadius: BorderRadius.circular(10)),
          child: Row(children: [
            Expanded(
                child: _reading(
                    forwardBias ? 'Forward voltage' : 'Reverse voltage',
                    selectedVoltage.toStringAsFixed(3),
                    'V')),
            Container(height: 45, width: 1, color: const Color(0xFFD5DFEC)),
            const SizedBox(width: 16),
            Expanded(
                child: _reading(
                    forwardBias ? 'Forward current' : 'Leakage current',
                    displayCurrent.toStringAsFixed(2),
                    unit)),
          ])),
      const SizedBox(height: 12),
      SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          title: const Text('Combined signed view',
              style: TextStyle(fontSize: 14)),
          value: session.combined,
          onChanged: (v) => setState(() => session.combined = v)),
      if (session.combined)
        const Padding(
            padding: EdgeInsets.only(bottom: 16),
            child: Text(
                'Split scales: left −10 to 0 V; right 0 to 1 V. Above zero: mA; below zero: µA.',
                style: TextStyle(
                    fontSize: 12, height: 1.5, color: LabColors.muted))),
      const SizedBox(height: 12),
      Semantics(
          label: '${forwardBias ? 'Forward' : 'Reverse'} characteristic. '
              '${silicon ? 'Silicon' : 'Germanium'} selected: '
              '${selectedVoltage.toStringAsFixed(3)} volts, '
              '${displayCurrent.toStringAsFixed(2)} $unit.',
          child: SizedBox(
              height: 300,
              width: double.infinity,
              child: CustomPaint(
                  painter: session.combined
                      ? CombinedCurvePainter(
                          voltage: selectedVoltage,
                          silicon: silicon,
                          forward: forwardBias)
                      : VICurvePainter(
                          voltage: selectedVoltage,
                          silicon: silicon,
                          forward: forwardBias)))),
      const SizedBox(height: 12),
      const Wrap(spacing: 20, runSpacing: 8, children: [
        _Legend(color: LabColors.silicon, label: 'Silicon'),
        _Legend(color: LabColors.germanium, label: 'Germanium', dashed: true)
      ]),
      const SizedBox(height: 16),
      Text(
          forwardBias
              ? 'The dot is your reading. Curves continue above the plot; the current axis expands for larger readings.'
              : 'Before breakdown: leakage approaches saturation. Both axes show positive magnitudes.',
          style: const TextStyle(
              fontSize: 12, height: 1.5, color: LabColors.muted)),
    ]));
  }

  Widget _observations() => _panel(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Wrap(
            spacing: 12,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Text('Observation table (${session.observations.length})',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, fontSize: 18)),
              Wrap(spacing: 8, children: [
                OutlinedButton.icon(
                    onPressed: session.observations.isEmpty || _exporting
                        ? null
                        : _export,
                    icon: const Icon(Icons.download_outlined, size: 18),
                    label: Text(_exporting ? 'Exporting…' : 'Export CSV')),
                TextButton(
                    onPressed: session.observations.isEmpty
                        ? null
                        : () async {
                            await Clipboard.setData(
                                ClipboardData(text: session.csv()));
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('CSV copied')));
                            }
                          },
                    child: const Text('Copy CSV')),
              ]),
            ]),
        const SizedBox(height: 12),
        if (session.observations.isEmpty)
          const Text(
              'Set a voltage, then tap Record reading. Collect both materials and bias conditions for your lab report.',
              style: TextStyle(height: 1.6, color: LabColors.muted))
        else ...[
          const Text(
              'Signed readings. Reverse voltage and current are negative. Scroll sideways on small screens.',
              style: TextStyle(fontSize: 12, color: LabColors.muted)),
          const SizedBox(height: 8),
          ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 330),
              child: SingleChildScrollView(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(columnSpacing: 20, columns: const [
                        DataColumn(label: Text('#')),
                        DataColumn(label: Text('Diode')),
                        DataColumn(label: Text('Bias')),
                        DataColumn(label: Text('V (V)')),
                        DataColumn(label: Text('Current')),
                        DataColumn(label: Text('Remove'))
                      ], rows: [
                        for (var i = 0; i < session.observations.length; i++)
                          DataRow(cells: [
                            DataCell(Text('${i + 1}')),
                            DataCell(Text(
                                session.observations[i].silicon ? 'Si' : 'Ge')),
                            DataCell(Text(session.observations[i].forward
                                ? 'Forward'
                                : 'Reverse')),
                            DataCell(Text(session.observations[i].volts
                                .toStringAsFixed(4))),
                            DataCell(Text(
                                '${(session.observations[i].amps * (session.observations[i].forward ? 1e3 : 1e6)).toStringAsPrecision(5)} ${session.observations[i].forward ? 'mA' : 'µA'}')),
                            DataCell(IconButton(
                                tooltip: 'Remove reading ${i + 1}',
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  final removed = session.observations[i];
                                  setState(
                                      () => session.observations.removeAt(i));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              const Text('Reading removed'),
                                          action: SnackBarAction(
                                              label: 'Undo',
                                              onPressed: () => setState(() =>
                                                  session.observations.insert(
                                                      math.min(
                                                          i,
                                                          session.observations
                                                              .length),
                                                      removed)))));
                                }))
                          ])
                      ])))),
        ],
      ]));

  Widget _reading(String label, String value, String unit) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(fontSize: 12, color: LabColors.muted)),
        const SizedBox(height: 6),
        FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text.rich(TextSpan(children: [
              TextSpan(
                  text: value,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      color: accent)),
              TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: LabColors.muted))
            ]))),
      ]);

  Widget _panel(
          {required Widget child,
          EdgeInsets padding = const EdgeInsets.all(20)}) =>
      Container(
          padding: padding,
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFDCE5EF))),
          child: Material(color: Colors.transparent, child: child));
}

class _Tag extends StatelessWidget {
  const _Tag(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color: const Color(0xFFE5F5EF),
          borderRadius: BorderRadius.circular(20)),
      child: Text(text,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF21624B))));
}

class _Legend extends StatelessWidget {
  const _Legend(
      {required this.color, required this.label, this.dashed = false});
  final Color color;
  final String label;
  final bool dashed;
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
            width: 24,
            child: Row(children: [
              Expanded(child: Container(height: 3, color: color)),
              if (dashed) ...[
                const SizedBox(width: 4),
                Expanded(child: Container(height: 3, color: color))
              ]
            ])),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12))
      ]);
}

class VICurvePainter extends CustomPainter {
  VICurvePainter(
      {required this.voltage, required this.silicon, required this.forward});
  final double voltage;
  final bool silicon;
  final bool forward;

  static double niceMaximum(double value) {
    if (value <= 20) return 20;
    final magnitude =
        math.pow(10, (math.log(value) / math.ln10).floor()).toDouble();
    final fraction = value / magnitude;
    return (fraction <= 2
            ? 2
            : fraction <= 5
                ? 5
                : 10) *
        magnitude;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final model = silicon ? DiodeModel.silicon : DiodeModel.germanium;
    double measured(DiodeModel m, double v) =>
        forward ? m.forwardMilliAmps(v) : m.reverseMicroAmps(v);
    final selected = measured(model, voltage);
    final xMax = forward ? 1.0 : 10.0;
    final yMax = forward ? niceMaximum(selected * 1.15) : 6.0;
    final plot = Rect.fromLTRB(48, 22, size.width - 14, size.height - 46);
    Offset point(double v, double current) => Offset(
        plot.left + v / xMax * plot.width,
        plot.bottom - current / yMax * plot.height);
    final grid = Paint()
      ..color = const Color(0xFFE4EAF2)
      ..strokeWidth = 1;
    final axis = Paint()
      ..color = const Color(0xFF7E8FA3)
      ..strokeWidth = 1;
    void label(String value, Offset at,
        {bool centered = false, Color color = LabColors.muted}) {
      final text = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
              text: value, style: TextStyle(fontSize: 10, color: color)))
        ..layout();
      text.paint(
          canvas, Offset(at.dx - (centered ? text.width / 2 : 0), at.dy));
    }

    for (var i = 0; i <= 4; i++) {
      final value = yMax * i / 4;
      final y = point(0, value).dy;
      canvas.drawLine(Offset(plot.left, y), Offset(plot.right, y), grid);
      final text = value == value.roundToDouble()
          ? value.toStringAsFixed(0)
          : value.toStringAsFixed(1);
      label(text, Offset(6, y - 6));
    }
    for (var i = 0; i <= 5; i++) {
      final value = xMax * i / 5;
      final x = point(value, 0).dx;
      canvas.drawLine(Offset(x, plot.top), Offset(x, plot.bottom), grid);
      label(value.toStringAsFixed(forward ? 1 : 0), Offset(x, plot.bottom + 10),
          centered: true);
    }
    canvas.drawLine(plot.topLeft, plot.bottomLeft, axis);
    canvas.drawLine(plot.bottomLeft, plot.bottomRight, axis);
    label(forward ? 'I (mA)' : '|Iᵣ| (µA)', const Offset(0, 0));
    label(forward ? 'Diode voltage (V)' : '|Vᵣ| (V)',
        Offset(plot.center.dx, size.height - 12),
        centered: true);

    canvas.save();
    canvas.clipRect(plot.inflate(1));
    void curve(DiodeModel m, Color color, bool dashed) {
      final path = Path();
      // Dense samples resolve the reverse branch's rapid approach to saturation.
      for (var i = 0; i <= 1000; i++) {
        final v = xMax * i / 1000;
        final p = point(v, measured(m, v));
        if (i == 0) {
          path.moveTo(p.dx, p.dy);
        } else {
          path.lineTo(p.dx, p.dy);
        }
      }
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      if (!dashed) {
        canvas.drawPath(path, paint);
        return;
      }
      for (final metric in path.computeMetrics()) {
        for (var d = 0.0; d < metric.length; d += 11) {
          canvas.drawPath(
              metric.extractPath(d, math.min(d + 6, metric.length)), paint);
        }
      }
    }

    curve(DiodeModel.silicon, LabColors.silicon, false);
    curve(DiodeModel.germanium, LabColors.germanium, true);
    final p = point(voltage, selected);
    final color = silicon ? LabColors.silicon : LabColors.germanium;
    final guide = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1;
    canvas.drawLine(Offset(p.dx, plot.bottom), p, guide);
    canvas.drawLine(Offset(plot.left, p.dy), p, guide);
    canvas.restore();
    canvas.drawCircle(p, 10, Paint()..color = color.withValues(alpha: 0.12));
    canvas.drawCircle(p, 5, Paint()..color = color);
    canvas.drawCircle(
        p,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2);
  }

  @override
  bool shouldRepaint(covariant VICurvePainter oldDelegate) =>
      oldDelegate.voltage != voltage ||
      oldDelegate.silicon != silicon ||
      oldDelegate.forward != forward;
}
