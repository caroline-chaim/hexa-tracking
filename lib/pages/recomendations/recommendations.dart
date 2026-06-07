import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:hexa_tracker/services/auth_service.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';
import 'package:hexa_tracker/ui/game_page/game_page.dart';

class Recommendation extends StatefulWidget {
  const Recommendation({super.key});

  @override
  State<Recommendation> createState() => _RecommendationState();
}

class _RecommendationState extends State<Recommendation> {
  static const String _baseUrl = 'https://hexa-tracker-server.azurewebsites.net';
  //static const String _baseUrl = 'http://localhost:3000';

  List<Map<String, dynamic>> _fromMatches = [];
  List<Map<String, dynamic>> _fromLibrary = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$_baseUrl/recommendations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode != 200) throw Exception('Erro ${response.statusCode}');
      final data = jsonDecode(response.body);
      setState(() {
        _fromMatches = List<Map<String, dynamic>>.from(data['fromMatches'] ?? []);
        _fromLibrary = List<Map<String, dynamic>>.from(data['fromLibrary'] ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppScaffold(
      backgroundColor: Colors.grey[100]!,
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Buscando recomendações...',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text('Erro ao carregar recomendações',
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        ElevatedButton(onPressed: _load, child: const Text('Tentar novamente')),
                      ],
                    ),
                  )
                : _fromMatches.isEmpty && _fromLibrary.isEmpty
                    ? _emptyState()
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 16 : 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Recomendações',
                                      style: GoogleFonts.majorMonoDisplay(
                                          fontSize: isMobile ? 24 : 32)),
                                  const SizedBox(height: 4),
                                  Text('Baseado no seu histórico e biblioteca',
                                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (_fromMatches.isNotEmpty) ...[
                              _SectionHeader(
                                icon: Icons.sports_esports_outlined,
                                title: 'Baseado nas suas partidas',
                                subtitle: 'Jogos similares ao que você mais joga',
                                isMobile: isMobile,
                              ),
                              const SizedBox(height: 12),
                              ..._fromMatches.map((rec) => _RecommendationGroup(
                                    sourceName: rec['sourceName'] ?? '',
                                    games: List<Map<String, dynamic>>.from(rec['games'] ?? []),
                                    isMobile: isMobile,
                                  )),
                              const SizedBox(height: 24),
                            ],
                            if (_fromLibrary.isNotEmpty) ...[
                              _SectionHeader(
                                icon: Icons.library_books_outlined,
                                title: 'Baseado na sua biblioteca',
                                subtitle: 'Você pode gostar desses jogos',
                                isMobile: isMobile,
                              ),
                              const SizedBox(height: 12),
                              ..._fromLibrary.map((rec) => _RecommendationGroup(
                                    sourceName: rec['sourceName'] ?? '',
                                    games: List<Map<String, dynamic>>.from(rec['games'] ?? []),
                                    isMobile: isMobile,
                                  )),
                            ],
                          ],
                        ),
                      ),
      ),
    );
  }

  Widget _emptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: 400,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.recommend_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text('Sem recomendações ainda',
                    style: GoogleFonts.majorMonoDisplay(fontSize: 18, color: Colors.grey[500])),
                const SizedBox(height: 8),
                Text(
                  'Adicione jogos à sua biblioteca ou registre partidas para receber recomendações personalizadas.',
                  style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.6),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section Header ─────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isMobile;
  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 98, 147, 175).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color.fromARGB(255, 98, 147, 175), size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recommendation Group ───────────────────────────────────────────────────────

class _RecommendationGroup extends StatelessWidget {
  final String sourceName;
  final List<Map<String, dynamic>> games;
  final bool isMobile;
  const _RecommendationGroup({
    required this.sourceName,
    required this.games,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, 16, isMobile ? 16 : 32, 8),
          child: Row(
            children: [
              const Icon(Icons.subdirectory_arrow_right, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Porque você jogou "$sourceName"',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
            itemCount: games.length,
            itemBuilder: (context, i) => _GameCard(game: games[i]),
          ),
        ),
      ],
    );
  }
}

// ── Game Card ──────────────────────────────────────────────────────────────────

class _GameCard extends StatefulWidget {
  final Map<String, dynamic> game;
  const _GameCard({required this.game});

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GamePage(
              id: widget.game['id'],
              name: widget.game['name'] ?? '',
            ),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_hovering ? 0.12 : 0.06),
                blurRadius: _hovering ? 16 : 8,
                offset: Offset(0, _hovering ? 6 : 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: SizedBox(
                  height: 130,
                  width: double.infinity,
                  child: Image.network(
                    ApiService.proxyImage(widget.game['thumbnail'] ?? ''),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, color: Colors.grey),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.game['name'] ?? '',
                      style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 11),
                        const SizedBox(width: 2),
                        Text(
                          widget.game['rating'] ?? '',
                          style: TextStyle(color: Colors.grey[600], fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}