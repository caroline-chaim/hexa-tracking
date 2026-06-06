import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  bool _loading = false;
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _floatAnimation = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _loading = true);
    final user = await AuthService.signInWithGoogle();
    setState(() => _loading = false);

    if (user != null && mounted) {
      Navigator.pushReplacementNamed(context, '/Home');
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Erro ao fazer login. Tente novamente.',
              style: TextStyle(color: Color(0xFF0D1117))),
          backgroundColor: const Color(0xFFE8F0FE),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final titleSize = isMobile ? 36.0 : 52.0;
    final logoSize = isMobile ? 60.0 : 80.0;
    final spacingLarge = isMobile ? 28.0 : 56.0;
    final spacingMed = isMobile ? 24.0 : 40.0;

    return Scaffold(
      backgroundColor: const Color(0xFF9EB3C2),
      body: Stack(
        children: [
          const Positioned.fill(child: _HexBackground()),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile ? 24 : 32,
                      vertical: 48,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _floatAnimation,
                          builder: (context, child) => Transform.translate(
                            offset: Offset(0, _floatAnimation.value),
                            child: child,
                          ),
                          child: _HexLogo(size: logoSize),
                        ),
                        SizedBox(height: isMobile ? 24 : 40),
                        Text(
                          'HEXA',
                          style: GoogleFonts.majorMonoDisplay(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF0D1117),
                            letterSpacing: isMobile ? 8 : 12,
                            height: 1,
                          ),
                        ),
                        Text(
                          'TRACKER',
                          style: GoogleFonts.majorMonoDisplay(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF0D1117),
                            letterSpacing: isMobile ? 8 : 12,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'rastreie seus jogos de tabuleiro',
                          style: GoogleFonts.spaceMono(
                            fontSize: isMobile ? 10 : 11,
                            color: const Color(0xFF0D1117).withOpacity(0.35),
                            letterSpacing: isMobile ? 1 : 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: spacingLarge),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Color(0x22000000)],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('◆',
                                  style: TextStyle(color: Color(0xFF0D1117), fontSize: 8)),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0x22000000), Colors.transparent],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: spacingMed),
                        _loading
                            ? const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0D1117),
                                  strokeWidth: 2,
                                ),
                              )
                            : _GoogleButton(onPressed: _handleLogin),
                        SizedBox(height: spacingMed),
                        Text(
                          'ao entrar, você concorda com os termos de uso',
                          style: GoogleFonts.spaceMono(
                            fontSize: 10,
                            color: const Color(0xFF0D1117).withOpacity(0.25),
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _GoogleButton({required this.onPressed});

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _hovering
                  ? const Color(0xFF0D1117)
                  : Colors.white.withOpacity(0.12),
              width: 1,
            ),
            color: _hovering
                ? const Color(0xFF0D1117).withOpacity(0.08)
                : Colors.white.withOpacity(0.04),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _GoogleColorIcon(),
              const SizedBox(width: 14),
              Text(
                'Entrar com Google',
                style: GoogleFonts.spaceMono(
                  fontSize: 13,
                  color: _hovering ? const Color(0xFF0D1117) : const Color(0xFF0D1117).withOpacity(0.7),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleColorIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2;
    final strokeW = size.width * 0.22;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.butt;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeW / 2),
        -math.pi * 0.3, math.pi * 0.9, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeW / 2),
        -math.pi * 1.2, math.pi * 0.9, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeW / 2),
        math.pi * 0.6, math.pi * 0.6, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r - strokeW / 2),
        math.pi * 0.6, -math.pi * 0.6, false, paint);
    paint
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(cx, cy - strokeW / 2, r * 0.85, strokeW),
      paint,
    );
    paint.color = const Color(0xFF9EB3C2);
    canvas.drawCircle(Offset(cx, cy), r * 0.48, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _HexLogo extends StatelessWidget {
  final double size;
  const _HexLogo({this.size = 80});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _HexLogoPainter()),
    );
  }
}

class _HexLogoPainter extends CustomPainter {
  Path _hexPath(Offset center, double r) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 2;
    final outerPath = _hexPath(center, r * 0.93);
    final innerPath = _hexPath(center, r * 0.55);

    canvas.drawPath(outerPath, Paint()
      ..color = const Color(0xFF0D1117).withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14));
    canvas.drawPath(outerPath, Paint()
      ..color = const Color(0xFF0D1117)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5);
    canvas.drawPath(innerPath, Paint()
      ..color = const Color(0xFF0D1117).withOpacity(0.12)
      ..style = PaintingStyle.fill);
    canvas.drawPath(innerPath, Paint()
      ..color = const Color(0xFF0D1117).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1);
    canvas.drawCircle(center, 3, Paint()..color = const Color(0xFF0D1117).withOpacity(0.8));
  }

  @override
  bool shouldRepaint(_) => false;
}

class _HexBackground extends StatelessWidget {
  const _HexBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _HexBackgroundPainter(), size: Size.infinite);
  }
}

class _HexBackgroundPainter extends CustomPainter {
  void _drawHex(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 30) * math.pi / 180;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;
    final hexes = [
      (Offset(size.width * 0.07, size.height * 0.10), 65.0, 0.05),
      (Offset(size.width * 0.88, size.height * 0.07), 90.0, 0.04),
      (Offset(size.width * 0.93, size.height * 0.72), 55.0, 0.05),
      (Offset(size.width * 0.04, size.height * 0.84), 75.0, 0.04),
      (Offset(size.width * 0.72, size.height * 0.45), 42.0, 0.03),
      (Offset(size.width * 0.18, size.height * 0.52), 110.0, 0.03),
      (Offset(size.width * 0.55, size.height * 0.88), 48.0, 0.04),
    ];
    for (final (pos, r, opacity) in hexes) {
      paint.color = Color(0xFF0D1117).withOpacity(opacity);
      _drawHex(canvas, pos, r, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}