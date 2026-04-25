import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:hexa_tracker/ui/hot_carousel/hot_carousel.dart';
import 'package:hexa_tracker/ui/best_sellers_carousel/best_sellers_carousel.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, String>> games = [];
  bool isLoading = false;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  Future<void> _searchGames(String query) async {
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        games = [];
      });
      return;
    }
    setState(() => isLoading = true);
    final loaded = await ApiService.searchGames(query);
    setState(() {
      games = loaded;
      isLoading = false;
      isSearching = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          NavigationBarr(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Row(
              children: [
                Text(
                  isSearching ? "Resultados" : "Games",
                  style: GoogleFonts.majorMonoDisplay(fontSize: 36),
                ),
                Spacer(),
                SearchBar(
                  controller: _searchController,
                  leading: Icon(Icons.search),
                  hintText: 'search',
                  elevation: WidgetStateProperty.all(0),
                  constraints: BoxConstraints.loose(Size(400, 50)),
                  onSubmitted: (value) => _searchGames(value),
                  trailing: [
                    if (isSearching)
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            isSearching = false;
                            games = [];
                          });
                        },
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : isSearching
                    ? games.isEmpty
                        ? Center(child: Text('Nenhum jogo encontrado'))
                        : GridView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 5,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 200 / 150,
                            ),
                            itemCount: games.length,
                            itemBuilder: (context, index) {
                              final game = games[index];
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Image.network(
                                      ApiService.proxyImage(game['image']!),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) =>
                                          Container(color: Colors.grey[300]),
                                    ),
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              Colors.transparent,
                                              Colors.black.withOpacity(0.75),
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          game['name']!,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            HotCarousel(),
                            Padding(
  padding: EdgeInsets.symmetric(horizontal: 32),
  child: Divider(color: Colors.grey[300], thickness: 1),
),
                            BestSellersCarousel(),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}