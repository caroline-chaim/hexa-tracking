import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/services/auth_service.dart';

// ── AppScaffold ────────────────────────────────────────────────────────────────
// Use este widget em vez de Scaffold nas telas que têm navigation bar.
// Ele já inclui o drawer mobile automaticamente.

class AppScaffold extends StatelessWidget {
  final Widget body;
  final Color backgroundColor;

  const AppScaffold({
    super.key,
    required this.body,
    this.backgroundColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: _MobileDrawer(),
      body: Column(
        children: [
          const NavigationBarr(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

// ── Drawer mobile ──────────────────────────────────────────────────────────────

class _MobileDrawer extends StatefulWidget {
  @override
  State<_MobileDrawer> createState() => _MobileDrawerState();
}

class _MobileDrawerState extends State<_MobileDrawer> {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadAuth();
  }

  Future<void> _loadAuth() async {
    final loggedIn = await AuthService.isLoggedIn();
    final user = await AuthService.getUser();
    if (mounted) setState(() { _isLoggedIn = loggedIn; _user = user; });
  }

  Future<void> _logout() async {
    await AuthService.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/Login');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color.fromARGB(255, 158, 179, 194),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com info do usuário
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: const Color.fromARGB(255, 130, 158, 178),
              child: _isLoggedIn && _user != null
                  ? Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color.fromARGB(255, 98, 147, 175),
                          backgroundImage: _user!['photoUrl'] != null
                              ? NetworkImage(_user!['photoUrl'])
                              : null,
                          child: _user!['photoUrl'] == null
                              ? Text(
                                  (_user!['displayName'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontSize: 18),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _user!['displayName'] ?? '',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _user!['email'] ?? '',
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Hexa Tracker',
                      style: GoogleFonts.majorMonoDisplay(fontSize: 18),
                    ),
            ),

            const SizedBox(height: 8),

            // Itens de navegação
            _DrawerItem(icon: Icons.home_outlined, title: 'Home', route: '/'),
            _DrawerItem(icon: Icons.recommend_outlined, title: 'Recommendations', route: '/Recommendations'),
            _DrawerItem(icon: Icons.bar_chart, title: 'WinRate', route: '/WinRate'),
            _DrawerItem(icon: Icons.store_outlined, title: 'Shop', route: '/Shop'),
            _DrawerItem(icon: Icons.library_books_outlined, title: 'Library', route: '/Library'),
            _DrawerItem(icon: Icons.people_outline, title: 'Friends', route: '/Friends'),

            const Divider(color: Colors.black12, height: 32),

            // Login / Logout
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.black87),
                title: Text('Log Out', style: GoogleFonts.lato(fontSize: 15, color: Colors.black87)),
                onTap: _logout,
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.black87),
                title: Text('Log In', style: GoogleFonts.lato(fontSize: 15, color: Colors.black87)),
                onTap: () => Navigator.pushNamed(context, '/Login'),
              ),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Colors.black87),
                title: Text('Create Account', style: GoogleFonts.lato(fontSize: 15, color: Colors.black87)),
                onTap: () => Navigator.pushNamed(context, '/Login'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String route;
  const _DrawerItem({required this.icon, required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    final current = ModalRoute.of(context)?.settings.name;
    final isActive = current == route || (route == '/' && current == '/Home');

    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.black : Colors.black54),
      title: Text(
        title,
        style: GoogleFonts.lato(
          fontSize: 15,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.black : Colors.black87,
        ),
      ),
      tileColor: isActive ? Colors.black.withOpacity(0.08) : null,
      onTap: () {
        Navigator.pop(context); // fecha o drawer
        Navigator.pushNamed(context, route);
      },
    );
  }
}

// ── Navigation Bar ─────────────────────────────────────────────────────────────

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
        Text("Hexa Tracking", style: GoogleFonts.majorMonoDisplay(fontSize: 24)),
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
        Text("Hexa Tracking", style: GoogleFonts.majorMonoDisplay(fontSize: 16)),
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

// ── Auth Buttons ───────────────────────────────────────────────────────────────

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
    if (mounted) setState(() { _isLoggedIn = loggedIn; _user = user; });
  }

  Future<void> _handleLogout(BuildContext context) async {
    await AuthService.signOut();
    if (context.mounted) Navigator.pushReplacementNamed(context, '/Login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoggedIn && _user != null) {
      return Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color.fromARGB(255, 98, 147, 175),
            backgroundImage: _user!['photoUrl'] != null ? NetworkImage(_user!['photoUrl']) : null,
            child: _user!['photoUrl'] == null
                ? Text((_user!['displayName'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 14))
                : null,
          ),
          const SizedBox(width: 8),
          Text(_user!['displayName']?.split(' ').first ?? '',
              style: GoogleFonts.lato(fontSize: 15, color: Colors.black87)),
          const SizedBox(width: 16),
          TextButton(
            onPressed: () => _handleLogout(context),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black45),
                borderRadius: BorderRadius.circular(4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: const Row(
                children: [
                  Text("Log Out", style: TextStyle(fontSize: 16, color: Colors.black87)),
                  SizedBox(width: 8),
                  Icon(Icons.logout, color: Colors.black87, size: 20),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/Login'),
          child: Container(
            color: const Color.fromARGB(255, 253, 254, 255),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 3),
            child: const Row(
              children: [
                Text("Log In", style: TextStyle(fontSize: 20, color: Colors.black)),
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
                Text("Create Account", style: TextStyle(fontSize: 20, color: Colors.white)),
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