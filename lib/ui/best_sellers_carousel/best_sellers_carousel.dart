import 'package:flutter/material.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:google_fonts/google_fonts.dart';
class BestSellersCarousel extends StatefulWidget {
  const BestSellersCarousel({super.key});

  @override
  State<BestSellersCarousel> createState() => _BestSellersCarouselState();
}

class _BestSellersCarouselState extends State<BestSellersCarousel> {
  List<Map<String, String>> games = [];
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  final List<String> bestSellerIds = [
    '452264', '420087', '436217', '373106', '414317',
    '434367', '266192', '230802', '421006', '413246',
    '224517', '13', '401636', '456440', '366013', '424981',
  ];

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
  final loaded = await ApiService.getBatchGames(bestSellerIds);
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
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 5),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'best sellers',
                    style: GoogleFonts.majorMonoDisplay(fontSize: 24),
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
        isLoading && games.isEmpty
            ? Center(child: CircularProgressIndicator())
            : SizedBox(
                height: 280,
                child: ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 32),
                  itemCount: games.length,
                  itemBuilder: (context, index) {
                    final game = games[index];
                    return Container(
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
                    );
                  },
                ),
              ),
      ],
    );
  }
}