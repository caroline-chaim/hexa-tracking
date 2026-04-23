import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:hexa_tracker/ui/game_card/game_card.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Map<String, String>> games = [];
  bool isLoading = true;
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadHotGames();
  }

  Future<void> _loadHotGames() async {
    setState(() => isLoading = true);
    final loaded = await ApiService.getHotGames();
    setState(() {
      games = loaded;
      isLoading = false;
      isSearching = false;
    });
  }

  Future<void> _searchGames(String query) async {
    if (query.isEmpty) {
      _loadHotGames();
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
                          _loadHotGames();
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
                : games.isEmpty
                    ? Center(child: Text('Nenhum jogo encontrado'))
                    : GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 32),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 200 / 150,
                        ),
                        itemCount: games.length,
                        itemBuilder: (context, index) {
                          return GameCard(game: games[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}