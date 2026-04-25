import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/services/api_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    final data = await ApiService.getGameFullDetails(widget.id);
    setState(() {
      details = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(32),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagem
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      ApiService.proxyImage(details!['image']!),
                      width: 220,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(width: 220, height: 180, color: Colors.grey[300]),
                    ),
                  ),
                  SizedBox(width: 32),

                  // Detalhes
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rank
                        Text(
                          'RANK: OVERALL  ${details!['rank']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 8),

                        // Nome e ano
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              details!['name']!,
                              style: GoogleFonts.majorMonoDisplay(fontSize: 28),
                            ),
                            SizedBox(width: 8),
                            Padding(
                              padding: EdgeInsets.only(bottom: 4),
                              child: Text(
                                '(${details!['yearpublished']})',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),

                        // Rating
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[700],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                details!['rating']!,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        // Stats
                        Row(
                          children: [
                            _statBox(
                              '${details!['minplayers']}–${details!['maxplayers']} Players',
                              'Min/Max Players',
                            ),
                            SizedBox(width: 16),
                            _statBox(
                              '${details!['minplaytime']}–${details!['maxplaytime']} Min',
                              'Playing Time',
                            ),
                            SizedBox(width: 16),
                            _statBox(
                              'Age: ${details!['minage']}+',
                              'Minimum Age',
                            ),
                            SizedBox(width: 16),
                            _statBox(
                              'Weight: ${details!['weight']} / 5',
                              'Complexity',
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Descrição
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          details!['description']!
                              .replaceAll('&mdash;', '—')
                              .replaceAll('&ldquo;', '"')
                              .replaceAll('&rdquo;', '"')
                              .replaceAll('&#10;', '\n'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statBox(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }
}