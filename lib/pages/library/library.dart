import 'package:flutter/material.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';

class Library extends StatelessWidget {
  const Library({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(children: [NavigationBarr(),
      
      
      Text("Library")]),
    );
  }
}
