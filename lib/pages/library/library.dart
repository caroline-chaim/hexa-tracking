import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/services/library_service.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  List<Map<String, String>> _games = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    final games = await LibraryService.getLibrary();
    setState(() { _games = games; _loading = false; });
  }

  Future<void> _removeGame(String id) async {
    await LibraryService.removeGame(id);
    await _loadLibrary();
  }

  Future<void> _confirmRemove(BuildContext context, String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover jogo'),
        content: Text('Remover "$name" da biblioteca?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) _removeGame(id);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppScaffold(
      backgroundColor: const Color.fromARGB(255, 245, 245, 245),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
              ? _emptyState(isMobile)
              : _gameGrid(isMobile),
    );
  }

  Widget _emptyState(bool isMobile) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.library_books_outlined, size: isMobile ? 48 : 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Sua biblioteca está vazia',
              style: GoogleFonts.majorMonoDisplay(fontSize: isMobile ? 16 : 20, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Adicione jogos clicando em "Adicionar à Biblioteca"\nna página de detalhes de um jogo.',
              style: TextStyle(color: Colors.grey[500], fontSize: isMobile ? 13 : 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _gameGrid(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, isMobile ? 20 : 32, isMobile ? 16 : 32, 16),
          child: Row(
            children: [
              Flexible(
                child: Text(
                  'Minha Biblioteca',
                  style: GoogleFonts.majorMonoDisplay(fontSize: isMobile ? 18 : 24),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue[700], borderRadius: BorderRadius.circular(20)),
                child: Text('${_games.length}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 24),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 2 : 4,
                crossAxisSpacing: isMobile ? 10 : 16,
                mainAxisSpacing: isMobile ? 10 : 16,
                childAspectRatio: 0.72,
              ),
              itemCount: _games.length,
              itemBuilder: (context, index) => _GameCard(
                game: _games[index],
                isMobile: isMobile,
                onRemove: () => _confirmRemove(context, _games[index]['id']!, _games[index]['name'] ?? ''),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _GameCard extends StatefulWidget {
  final Map<String, String> game;
  final VoidCallback onRemove;
  final bool isMobile;
  const _GameCard({required this.game, required this.onRemove, required this.isMobile});

  @override
  State<_GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<_GameCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final showRemove = widget.isMobile || _hovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_hovering ? 0.12 : 0.06),
              blurRadius: _hovering ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Image.network(
                      ApiService.proxyImage(widget.game['thumbnail'] ?? ''),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[200], child: const Icon(Icons.image_not_supported, color: Colors.grey)),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(widget.isMobile ? 8 : 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game['name'] ?? '',
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: widget.isMobile ? 12 : 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 13),
                          const SizedBox(width: 3),
                          Text(widget.game['rating'] ?? '',
                              style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                          const Spacer(),
                          Text(widget.game['yearpublished'] ?? '',
                              style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (showRemove)
              Positioned(
                top: 6, right: 6,
                child: GestureDetector(
                  onTap: widget.onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red[600],
                      shape: BoxShape.circle,
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}