import 'package:flutter/material.dart';
import 'package:hexa_tracker/pages/friends/friends.dart';
import 'package:hexa_tracker/pages/home/home.dart';
import 'package:hexa_tracker/pages/library/library.dart';
import 'package:hexa_tracker/pages/login/login.dart';
import 'package:hexa_tracker/pages/recomendations/recommendations.dart';
import 'package:hexa_tracker/pages/shop/shop.dart';
import 'package:hexa_tracker/pages/winrate/winrate.dart';
import 'services/auth_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "HexaTracker",
      theme: ThemeData(
        primaryColor: Colors.amber,
      ),
      routes: {
        '/': (context) => const AuthGate(),
        '/Home': (context) => const Home(),
        '/Recommendations': (context) => const Recommendation(),
        '/WinRate': (context) => const WinRate(),
        '/Shop': (context) => const Shop(),
        '/Library': (context) => const Library(),
        '/Friends': (context) => const Friends(),
        '/Login': (context) => const LoginScreen(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data == true) {
          return const Home();
        }
        return const LoginScreen();
      },
    );
  }
}