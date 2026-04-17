import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexa_tracker/module/games_list.dart';
import 'package:hexa_tracker/ui/centered_view/centered_view.dart';

import 'package:hexa_tracker/ui/search_bar/search_bar.dart';
import 'package:hexa_tracker/ui/navigationBar/navigation_bar.dart';

class Home extends StatelessWidget {
  const Home({super.key});

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
 
                   Text("coisa")

                 
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
                        Text(
                          "Best Games",
                          style: TextStyle(color: Colors.white),
                        ),
                        SizedBox(width: 100),
                        Text(
                          "Victories",
                          style: TextStyle(color: Colors.white),
                        ),
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
