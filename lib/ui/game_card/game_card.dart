import 'package:flutter/material.dart';
import 'package:hexa_tracker/services/api_service.dart';

class GameCard extends StatefulWidget {
  final Map<String, String> game;
  const GameCard({super.key, required this.game});

  @override
  State<GameCard> createState() => _GameCardState();
}

class _GameCardState extends State<GameCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.3 : 0.1),
              blurRadius: _isHovered ? 16 : 8,
              offset: Offset(0, _isHovered ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 150,
            width: 200,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagem
                AnimatedScale(
                  scale: _isHovered ? 1.05 : 1.0,
                  duration: Duration(milliseconds: 200),
                  child: Image.network(
                    ApiService.proxyImage(widget.game['image']!),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: Colors.grey[300]),
                  ),
                ),

                // Gradiente escuro na parte de baixo
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.75),
                        ],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // Nome sobre a imagem
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Text(
                    widget.game['name']!,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),

                // Overlay escuro no hover
                AnimatedOpacity(
                  opacity: _isHovered ? 0.15 : 0.0,
                  duration: Duration(milliseconds: 200),
                  child: Container(color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}