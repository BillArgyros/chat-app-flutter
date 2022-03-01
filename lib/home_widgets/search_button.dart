import 'package:flutter/material.dart';
import '../screens/search_screen.dart';


//a button that redirects the user to the search screen
Widget searchButton(
    context, screenWidth, screenHeight, userList, activeUser) {
  return Container(
    decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        border: Border.all(color: Colors.black, width: 0.5),
        borderRadius: BorderRadius.circular(32)),
    width: screenWidth * 0.9,
    padding: const EdgeInsets.only(right: 10),
    child: TextButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SearchScreen(
                userList: userList,
                activeUser: activeUser,
              )),
        );
      },
      icon: const Icon(
        Icons.search_rounded,
        color: Colors.black,
      ),
      label: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Search',
            style: TextStyle(color: Colors.black),
          )),
    ),
  );
}