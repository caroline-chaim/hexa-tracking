import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationBarr extends StatelessWidget {
  const NavigationBarr({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      color: Color.fromARGB(255, 158, 179, 194),
      padding: EdgeInsets.symmetric(horizontal: 16),
      height: isMobile ? 60 : 70,
      child: isMobile
          ? _mobileBar(context)
          : _desktopBar(context),
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
            _NevBarItem("Home"),
            SizedBox(width: 30),
            _NevBarItem("Recommendations"),
            SizedBox(width: 30),
            _NevBarItem("WinRate"),
            SizedBox(width: 30),
            _NevBarItem("Shop"),
            SizedBox(width: 30),
            _NevBarItem("Library"),
            SizedBox(width: 30),
            _NevBarItem("Friends"),
          ],
        ),
        Row(
          children: [
            TextButton(
              onPressed: () {},
              child: Container(
                color: Color.fromARGB(255, 253, 254, 255),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                child: Row(
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
              onPressed: () {},
              child: Container(
                color: Color.fromARGB(255, 98, 147, 175),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                child: Row(
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
        ),
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
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ],
    );
  }
}

class _NevBarItem extends StatelessWidget {
  final String title;
  const _NevBarItem(this.title);

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