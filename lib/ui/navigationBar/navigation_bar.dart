import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/auth_service.dart';

class NavigationBarr extends StatelessWidget {
  const NavigationBarr({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: const Color.fromARGB(255, 158, 179, 194),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: isMobile ? 60 : 70,
      child: isMobile ? _mobileBar(context) : _desktopBar(context),
    );
  }

  Widget _desktopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          "Hexa Tracking",
          style: GoogleFonts.majorMonoDisplay(fontSize: 24),
        ),
        Row(
          children: [
            _NavBarItem("Home"),
            const SizedBox(width: 30),
            _NavBarItem("Recommendations"),
            const SizedBox(width: 30),
            _NavBarItem("WinRate"),
            const SizedBox(width: 30),
            _NavBarItem("Shop"),
            const SizedBox(width: 30),
            _NavBarItem("Library"),
            const SizedBox(width: 30),
            _NavBarItem("Friends"),
          ],
        ),
        _AuthButtons(),
      ],
    );
  }

  Widget _mobileBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Hexa Tracking",
          style: GoogleFonts.majorMonoDisplay(fontSize: 16),
        ),
        Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }
}

// ── Botões de autenticação (Login / Logout) ────────────────────────────────────

class _AuthButtons extends StatefulWidget {
  @override
  State<_AuthButtons> createState() => _AuthButtonsState();
}

class _AuthButtonsState extends State<_AuthButtons> {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    final loggedIn = await AuthService.isLoggedIn();
    final user = await AuthService.getUser();
    if (mounted) {
      setState(() {
        _isLoggedIn = loggedIn;
        _user = user;
      });
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.signOut();
    if (context.mounted) {
      Navigator.pushReplacementNamed(context, '/Login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn && _user != null) {
      // Usuário logado — mostra nome/foto e botão de logout
      return Row(
        children: [
          // Avatar ou inicial
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color.fromARGB(255, 98, 147, 175),
            backgroundImage: _user!['photoUrl'] != null
                ? NetworkImage(_user!['photoUrl'])
                : null,
            child: _user!['photoUrl'] == null
                ? Text(
                    (_user!['displayName'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            _user!['displayName']?.split(' ').first ?? '',
            style: GoogleFonts.lato(fontSize: 15, color: Colors.black87),
          ),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => _handleLogout(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black45),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  const Text("Log Out",
                      style: TextStyle(fontSize: 16, color: Colors.black87)),
                  const SizedBox(width: 8),
                  const Icon(Icons.logout, color: Colors.black87, size: 20),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Usuário deslogado — mostra Log In e Create Account
    return Row(
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/Login'),
          child: Container(
            color: const Color.fromARGB(255, 253, 254, 255),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
            child: const Row(
              children: [
                Text("Log In",
                    style: TextStyle(fontSize: 20, color: Colors.black)),
                SizedBox(width: 10),
                Icon(Icons.person_outline, color: Colors.black, size: 30),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/Login'),
          child: Container(
            color: const Color.fromARGB(255, 98, 147, 175),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
            child: const Row(
              children: [
                Text("Create Account",
                    style: TextStyle(fontSize: 20, color: Colors.white)),
                SizedBox(width: 10),
                Icon(Icons.add_circle_outline, color: Colors.white, size: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Nav Item ───────────────────────────────────────────────────────────────────

class _NavBarItem extends StatelessWidget {
  final String title;
  const _NavBarItem(this.title);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(foregroundColor: Colors.black),
      onPressed: () {
        if (title == 'Home') {
          Navigator.pushNamed(context, '/');
        } else {
          Navigator.pushNamed(context, '/$title');
        }
      },
      child: Text(title, style: GoogleFonts.lato(fontSize: 16)),
    );
  }
}