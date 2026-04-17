import 'package:flutter/material.dart';
import 'package:hexa_tracker/pages/friends/friends.dart';
import 'package:hexa_tracker/pages/home/home.dart';
import 'package:hexa_tracker/pages/library/library.dart';
import 'package:hexa_tracker/pages/recomendations/recommendations.dart';
import 'package:hexa_tracker/pages/shop/shop.dart';
import 'package:hexa_tracker/pages/winrate/winrate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Flutter Demo",
      theme: ThemeData(
        primaryColor: Colors.amber
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const Home(),
        '/Recommendations': (context)=> const Recommendation(),
        '/WinRate': (context)=> const WinRate(),
        '/Shop' : (context)=> const Shop(),
        '/Library' : (context)=> const Library(),
        '/Friends' : (context)=> const Friends()
      },
      
    );
  }
}