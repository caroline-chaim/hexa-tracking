import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:hexa_tracker/ui/hot_carousel/hot_carousel.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';
import 'package:hexa_tracker/ui/game_carousel/game_carousel.dart';
import 'package:hexa_tracker/ui/game_page/game_page.dart';

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          NavigationBarr(),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 16 : 32,
              vertical: isMobile ? 12 : 20,
            ),
            child: isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isSearching ? "Resultados" : "Games",
                        style: GoogleFonts.majorMonoDisplay(fontSize: 24),
                      ),
                      SizedBox(height: 12),
                      SearchBar(
                        controller: _searchController,
                        leading: Icon(Icons.search),
                        hintText: 'search',
                        elevation: WidgetStateProperty.all(0),
                        constraints: BoxConstraints(
                          maxWidth: double.infinity,
                          maxHeight: 50,
                        ),
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
                  )
                : Row(
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
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 16 : 32,
                            ),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: isMobile ? 2 : 5,
                              crossAxisSpacing: isMobile ? 8 : 16,
                              mainAxisSpacing: isMobile ? 8 : 16,
                              childAspectRatio: 200 / 150,
                            ),
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
                                child: ClipRRect(
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
                                ),
                              );
                            },
                          )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            HotCarousel(),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                              child: Divider(color: Colors.grey[300], thickness: 1),
                            ),
                            GameCarousel(
                              title: 'BEST SELLERS',
                              subtitle: 'Top games this week',
                              ids: ['452264', '420087', '436217', '373106', '414317',
                                    '434367', '266192', '230802', '421006', '413246',
                                    '224517', '13', '401636', '456440', '366013', '424981'],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                              child: Divider(color: Colors.grey[300], thickness: 1),
                            ),
                            GameCarousel(
                              title: 'PARTY GAMES',
                              subtitle: 'Best games to play with friends',
                              ids: ['188834', '2223', '226610', '39856', '262543', '172225',
                                    '32471', '240980', '225694', '254640', '178900', '128882'],
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 32),
                              child: Divider(color: Colors.grey[300], thickness: 1),
                            ),
                            GameCarousel(
                              title: 'MEMORY GAMES',
                              subtitle: 'Best memory games to play',
                              ids: ['352515', '98778', '355483', '190082', '375651', '164265',
                                    '41916', '424975', '49', '230383', '28089', '36648',
                                    '231999', '2266', '231197', '12346'],
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}