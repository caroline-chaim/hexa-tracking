import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:hexa_tracker/services/library_service.dart';
import 'package:hexa_tracker/services/match_service.dart';

class GamePage extends StatefulWidget {
  final String id;
  final String name;

  const GamePage({super.key, required this.id, required this.name});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  Map<String, String>? details;
  bool isLoading = true;
  bool _inLibrary = false;
  bool _libraryLoading = false;

  // Partida
  bool _matchRunning = false;
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadDetails() async {
    final data = await ApiService.getGameFullDetails(widget.id);
    final inLib = await LibraryService.isInLibrary(widget.id);
    setState(() {
      details = data;
      _inLibrary = inLib;
      isLoading = false;
    });
  }

  Future<void> _toggleLibrary() async {
    setState(() => _libraryLoading = true);
    if (_inLibrary) {
      await LibraryService.removeGame(widget.id);
    } else {
      await LibraryService.addGame({
        'id': widget.id,
        'name': details!['name'] ?? widget.name,
        'thumbnail': details!['thumbnail'] ?? '',
        'image': details!['image'] ?? '',
        'rating': details!['rating'] ?? '',
        'yearpublished': details!['yearpublished'] ?? '',
      });
    }
    final inLib = await LibraryService.isInLibrary(widget.id);
    setState(() { _inLibrary = inLib; _libraryLoading = false; });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(inLib ? '${details!['name']} adicionado à biblioteca!' : 'Removido da biblioteca.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    }
  }

  void _startMatch() {
    setState(() { _matchRunning = true; _elapsedSeconds = 0; });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _stopMatch() {
    _timer?.cancel();
  }

  Future<void> _endMatch(String result) async {
    _stopMatch();
    final duration = _elapsedSeconds;
    setState(() => _matchRunning = false);

    final saved = await MatchService.saveMatch(
      gameId: widget.id,
      gameName: details!['name'] ?? widget.name,
      gameThumbnail: details!['thumbnail'] ?? '',
      durationSeconds: duration,
      result: result,
    );

    if (mounted) {
      final emoji = result == 'win' ? '🏆' : '😔';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(saved
            ? '$emoji Partida salva! Duração: ${_formatTime(duration)}'
            : 'Erro ao salvar partida.'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ));
    }
  }

  String _formatTime(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) return '${h}h ${m}m ${s}s';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (_matchRunning) _stopMatch();
            Navigator.pop(context);
          },
        ),
        actions: [
          if (!isLoading)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _libraryLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : _AddToLibraryButton(inLibrary: _inLibrary, onTap: _toggleLibrary),
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: isMobile ? _mobileLayout(context) : _desktopLayout(context),
            ),
    );
  }

  Widget _desktopLayout(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            ApiService.proxyImage(details!['image']!),
            width: 220, height: 180, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: 220, height: 180, color: Colors.grey[300]),
          ),
        ),
        const SizedBox(width: 32),
        Expanded(child: _detailsColumn(false)),
      ],
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            ApiService.proxyImage(details!['image']!),
            width: double.infinity, height: 220, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(width: double.infinity, height: 220, color: Colors.grey[300]),
          ),
        ),
        const SizedBox(height: 24),
        _detailsColumn(true),
      ],
    );
  }

  Widget _detailsColumn(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RANK: OVERALL  ${details!['rank']}',
            style: TextStyle(color: Colors.grey[600], fontSize: 13, letterSpacing: 1)),
        const SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            Text(details!['name']!,
                style: GoogleFonts.majorMonoDisplay(fontSize: isMobile ? 20 : 28)),
            Text('(${details!['yearpublished']})',
                style: TextStyle(fontSize: 16, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.blue[700], borderRadius: BorderRadius.circular(8)),
              child: Text(details!['rating']!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            const SizedBox(width: 12),
            _AddToLibraryButton(inLibrary: _inLibrary, onTap: _toggleLibrary),
          ],
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12, runSpacing: 12,
          children: [
            _statBox('${details!['minplayers']}–${details!['maxplayers']} Players', 'Min/Max Players'),
            _statBox('${details!['minplaytime']}–${details!['maxplaytime']} Min', 'Playing Time'),
            _statBox('Age: ${details!['minage']}+', 'Minimum Age'),
            _statBox('Weight: ${details!['weight']} / 5', 'Complexity'),
          ],
        ),
        const SizedBox(height: 24),

        // ── Seção de partida ──────────────────────────────────────────────────
        _MatchSection(
          running: _matchRunning,
          elapsed: _elapsedSeconds,
          formatTime: _formatTime,
          onStart: _startMatch,
          onEnd: _endMatch,
        ),

        const SizedBox(height: 24),
        const Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(
          details!['description']!
              .replaceAll('&mdash;', '—')
              .replaceAll('&ldquo;', '"')
              .replaceAll('&rdquo;', '"')
              .replaceAll('&#10;', '\n'),
          style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.5),
        ),
      ],
    );
  }

  Widget _statBox(String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Seção de partida ───────────────────────────────────────────────────────────

class _MatchSection extends StatelessWidget {
  final bool running;
  final int elapsed;
  final String Function(int) formatTime;
  final VoidCallback onStart;
  final Future<void> Function(String) onEnd;

  const _MatchSection({
    required this.running,
    required this.elapsed,
    required this.formatTime,
    required this.onStart,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: running ? _runningState() : _idleState(),
    );
  }

  Widget _idleState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Partida', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Partida'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _runningState() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 10, height: 10,
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            const Text('Partida em andamento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            formatTime(elapsed),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w200, letterSpacing: 2),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onEnd('win'),
                icon: const Icon(Icons.emoji_events),
                label: const Text('Vitória'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => onEnd('loss'),
                icon: const Icon(Icons.sentiment_dissatisfied),
                label: const Text('Derrota'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Add to Library Button ──────────────────────────────────────────────────────

class _AddToLibraryButton extends StatefulWidget {
  final bool inLibrary;
  final VoidCallback onTap;
  const _AddToLibraryButton({required this.inLibrary, required this.onTap});

  @override
  State<_AddToLibraryButton> createState() => _AddToLibraryButtonState();
}

class _AddToLibraryButtonState extends State<_AddToLibraryButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final color = widget.inLibrary ? Colors.green[700]! : Colors.blue[700]!;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: _hovering ? color : color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(8),
            boxShadow: _hovering
                ? [BoxShadow(color: color.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 3))]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.inLibrary ? Icons.check : Icons.add, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                widget.inLibrary ? 'Na Biblioteca' : 'Adicionar à Biblioteca',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}