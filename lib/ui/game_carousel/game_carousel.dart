
import 'package:flutter/material.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:hexa_tracker/ui/game_page/game_page.dart';

class GameCarousel extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<String> ids;

  const GameCarousel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.ids,
  });

  @override
  State<GameCarousel> createState() => _GameCarouselState();
}

class _GameCarouselState extends State<GameCarousel> {
  List<Map<String, String>> games = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    final loaded = await ApiService.getBatchGames(widget.ids);
    setState(() {
      games = loaded;
      isLoading = false;
    });
  }

  void _scrollLeft() {
    _scrollController.animateTo(
      _scrollController.offset - 600,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _scrollRight() {
    _scrollController.animateTo(
      _scrollController.offset + 600,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                onPressed: _scrollLeft,
                icon: Icon(Icons.arrow_back_ios),
              ),
              IconButton(
                onPressed: _scrollRight,
                icon: Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
        isLoading
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                height: 220,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => GamePage(
                              id: game['id']!,
                              name: game['name']!,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: 200,
                        margin: EdgeInsets.only(right: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                ApiService.proxyImage(game['image']!),
                                width: 200,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 200,
                                  height: 150,
                                  color: Colors.grey[300],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              game['name']!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }
}