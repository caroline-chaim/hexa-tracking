import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/services/api_service.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _nomeJogo = '';
  String _imagemUrl = '';
  bool _carregando = false;

  Future<void> _buscarJogo() async {
    setState(() => _carregando = true);
    try {
      final response = await ApiService.get('/thing?id=35424');
      final json = jsonDecode(response.body);

    setState(() {
      _nomeJogo = json['item']['primaryname']['name'] ?? 'Nome não encontrado';
      _imagemUrl = json['item']['imageurl'] ?? '';
    });
    } catch (e) {
      setState(() => _nomeJogo = 'Erro: $e');
    } finally {
      setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          NavigationBarr(),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    margin: EdgeInsetsDirectional.only(start: 100, top: 50),
                    child: Row(
                      children: [
                        Text(
                          "Games",
                          style: GoogleFonts.majorMonoDisplay(fontSize: 36),
                        ),
                        SizedBox(width: 200),
                        SearchBar(
                          leading: Icon(Icons.search),
                          hintText: 'search',
                          elevation: WidgetStateProperty.all(0),
                          constraints: BoxConstraints.loose(Size(400, 50)),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _carregando ? null : _buscarJogo,
                    child: _carregando
                        ? CircularProgressIndicator()
                        : Text('Buscar Jogo'),
                  ),

                  SizedBox(height: 20),

                  // CARD DO JOGO
                  if (_imagemUrl != '')
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
  ApiService.imagemUrl(_imagemUrl),
  width: 200,
  height: 250,
  fit: BoxFit.cover,
),
                        ),
                        SizedBox(height: 10),
                        Text(
                          _nomeJogo,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

              Container(
                color: Color.fromARGB(255, 28, 113, 147),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.only(left: 30, right: 50, top: 10),
                margin: EdgeInsetsDirectional.only(end: 20, top: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text("Best Games", style: TextStyle(color: Colors.white)),
                        SizedBox(width: 100),
                        Text("Victories", style: TextStyle(color: Colors.white)),
                      ],
                    ),
                    Text("coisa"),
                    Text("Recent Games", style: TextStyle(color: Colors.white)),
                    Text("coisa"),
                    Text("Most Played", style: TextStyle(color: Colors.white)),
                    Text("coisa"),
                    Text("coisa"),
                    Text("coisa"),
                    Text("coisa"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}