import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/services/match_service.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';
import 'dart:math' as math;

class WinRate extends StatefulWidget {
  const WinRate({super.key});

  @override
  State<WinRate> createState() => _WinRateState();
}

class _WinRateState extends State<WinRate> {
  List<Map<String, dynamic>> _matches = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final matches = await MatchService.getMonthMatches();
    setState(() { _matches = matches; _loading = false; });
  }

  // Partidas por jogo
  Map<String, int> get _matchesByGame {
    final map = <String, int>{};
    for (final m in _matches) {
      final name = m['gameName'] as String? ?? 'Desconhecido';
      map[name] = (map[name] ?? 0) + 1;
    }
    return map;
  }

  // Tempo médio por jogo (em minutos)
  Map<String, double> get _avgDurationByGame {
    final totals = <String, int>{};
    final counts = <String, int>{};
    for (final m in _matches) {
      final name = m['gameName'] as String? ?? 'Desconhecido';
      final dur = (m['durationSeconds'] as num?)?.toInt() ?? 0;
      totals[name] = (totals[name] ?? 0) + dur;
      counts[name] = (counts[name] ?? 0) + 1;
    }
    return totals.map((k, v) => MapEntry(k, (v / counts[k]!) / 60));
  }

  // Vitórias e derrotas por jogo
  Map<String, Map<String, int>> get _resultsByGame {
    final map = <String, Map<String, int>>{};
    for (final m in _matches) {
      final name = m['gameName'] as String? ?? 'Desconhecido';
      map.putIfAbsent(name, () => {'win': 0, 'loss': 0});
      final result = m['result'] as String? ?? 'loss';
      map[name]![result] = (map[name]![result] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final now = DateTime.now();
    final monthName = _monthName(now.month);

    return AppScaffold(
      backgroundColor: Colors.grey[100]!,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _matches.isEmpty
              ? _emptyState()
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isMobile ? 16 : 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Win Rate',
                          style: GoogleFonts.majorMonoDisplay(fontSize: isMobile ? 24 : 32)),
                      const SizedBox(height: 4),
                      Text('$monthName ${now.year}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                      const SizedBox(height: 8),
                      _summaryRow(isMobile),
                      const SizedBox(height: 32),
                      _sectionTitle('Partidas por Jogo'),
                      const SizedBox(height: 16),
                      _PieChart(data: _matchesByGame),
                      const SizedBox(height: 32),
                      _sectionTitle('Tempo Médio de Partida (min)'),
                      const SizedBox(height: 16),
                      _BarChart(data: _avgDurationByGame, unit: 'min', color: Colors.blue[600]!),
                      const SizedBox(height: 32),
                      _sectionTitle('Vitórias e Derrotas'),
                      const SizedBox(height: 16),
                      _WinLossChart(data: _resultsByGame),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Nenhuma partida este mês',
              style: GoogleFonts.majorMonoDisplay(fontSize: 18, color: Colors.grey[600])),
          const SizedBox(height: 8),
          Text('Inicie uma partida na página de um jogo para ver suas estatísticas.',
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _summaryRow(bool isMobile) {
    final wins = _matches.where((m) => m['result'] == 'win').length;
    final losses = _matches.length - wins;
    final winRate = _matches.isEmpty ? 0 : (wins / _matches.length * 100).round();

    return Wrap(
      spacing: 12, runSpacing: 12,
      children: [
        _StatCard(label: 'Partidas', value: '${_matches.length}', color: Colors.blue[700]!),
        _StatCard(label: 'Vitórias', value: '$wins', color: Colors.green[600]!),
        _StatCard(label: 'Derrotas', value: '$losses', color: Colors.red[600]!),
        _StatCard(label: 'Win Rate', value: '$winRate%', color: Colors.purple[600]!),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16));
  }

  String _monthName(int month) {
    const names = ['Janeiro','Fevereiro','Março','Abril','Maio','Junho',
                   'Julho','Agosto','Setembro','Outubro','Novembro','Dezembro'];
    return names[month - 1];
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
        ],
      ),
    );
  }
}

// ── Pie Chart ─────────────────────────────────────────────────────────────────

class _PieChart extends StatelessWidget {
  final Map<String, int> data;
  const _PieChart({required this.data});

  static const _colors = [
    Color(0xFF4285F4), Color(0xFF34A853), Color(0xFFEA4335), Color(0xFFFBBC05),
    Color(0xFF9B59B6), Color(0xFF1ABC9C), Color(0xFFE67E22), Color(0xFF2ECC71),
  ];

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0, (a, b) => a + b);
    final entries = data.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 160, height: 160,
            child: CustomPaint(
              painter: _PiePainter(entries: entries, total: total, colors: _colors),
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(entries.length, (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12, height: 12,
                      decoration: BoxDecoration(
                        color: _colors[i % _colors.length],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(entries[i].key,
                          style: const TextStyle(fontSize: 13),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    Text('${entries[i].value}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<MapEntry<String, int>> entries;
  final int total;
  final List<Color> colors;
  const _PiePainter({required this.entries, required this.total, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    var startAngle = -math.pi / 2;
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < entries.length; i++) {
      final sweep = (entries[i].value / total) * 2 * math.pi;
      paint.color = colors[i % colors.length];
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle, sweep, true, paint,
      );
      startAngle += sweep;
    }

    // Hole (donut)
    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.55, paint);

    // Total no centro
    final tp = TextPainter(
      text: TextSpan(
        text: '$total',
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => true;
}

// ── Bar Chart ─────────────────────────────────────────────────────────────────

class _BarChart extends StatelessWidget {
  final Map<String, double> data;
  final String unit;
  final Color color;
  const _BarChart({required this.data, required this.unit, required this.color});

  @override
  Widget build(BuildContext context) {
    final maxVal = data.values.fold(0.0, math.max);
    final entries = data.entries.toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: List.generate(entries.length, (i) {
          final pct = maxVal == 0 ? 0.0 : entries[i].value / maxVal;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(entries[i].key,
                      style: const TextStyle(fontSize: 12),
                      overflow: TextOverflow.ellipsis),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Stack(
                    children: [
                      Container(height: 28, decoration: BoxDecoration(
                        color: Colors.grey[100], borderRadius: BorderRadius.circular(4))),
                      FractionallySizedBox(
                        widthFactor: pct.clamp(0.0, 1.0),
                        child: Container(height: 28, decoration: BoxDecoration(
                          color: color, borderRadius: BorderRadius.circular(4))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${entries[i].value.toStringAsFixed(1)} $unit',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ── Win/Loss Chart ────────────────────────────────────────────────────────────

class _WinLossChart extends StatelessWidget {
  final Map<String, Map<String, int>> data;
  const _WinLossChart({required this.data});

  @override
  Widget build(BuildContext context) {
    final entries = data.entries.toList();
    final maxVal = entries.fold(0, (prev, e) =>
        math.max(prev, (e.value['win'] ?? 0) + (e.value['loss'] ?? 0)));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          // Legenda
          Row(
            children: [
              _legendDot(Colors.green[600]!, 'Vitória'),
              const SizedBox(width: 16),
              _legendDot(Colors.red[600]!, 'Derrota'),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(entries.length, (i) {
            final wins = entries[i].value['win'] ?? 0;
            final losses = entries[i].value['loss'] ?? 0;
            final total = wins + losses;
            final pctWin = maxVal == 0 ? 0.0 : wins / maxVal;
            final pctLoss = maxVal == 0 ? 0.0 : losses / maxVal;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(entries[i].key,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      children: [
                        // Barra de vitórias
                        Row(children: [
                          Flexible(
                            flex: (pctWin * 100).round(),
                            child: Container(height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.green[600],
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                                )),
                          ),
                          Flexible(
                            flex: 100 - (pctWin * 100).round(),
                            child: Container(height: 12, color: Colors.grey[100]),
                          ),
                        ]),
                        const SizedBox(height: 2),
                        // Barra de derrotas
                        Row(children: [
                          Flexible(
                            flex: (pctLoss * 100).round(),
                            child: Container(height: 12,
                                decoration: BoxDecoration(
                                  color: Colors.red[600],
                                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(4)),
                                )),
                          ),
                          Flexible(
                            flex: 100 - (pctLoss * 100).round(),
                            child: Container(height: 12, color: Colors.grey[100]),
                          ),
                        ]),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$wins/$total',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}