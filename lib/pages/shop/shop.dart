import 'dart:convert';
import 'dart:js_interop';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';
import 'package:web/web.dart' as web;

class Shop extends StatefulWidget {
  const Shop({super.key});

  @override
  State<Shop> createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  static const String _baseUrl = 'https://hexa-tracker-server.azurewebsites.net';
  //static const String _baseUrl = 'http://localhost:3000';

  List<Map<String, dynamic>> _shops = [];
  bool _loading = false;
  bool _locationDenied = false;
  double? _userLat;
  double? _userLng;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  void _getLocation() {
    setState(() { _loading = true; _locationDenied = false; _error = null; });

    web.window.navigator.geolocation.getCurrentPosition(
      (web.GeolocationPosition pos) {
        final lat = pos.coords.latitude;
        final lng = pos.coords.longitude;
        _userLat = lat;
        _userLng = lng;
        _fetchShops(lat, lng);
      }.toJS,
      (web.GeolocationPositionError err) {
        setState(() { _loading = false; _locationDenied = true; });
      }.toJS,
    );
  }

  Future<void> _fetchShops(double lat, double lng) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/shop/nearby?lat=$lat&lng=$lng&radius=10000'),
      );
      if (response.statusCode != 200) throw Exception('Erro ${response.statusCode}');
      final List<dynamic> data = jsonDecode(response.body);
      setState(() {
        _shops = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  String _formatDistance(int meters) {
    if (meters < 1000) return '${meters}m';
    return '${(meters / 1000).toStringAsFixed(1)}km';
  }

  void _openMap(double lat, double lng, String name) {
    final url = 'https://www.openstreetmap.org/?mlat=$lat&mlon=$lng&zoom=17&layers=M';
    web.window.open(url, '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppScaffold(
      backgroundColor: Colors.grey[100]!,
      body: _buildBody(isMobile),
    );
  }

  Widget _buildBody(bool isMobile) {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Buscando lojas próximas...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (_locationDenied) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Localização negada',
                  style: GoogleFonts.majorMonoDisplay(fontSize: 18, color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text(
                'Permita o acesso à sua localização no navegador para encontrar lojas próximas.',
                style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _getLocation,
                icon: const Icon(Icons.my_location),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 147, 175),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Erro ao buscar lojas', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: () {
              if (_userLat != null && _userLng != null) _fetchShops(_userLat!, _userLng!);
            }, child: const Text('Tentar novamente')),
          ],
        ),
      );
    }

    if (_shops.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.store_outlined, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text('Nenhuma loja encontrada',
                  style: GoogleFonts.majorMonoDisplay(fontSize: 18, color: Colors.grey[600])),
              const SizedBox(height: 8),
              Text(
                'Não encontramos lojas de jogos num raio de 10km.\nTente ampliar a busca.',
                style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  if (_userLat != null && _userLng != null) {
                    setState(() => _loading = true);
                    _fetchShops(_userLat!, _userLng!);
                  }
                },
                icon: const Icon(Icons.search),
                label: const Text('Buscar em raio maior'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 98, 147, 175),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(isMobile ? 16 : 32, isMobile ? 20 : 32, isMobile ? 16 : 32, 8),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Lojas Próximas',
                      style: GoogleFonts.majorMonoDisplay(fontSize: isMobile ? 22 : 28)),
                  const SizedBox(height: 4),
                  Text('${_shops.length} lojas encontradas num raio de 10km',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _getLocation,
                tooltip: 'Atualizar localização',
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 32,
              vertical: 8,
            ),
            itemCount: _shops.length,
            itemBuilder: (context, i) => _ShopCard(
              shop: _shops[i],
              isMobile: isMobile,
              formatDistance: _formatDistance,
              onOpenMap: _openMap,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shop Card ──────────────────────────────────────────────────────────────────

class _ShopCard extends StatelessWidget {
  final Map<String, dynamic> shop;
  final bool isMobile;
  final String Function(int) formatDistance;
  final void Function(double, double, String) onOpenMap;

  const _ShopCard({
    required this.shop,
    required this.isMobile,
    required this.formatDistance,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final lat = (shop['lat'] as num).toDouble();
    final lng = (shop['lng'] as num).toDouble();
    final name = shop['name'] as String;
    final distance = shop['distance'] as int;
    final address = shop['address'] as String?;
    final phone = shop['phone'] as String?;
    final website = shop['website'] as String?;
    final hours = shop['opening_hours'] as String?;
    final type = shop['type'] as String? ?? 'games';

    final typeLabel = switch (type) {
      'toy' => 'Loja de brinquedos',
      'hobby' => 'Loja de hobbies',
      _ => 'Loja de jogos',
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 8,
          offset: const Offset(0, 3),
        )],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 98, 147, 175).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store,
                      color: Color.fromARGB(255, 98, 147, 175), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(typeLabel,
                                style: TextStyle(color: Colors.grey[600], fontSize: 11)),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.near_me, size: 12, color: Colors.grey[400]),
                          const SizedBox(width: 3),
                          Text(formatDistance(distance),
                              style: TextStyle(
                                  color: distance < 2000
                                      ? Colors.green[600]
                                      : Colors.grey[500],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (address != null || phone != null || hours != null) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              if (address != null)
                _infoRow(Icons.location_on_outlined, address),
              if (phone != null)
                _infoRow(Icons.phone_outlined, phone),
              if (hours != null)
                _infoRow(Icons.access_time_outlined, hours),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => onOpenMap(lat, lng, name),
                    icon: const Icon(Icons.map_outlined, size: 16),
                    label: const Text('Ver no mapa'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 98, 147, 175),
                      side: const BorderSide(color: Color.fromARGB(255, 98, 147, 175)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                if (website != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => web.window.open(website, '_blank'),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Site'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 98, 147, 175),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: Colors.grey[400]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ),
        ],
      ),
    );
  }
}