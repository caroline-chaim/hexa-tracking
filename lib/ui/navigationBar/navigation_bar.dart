import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationBarr extends StatelessWidget {
  const NavigationBarr({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      color: Color.fromARGB(255, 158, 179, 194),
      alignment: Alignment.center,

      child: Row(
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
              _NevBarItem("Win Rate"),
              SizedBox(width: 30),
              _NevBarItem("Shops"),
              SizedBox(width: 30),
              _NevBarItem("Library"),
              SizedBox(width: 30),
              _NevBarItem("Friends"),
            ],
          ),

          Row(
            children: [
              TextButton(
                onPressed: () {
                  print("Log in Button Pressed");
                },
                child: Container(
                  color: Color.fromARGB(255, 253, 254, 255),

                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                  child: Row(
                    children: [
                      Text(
                        "Log In",
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.person_outline,
                        color: Colors.black,
                        size: 30.0,
                      ),
                    ],
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  print("Log in Button Pressed");
                },
                child: Container(
                  color: Color.fromARGB(255, 98, 147, 175),

                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 3),
                  child: Row(
                    children: [
                      Text(
                        "Create Account",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Icon(
                        Icons.add_circle_outline,
                        color: Colors.white,
                        size: 30.0,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NevBarItem extends StatelessWidget {
  final String title;
  const _NevBarItem(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: GoogleFonts.lato(fontSize: 16));
  }
}
