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
    final isMobile = MediaQuery.of(context).size.width < 600;

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
              padding: EdgeInsets.all(isMobile ? 16 : 32),
              child: isMobile
                  ? _mobileLayout(context)
                  : _desktopLayout(context),
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
            width: 220,
            height: 180,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(width: 220, height: 180, color: Colors.grey[300]),
          ),
        ),
        SizedBox(width: 32),
        Expanded(child: _detailsColumn(false)),
      ],
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              ApiService.proxyImage(details!['image']!),
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: double.infinity, height: 220, color: Colors.grey[300]),
            ),
          ),
        ),
        SizedBox(height: 24),
        _detailsColumn(true),
      ],
    );
  }

  Widget _detailsColumn(bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RANK: OVERALL  ${details!['rank']}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 8),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.end,
          spacing: 8,
          children: [
            Text(
              details!['name']!,
              style: GoogleFonts.majorMonoDisplay(fontSize: isMobile ? 20 : 28),
            ),
            Text(
              '(${details!['yearpublished']})',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
        SizedBox(height: 16),
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
        SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _statBox('${details!['minplayers']}–${details!['maxplayers']} Players', 'Min/Max Players'),
            _statBox('${details!['minplaytime']}–${details!['maxplaytime']} Min', 'Playing Time'),
            _statBox('Age: ${details!['minage']}+', 'Minimum Age'),
            _statBox('Weight: ${details!['weight']} / 5', 'Complexity'),
          ],
        ),
        SizedBox(height: 24),
        Text(
          'Description',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 8),
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
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}